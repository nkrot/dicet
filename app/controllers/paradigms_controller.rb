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
    # empty form for creating a new paradigm
    if params[:word_id]
      @word = Word.find(params[:word_id])
    end
    @paradigm = Paradigm.new
  end

  def create
    # bring a new paradigm and save it to db
    save_paradigms params

    @paradigm = Paradigm.new
    redirect_to new_paradigm_url
  end

  def edit
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
  end

  private

  def update_paradigm params
    saved = true
    pdg = Paradigm.find(params[:id])
#    params[:paradigm_id] = params[:id] # for find_suitable_word
    each_paradigm_2(params) do |pdg_type_id, words, extras|
      pdg.paradigm_type_id = pdg_type_id
      pdg.comment = extras["comment"]  if extras["comment"]
      pdg.status  = extras["status"]   if extras["status"]
      pdg.words.concat words
      saved = saved && pdg.save
      words.map {|w| w.update_attributes(paradigm_id: pdg.id) }
    end
    saved
  end

#  "pdg"=>{
#    "5"=>{
#      "96"=>{"10"=>"wander"},
#      "97"=>{"word"=>"wanders"},
#      "98"=>{"word"=>"wandering"},
#      "99"=>{"word"=>"wandered"},
#      "100"=>{"word"=>""},
#      "107"=>{"word"=>""},
#      "108"=>{"word"=>""},
#      "extras"=>{"comment"=>"", "status"=>"ready"}
#    }
#  }

  def each_paradigm_2 params
    params[:pdg].each do |pdg_type_id, data|
      words = []
      extras = {}
      data.each do |tag_id, word_data|
        if tag_id == "extras"
          ["comment", "status"].each do |field|
            val = word_data[field].strip
            extras[field] = val  unless val.nil? || val.empty?
          end

        elsif word_data.key?(Word.label) && word_data[Word.label].empty?
          # skip. we dont want to store empty words

        else
          w = find_suitable_word(word_data, params)
          w.update_attributes(tag_id: tag_id)
          words << w
        end
      end

      unless words.empty?
        yield pdg_type_id, words, extras
      end
    end

  end

  # TODO: get rid of it
  def save_paradigms params
#    puts params
    # extract individual paradigms from the form
    each_paradigm(params) do |pdg_type_id, status, comment, words|
      pdg = Paradigm.new(paradigm_type_id: pdg_type_id, status: status, comment: comment)
      pdg.words.concat words
#      puts "WORDS:\n #{words.inspect}"
      pdg.save
      words.map {|w| w.update_attributes(paradigm_id: pdg.id) } 
      # TODO: how to manage task_id? should it be updated for words originally
      # not in task but that were appended to the task through a paradigm
    end
  end

  # TODO: get rid of it
  def each_paradigm params
    params[:pdg].each do |pdg_type, data|
      words = []
      data.each do |tag, hash|
        if tag !~ /^(status|comment)$/ && !hash[:word].empty?
          hash[:word].strip!
          hash[:tag].strip!

          w = find_suitable_word(hash, params)

          w.update_attributes(tag_id: Tag.tag_name2tag_id(hash[:tag]))
          words << w
        end
      end

      unless words.empty?
        pdg_type_id = ParadigmType.where(name: pdg_type).first.id
        yield pdg_type_id, data[:status], data[:comment], words
      end
    end
  end

  # FIND_SUITABLE_WORD: {"word"=>"wander"}
  # PARAMS: {"paradigm_id"=>"5",
  #   "pdg"=>{"5"=>{"96"=>{"word"=>"wander"},
  #                 "97"=>{"word"=>"wanders"}, 
  #                 "98"=>{"word"=>"wandering"},
  #                 "99"=>{"word"=>"wandered"},
  #                 "100"=>{"word"=>""},
  #                 "107"=>{"word"=>""},
  #                 "108"=>{"word"=>""},
  #         "extras"=>{"comment"=>"", "status"=>"ready"}}},
  #     "commit"=>"Save", "action"=>"update", "controller"=>"paradigms", "id"=>"1"}

  def find_suitable_word(hash, params)
    puts "FIND_SUITABLE_WORD: #{hash.inspect}"
    puts "PARAMS: #{params.inspect}"

    current_word_id = params[:word_id] || nil

    label = hash.keys.first

    if label != Word.label
      # the key is word.id if the word was already in DB.
      # In this case just retrieve it.
      w = Word.find(label)

    elsif current_word_id
      # find the word by the given ID

      # Q: what if the word somehow has already been taken to a paradigm
      # A: this should not happen, because such words go through paradigms#edit action
      #    not through paradigms#create
      attrs = {id: current_word_id, text: hash[:word], tag_id: nil, paradigm_id: nil}
      w = Word.find_by(attrs)
#      puts "Reusing the word #{w.text} with ID=#{w.id} /end" if w
    end

    # if nothing suitable was found by the id, find by word.text
    unless w
      hash[:word].strip!
      # attributes that identify a Word that was not taken to a paradigm
      attrs = {text: hash[:word], tag_id: nil, paradigm_id: nil}
#      _word = Word.find_by(attrs)
#      puts "Found? #{_word.text} with ID=#{_word.id} /End"  if _word
      # TODO: the user can change word.text as well
      w = Word.where(attrs).first_or_create(text: hash[:word])
    end

    w
  end

#  def paradigm_params
#    params.require(:paradigm).permit(:status, :comment)
#  end
end
