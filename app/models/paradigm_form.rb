class ParadigmForm
  attr_accessor :slots, :paradigm
  attr_reader :comment, :status, :paradigm_type_id
  attr_reader :current_word

  def initialize(obj=nil)
    @slots = []
    @paradigm = nil
    @comment = @status = nil
    @paradigm_type_id = nil
    @current_word = nil

    if obj.is_a? Hash
      parse_params obj
    elsif obj.is_a? Paradigm
      parse_paradigm obj
    end
  end

  # based on paradigms_controller#each_paradigm
  # NOTE: do not use it to parse a form that contains multiple paradigms!
  #
  def parse_params(params)
    debug = false

    if params['word_id']
      @current_word = Word.find(params['word_id'])
    end

    params["pdg"].each do |num, pdgtid_data|
      pdgtid_data.each do |pdg_type_id, slots|
        @paradigm_type_id = pdg_type_id.to_i
        @status  = slots["extras"]["status"]
        @comment = slots["extras"]["comment"]

        @paradigm ||= Paradigm.find_or_initialize_by(id: params["id"]) do |pdg|
          pdg.paradigm_type_id = @paradigm_type_id 
        end

        slots.each do |tag_id, hash|
          next  if tag_id == "extras"

          hash.each do |num, tw_hash|
            slot = Slot.new(tw_hash.merge({tag_id: tag_id}))
            slot.paradigm = @paradigm
            puts "SLOT: #{slot.inspect}"  if debug
            @slots << slot
          end
        end
      end
    end

    # we do not want to delete a duplicate tag just because it is empty:
    # it may be the intention of the user to obtain a conversion for that tag
#    sanitize
  end

  def old_words
    @slots.collect {|slot| slot.old_word }
  end

  def new_words
    @slots.collect {|slot| slot.new_word }
  end

  def extras
    {"comment" => @comment, "status" => @status}
  end

  # unknown paradigm
  #  Parameters: {"page_section_id"=>"paradigm_data_2", "word_id"=>"7", pdg=>...}
  #  "pdg"=>{
  #    "1"=>{
  #      ---- can be abstracted into ParadigmForm model ---
  #      ---- in parse_params the hash below is called pdgtid_data
  #      "8"=>{ # paradigm_type.id
  #        "53"=>{ # tag.id
  #          "0"=>{"tag"=>"JJ", "word"=>"run", "deleted"=>"false"}
  #        },
  #        "54"=>{
  #          "1"=>{"tag"=>"JJR", "word"=>"", "deleted"=>"false"}
  #        },
  #        "55"=>{
  #          "2"=>{"tag"=>"JJT", "word"=>"", "deleted"=>"false"}
  #        },
  #        "92"=>{
  #          "3"=>{"tag"=>"RB", "word"=>"", "deleted"=>"false"}
  #        },
  #        "extras"=>{"comment"=>"", "status"=>"ready"}
  #      }
  #     -----------------------------------------------
  #    }
  #  }
  #
  # Known paradigm
  #Parameters: {"page_section_id"=>"paradigm_data_0", "word_id"=>"7", pdg=>...}
  #  "pdg"=>{
  #    "0"=>{
  #      ---- can be abstracted into ParadigmForm model ---
  #      "3"=>{                          # paradigm_type.id=3
  #        "60"=>{                       # tag.id=60
  #          "0"=>{"tag" => "NN",
  #                 "7"  => "run",       # word.id=7
  #                 "deleted"=>"false"}
  #        },
  #        "61"=>{
  #           "1"=>{"tag"=>"NNS",
  #                 "10"=>"",            # word.id=10
  #                 "deleted"=>"false"}
  #        },
  #        "extras"=>{"comment"=>"", "status"=>"ready"
  #       }
  #      ----------------------------------------------
  #      }
  #    }
  #  }
 
  # # know paradigm with two NNS and an extra VB
  #  Parameters: {"page_section_id"=>"paradigm_data_0", "word_id"=>"7", "pdg"=>"..."}
  #  "pdg"=> {
  #    "0"=>{
  #      "3"=>{
  #        "60"=>{
  #          "0"=>{"tag"=>"NN", "7"=>"run", "deleted"=>"false"}
  #        },
  #        "61"=>{ # NNS
  #          "1"=>{"tag"=>"NNS", "10"=>"runs", "deleted"=>"false"},
  #          "9"=>{"tag"=>"NNS", "word"=>"runz", "deleted"=>"false"},
  #          "10"=>{"tag"=>"VB", "word"=>"", "deleted"=>"false"}    # obtained by copying NNS, should be moved away
  #        },
  #        "extras"=>{"comment"=>"", "status"=>"ready"}
  #      }
  #    }
  #  }

  def parse_paradigm pdg
    @paradigm = pdg
    @paradigm_type_id = @paradigm.paradigm_type_id

    pdg.each_word_with_tag do |word, tag|
      slot = Slot.new
      slot.paradigm = pdg
      slot.old_word = word

      @slots << slot
    end

    sanitize
  end

  def each_pair_of_words
    @slots.each do |sl|
      yield sl.old_word, sl.new_word
    end
  end

  def method_missing(name, *args)
    @paradigm.send(name, *args)
  end

  def save
    attrs = {
      status: @status,
      comment: @comment,
      paradigm_type_id: @paradigm_type_id
    }
    @paradigm.update_attributes(attrs) # this also calls @paradigm.save which is important
    @slots.each {|slot| slot.save}

    assign_task # and save

    sanitize
  end

  def fill_with_conversions
    debug = false

    src_words = new_words.select {|w| !w.empty? }
    trg_words = new_words.select {|w|  w.empty? }

    if debug
      puts "***** BEFORE *****"
      puts src_words.inspect
      puts trg_words.inspect
    end

    Inflector.convert(src_words, trg_words)

    if debug
      puts "***** AFTER *****"
      puts src_words.inspect
      puts trg_words.inspect
    end
  end

  private

  # Rules for assigning a paradigm to a task
  # Goal: the paradigm can be assigned to a task iff it contains a word
  #       that belongs to this task as well.
  # TODO: instead of resetting, assign task from another word in the paradigm?
  def assign_task
    if @paradigm.task
      if @paradigm.has_word_linked_to_task? @paradigm.task
        # the current value of task_id is no longer valid
        @paradigm.update_attributes(task: nil)
      end

    elsif @current_word && @paradigm.has_word_or_homonym_of(@current_word)
      @paradigm.update_attributes(task: @current_word.task)

    else
      @paradigm.update_attributes(task: nil)
    end
  end

  def sanitize

    pdg_tags = @paradigm.tags

    # delete unnecessary paradigm slots
    @slots.delete_if do |sl|
      # delete an empty slot
      sl.empty? \
      && \
      ( \
        # that duplicates another non-empty slot
        @slots.any? {|_sl| _sl.tag == sl.tag && ! _sl.empty? } \
        || \
        # or that has the tag that does not belong to this paradigm type
        ! pdg_tags.include?(sl.tag)
      )
    end

    # add slots for the tags that must be in the paradigm but are missing
    pdg_tags.each do |t|
      if ! @slots.any? {|sl| sl.tag == t}
        sl = Slot.new
        sl.old_word = Word.new(tag: t)
        @slots << sl
      end
    end

    # ensure the order of tags is also correct:
    # first go tags that belong to the paradigm
    # followed by other tags
    pdgt_tags = @paradigm.paradigm_type.tags

    @slots.sort_by! do |s|
      # compute a number that represents the tag position based on
      # 1. the order of the tag in this paradigm
      pdg_tag = s.tag.paradigm_tags.where(paradigm_type: @paradigm.paradigm_type).first
      n = pdg_tag ? pdg_tag.order : s.tag.id
      # 2. if the tag is not in this paradigm, order the tag by its global id
      #    and add 1000 to push this tag to the end of the ordered sequence
      n += (pdgt_tags.include?(s.tag) ? 0 : 1000)
      n
    end
  end
end

######################################################################

class ParadigmForm
  class Slot

    attr_accessor :old_word, :new_word, :paradigm

    def initialize(hash=nil)
      if hash
        parse_hash(hash)  
      else
        @old_word = Word.new
        @new_word = Word.new
      end
    end

    def deleted?
      @new_word.empty?
    end

#    def changed?
#    end

    def empty?
      old_word.empty? && new_word.empty?
    end

#    def nonempty?
#      ! empty?
#    end

    def tag
      old_word.tag
    end

    def save
      debug = false
      # TODO: take logic from paradigms_controller#{save,update}_paradigm
      puts "Compare: #{@old_word.inspect} vs. #{@new_word.inspect}"  if debug
      
      if @old_word.empty? && @new_word.empty?
        # this happens if the user first added a new word+tag (w/o saving)
        # and then marked it for deletion
      
      elsif @old_word.nonempty? && @new_word.empty?
        # the old word was marked for deletion
        puts "the old word will be deleted"  if debug
        old_word = Word.new {|w| w.tag = @old_word.tag}
        @old_word.suicide
        @old_word = old_word
 
      elsif @old_word.nonempty?
        puts "the old word will be updated from the new word"  if debug
        @old_word = @old_word.update_from(@new_word)
        # !!! originally, it was in save_paradigm only
        @old_word.paradigm = @paradigm # !!!
        @old_word.save                 # !!!
      
      else
        puts "the new word will be added"  if debug
        # newly added word+tag pair
        @new_word.paradigm = @paradigm
        @new_word.save
        @old_word = @new_word
      end
    end

    private

    # The hash that represents a single paradigm slot EXTENDED with
    # an additional key-val "tag_id"=>"NUM" that corresponds to the original tag
    # TODO: tag_id however is not yet used. note that is the slot was obtained by copying
    #       another slot (pressing (+)) the old tag id is not relevant
    #
    # {"tag"=>"VB", "101"=>"run", "deleted=>"", "tag_id"=>"60"},   # word.id=101
    #   or w/o old_word
    # {"tag"=>"VB", "word"=>"run", "deleted"=>"", "tag_id"=>"61"}, # no word.id means new word
    #   or with deleted set to true
    # {"tag"=>"NNS", "128"=>"palabras", "deleted"=>"true", "tag_id"=>"80"}

    def parse_hash tw_hash
      @old_word = nil
      @new_word = nil

      if tw_hash.key? Word.label  # hits { ... "word"=>"run" ... }
        # no old word
        word_id = Word.label
        @old_word = Word.new {|w| w.tag_id = tw_hash["tag_id"].to_i }

      else                        # hits { ... "101"=>"run"  ... }
        # old_word is set from word.id
        word_id = tw_hash.keys.detect {|k| k =~ /^\d+$/} #=>101
        @old_word = Word.find(word_id)
        # TODO: what if the old word was deleted or its tag changed in the meanwhile?
      end

      if tw_hash["deleted"].to_s.downcase =~ /^[1ty]/
        # if the word+tag is marked for deletion, we do not need the new word
        # the new word being equal to nil will signal the old word needs to be deleted
        @new_word = Word.new
      else
        # otherwise,
        # new_word is set from submitted *values* of the keys "tag" and 101 or "word"
        # or is retrieved from db if it is already there and has not yet been taken to a pdg
        word_text = tw_hash[word_id].strip
        attrs = {text: word_text, tag_id: nil, paradigm_id: nil}
        @new_word = Word.where(attrs).first_or_initialize
        @new_word.tag = Tag.find_by(name: tw_hash["tag"])
      end
    end
  end
end
