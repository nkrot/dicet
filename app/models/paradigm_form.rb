class ParadigmForm
  attr_accessor :slots, :paradigm

  def initialize(obj=nil)
    @slots = []
    @paradigm = nil

    if obj.is_a? Hash
      parse_params obj
    elsif obj.is_a? Paradigm
      parse_paradigm obj
    end
  end

  # based on paradigms_controller#each_paradigm
  # TODO: do not use it to parse a form that contains multiple paradigms!
  # TODO: a way to linking the paradigm from params to a real paradigm existing in DB.
  #       this is necessary to serve updating existing paradigms (see update_paradigm)
  def parse_params(params)
    @paradigm = Paradigm.find_or_initialize_by(id: params["id"])

    params["pdg"].each do |num, pdgtid_data|
      pdgtid_data.each do |pdg_type_id, slots|
        @paradigm.paradigm_type_id = pdg_type_id       # TODO: when editing an existing pdg
        @paradigm.status  = slots["extras"]["status"]  # should wait until #save method is called
        @paradigm.comment = slots["extras"]["comment"] #

        slots.each do |tag_id, hash|
          next  if tag_id == "extras"

          hash.each do |num, tw_hash|
            slot = Slot.new(tw_hash.merge({tag_id: tag_id}))
            slot.paradigm_id = @paradigm.id
            @slots << slot
          end
        end
      end
    end
  end

  def old_words
    @slots.collect {|slot| slot.old_word }
  end

  def new_words
    @slots.collect {|slot| slot.new_word }
  end

  def extras
    {"comment" => @paradigm.comment, "status" => @paradigm.status}
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

    pdg.each_word_with_tag do |word, tag|
      slot = Slot.new
      slot.paradigm_id = pdg.id
      slot.old_word = word

      @slots << slot
    end

  end

#  def each
#    @slots.each do ||
#    end
#  end

  def method_missing(name, *args)
    @paradigm.send(name, *args)
  end

  def save
    # TODO: update comment, status
    
    @slots.each {|slot| slot.save}
  end
end

######################################################################

class ParadigmForm
  class Slot

    attr_accessor :old_word, :new_word, :paradigm_id

    def initialize(hash=nil)
      @old_word = @new_word = nil
      parse_hash(hash)  if hash
    end

    def deleted?
      ! @new_word
    end

#    def changed?
#    end

    def save
      debug = false
      # TODO: take logic from paradigms_controller#{save,update}_paradigm
      puts "Compare: #{@old_word.inspect} vs. #{@new_word.inspect}"  if debug
      
      if !@old_word && !@new_word
        # this happens if the user first added a new word+tag (w/o saving)
        # and then marked it for deletion
      
      elsif @old_word && ! @new_word
        # the old word was marked for deletion
        @old_word.suicide
 
      elsif old_word
        @old_word.update_from(@new_word)
        # !!! originally, it was in save_paradigm only
        @old_word.paradigm_id = paradigm_id  # !!!
        @old_word.save                       # !!!
      
      else
        # newly added word+tag pair
        @new_word.paradigm_id = paradigm_id
        @new_word.save
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
      else                        # hits { ... "101"=>"run"  ... }
        # old_word is set from word.id
        word_id = tw_hash.keys.detect {|k| k =~ /^\d+$/} #=>101
        @old_word = Word.find(word_id)
        # TODO: what if the old word was deleted or its tag changed in the meanwhile?
      end

      if tw_hash["deleted"].to_s.downcase =~ /^[1ty]/
        # if the word+tag is marked for deletion, we do not need the new word
        # the new word being equal to nil will signal the old word needs to be deleted
        @new_word = nil
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
