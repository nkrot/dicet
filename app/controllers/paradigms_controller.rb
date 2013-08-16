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
    save_paradigms params

    @paradigm = Paradigm.new
    render 'new'
  end

  def edit
  end

  def update
  end

  def destroy
  end

  private

  def save_paradigms params
#    puts params
    # extract individual paradigms from the form
    each_paradigm(params) do |pdg_type, status, comment, words|
      pdg = Paradigm.new(paradigm_type: pdg_type, status: status, comment: comment)
      pdg.words.concat words
#      puts "WORDS:\n #{words.inspect}"
      pdg.save
      words.map {|w| w.update_attributes(paradigm_id: pdg.id) } 
    end
  end

  def each_paradigm params
    params[:pdg].each do |pdg_type, data|
      words = []
      data.each do |tag, hash|
        if tag !~ /^(status|comment)$/ && !hash[:word].empty?
          # attributes that identify a Word that was not taken to a paradigm
          attrs = {text: hash[:word], tag: nil, paradigm_id: nil}

#          _word = Word.find_by(attrs)
#          puts "Found? #{_word.to_s}"

          # TODO: the user can change word.text as well
          w = Word.where(attrs).first_or_create(text: hash[:word])
          w.update_attributes(tag: hash[:tag])

          words << w
        end
      end
      unless words.empty?
        yield pdg_type, data[:status], data[:comment], words
      end
    end
  end

#  def paradigm_params
#    params.require(:paradigm).permit(:status, :comment)
#  end
end
