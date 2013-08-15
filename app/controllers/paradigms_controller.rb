class ParadigmsController < ApplicationController

  def index
    # show all
    @paradigms = Paradigm.all
  end

  def show
    # show one paradigm
    # TODO: should probably be identical to edit
  end

  def new
    # empty form for creating a new paradigm
    @paradigm = Paradigm.new
  end

  def create
    # bring a new paradigm and save it to db
    @paradigm = Paradigm.new
    puts params

    # extract individual paradigms from the form
    each_paradigm(params) do |pdg_type, status, comment, words|
      puts "WORDS:\n #{words.inspect}"
      @pdg = Paradigm.new(paradigm_type: pdg_type, status: status, comment: comment)
      @pdg.words.concat words
      puts "WORDS:\n #{words.inspect}"
#     @pdg.words.save
      @pdg.save
      words.map {|w| w.paradigm_id = @pdg.id } 
    end

    render 'new'
  end

  def edit
  end

  def update
  end

  def destroy
  end

  private

# [
#  <Word id: nil, text: "book",    typo: nil, comment: nil, created_at: nil, updated_at: nil, tag: "VB", paradigm_id: nil>,
#  <Word id: nil, text: "booking", typo: nil, comment: nil, created_at: nil, updated_at: nil, tag: "VBG", paradigm_id: nil>
# ]

  def each_paradigm(params)
    params[:pdg].each do |pdg_type, data|
      words = []
      data.each do |tag, hash|
        if tag !~ /^(status|comment)$/
          # attributes that identify a Word that was not taken to a paradigm
          attrs = {text: hash[:word], tag: nil, paradigm_id: nil}
          _word = Word.find_by(attrs)
          puts "Found? #{_word.to_s}"
          words << Word.where(attrs).first_or_create
          puts __method__
        end
      end
      yield pdg_type, data[:status], data[:comment], words
    end
  end

#  def paradigm_params
#    params.require(:paradigm).permit(:status, :comment)
#  end
end
