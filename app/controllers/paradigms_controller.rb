class ParadigmsController < ApplicationController

  def index
    # show all
    @paradigms = Paradigm.all
  end

  # TODO: unnecessary?
  def show
    @paradigm = Paradigm.find(params[:id])
    @title = "Paradigm"
  end

  def new
    @title = "Add a new paradigm"

    @paradigm_types = ParadigmType.all.map do |pdgt|
      Paradigm.new(paradigm_type_id: pdgt.id)
    end

    @paradigms = ParadigmType.all.map do |pdgt|
      Paradigm.new(paradigm_type_id: pdgt.id)
    end

    if params[:word_id]
      @word = Word.find(params[:word_id])
      # if a word is already in paradigms, retrieve them
      word_paradigms = Word.where(text: @word.text).map(&:paradigm) #=> Relation
#      puts "WORD_PARADIGMS:"
#      puts word_paradigms.inspect
      word_paradigms = word_paradigms.to_a.compact
      unless word_paradigms.empty?
        @paradigms.unshift *word_paradigms
      end
    end

#    puts @paradigms.class
#    puts @paradigms.methods.sort
#    puts @paradigms.first.class
  end

  def create
    # bring a new paradigm and save it to db
    save_paradigms params

    @paradigm = Paradigm.new
    redirect_to new_paradigm_url # TODO: for a new word from this task
  end

  def edit
    @current_word = Word.find_by(id: params[:word_id])
    @paradigm = Paradigm.find(params[:id])
    @title = "Edit paradigm"
  end

  def update
    if update_paradigm(params)
      flash[:success] = "Paradigm saved successfully"
    else
      flash[:error] = "Shit happened when saving paradigm"
    end
    redirect_to user_url(@current_user)
  end

  def destroy
    # TODO: deleting paradigms implies:
    #  deleting pdg id from paradigm model
    #  deleting words that reference this pdg id:
    #    a) original word must persist in db, pdg_id and tag are removed
    #    b) newly added word is purged
    #  implement word.delete that follows the above logic
    puts "Deleting #{params[:id]}"
  end

  private

  def update_paradigm params
    saved = true
    pdg = Paradigm.find(params[:id])
    each_paradigm(params) do |pdg_type_id, words, extras|
      pdg.paradigm_type_id = pdg_type_id
      pdg.comment = extras["comment"]  if extras["comment"]
      pdg.status  = extras["status"]   if extras["status"]
      pdg.words.concat words
      saved = pdg.save && saved
      words.map {|w| w.update_attributes(paradigm_id: pdg.id) }
    end
    saved
  end

#  "pdg"=>{
#   "idx"=> {
#     "5"=>{
#       "96"=>{"10"=>"wander"},
#       "97"=>{"word"=>"wanders"},
#       "98"=>{"word"=>"wandering"},
#       "99"=>{"word"=>"wandered"},
#       "100"=>{"word"=>""},
#       "107"=>{"word"=>""},
#       "108"=>{"word"=>""},
#       "extras"=>{"comment"=>"", "status"=>"ready"}
#     }
#   }
# }

  def each_paradigm params
    params[:pdg].each_value do |hash|
      puts hash.inspect
      hash.each do |pdg_type_id, data|
        words = []
        extras = {}
        data.each do |tag_id, word_data|
          if tag_id == "extras"
            ["comment", "status"].each do |field|
              next  unless word_data[field]
              val = word_data[field].strip
              extras[field] = val  unless val.nil? || val.empty?
            end

          elsif word_data.key?(Word.label) && word_data[Word.label].empty?
            # skip. we dont want to store empty words

          else
#            puts "tag_id: #{tag_id}"
#            if Tag.notag?(tag_id) && word_data.key?("tag")
#              tag_id = Tag.tag_name2tag_id word_data["tag"]
#              puts "found tag_id: #{tag_id}"
#            end
            w = find_suitable_word(word_data, params)
#            w.update_attributes(tag_id: tag_id)
            words << w
          end
        end
        
        unless words.empty?
          yield pdg_type_id, words, extras
        end
      end
    end
  end

  # TODO: cf with update_paradigm and refactor
  def save_paradigms params
    saved = true
#    puts params
    each_paradigm(params) do |pdg_type_id, words, extras|
      puts "pdg_type_id=#{pdg_type_id}"
      puts "words: #{words.inspect}"
      puts "extras: #{extras.inspect}"
      pdg = Paradigm.new
      pdg.paradigm_type_id = pdg_type_id
      pdg.comment = extras["comment"]  if extras["comment"]
      pdg.status  = extras["status"]   if extras["status"]
      pdg.words.concat words
      saved = saved && pdg.save
      words.map {|w| w.update_attributes(paradigm_id: pdg.id) }
    end
    saved
  end

  def find_suitable_word(hash, params)
    puts "FIND_SUITABLE_WORD: #{hash.inspect}"
    puts "PARAMS: #{params.inspect}"

    current_word_id = params[:word_id] || nil

    # either "word" or word.id
    key_for_word = hash.keys.reject{|k| k == "tag"}.first

    if key_for_word != Word.label
      # the hash has no key "word" but a numeric word.id
      #   {"tag"=>"TAG", "10"=>"WORD"}
      # if the word was already in DB. In this case just retrieve it.
      attrs = {id: key_for_word, text: hash[key_for_word], tag_id: nil, paradigm_id: nil}
      w = Word.find_by(attrs)

    elsif current_word_id
      # find the word by the given ID and word.text
      attrs = {id: current_word_id, text: hash[key_for_word], tag_id: nil, paradigm_id: nil}
      w = Word.find_by(attrs)
#      puts "Reusing the word #{w.text} with ID=#{w.id} /end" if w
    end

    unless w
      # if nothing suitable was found by the id, find by word.text or create a new word
      word_text = hash[key_for_word].strip
      # attributes that identify a Word that was not taken to a paradigm
      attrs = {text: word_text, tag_id: nil, paradigm_id: nil}
#      _word = Word.find_by(attrs)
#      puts "Found? #{_word.text} with ID=#{_word.id} /End"  if _word
      # TODO: the user can change word.text as well
      w = Word.where(attrs).first_or_create(text: word_text)
    end

    # update the word tag
    tag_id = Tag.tag_name2tag_id(hash[:tag])
    w.update_attributes(tag_id: tag_id)
    w.save

    w
  end

#  def paradigm_params
#    params.require(:paradigm).permit(:status, :comment)
#  end
end

