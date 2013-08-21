class ParadigmsController < ApplicationController

  def index
    # show all
    @paradigms = Paradigm.all
    pdg = @paradigms.first
    puts pdg.methods.sort
    puts pdg.inspect
#    puts pdg.paradigm_type
  end

  def show
    # show one paradigm
  end

  def new
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
    render 'new'
  end

  def edit
    @paradigm = Paradigm.find(params[:id])
  end

  def update
  end

  def destroy
  end

  private

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

  def each_paradigm params
    params[:pdg].each do |pdg_type, data|
      words = []
      data.each do |tag, hash|
        if tag !~ /^(status|comment)$/ && !hash[:word].empty?
          hash[:word].strip!
          hash[:tag].strip!

          w = find_suitable_word(hash, params[:word_id])

          w.update_attributes(tag: hash[:tag])
          words << w
        end
      end

      unless words.empty?
        pdg_type_id = ParadigmType.where(name: pdg_type).first
        puts "pdg_type -> pdg_type_id: #{pdg_type} -> #{pdg_type_id}"
        yield pdg_type_id, data[:status], data[:comment], words
      end
    end
  end

  def find_suitable_word(hash, current_word_id=nil)
    # find the word by the given ID
    if current_word_id
      # Q: what if the word somehow has already been taken to a paradigm
      # A: this should not happen, because such words go through paradigms#edit action
      #    not through paradigms#create
      attrs = {id: current_word_id, text: hash[:word], tag: nil, paradigm_id: nil}
      w = Word.find_by(attrs)
#      puts "Reusing the word #{w.text} with ID=#{w.id} /end" if w
    end

    # if nothing suitable was found by the id, find by word.text
    unless w
      # attributes that identify a Word that was not taken to a paradigm
      attrs = {text: hash[:word], tag: nil, paradigm_id: nil}
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
