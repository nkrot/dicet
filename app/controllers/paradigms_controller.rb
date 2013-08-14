class ParadigmsController < ApplicationController

  def index
    # show all
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
      puts words.inspect
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

  def each_paradigm(params)
    params[:pdg].each do |pdg_type, data|
      words = []
      data.each do |tag, hash|
        if tag !~ /^(status|comment)$/
          words << Word.where(:text => hash[:word],
                              :tag => hash[:tag],
                              :paradigm_id => nil).first_or_create
        end
      end
      yield pdg_type, data[:status], data[:comment], words
    end
  end

#  def paradigm_params
#    params.require(:paradigm).permit(:status, :comment)
#  end
end
