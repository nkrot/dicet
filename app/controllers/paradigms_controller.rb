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
    render 'new'
  end

  def edit
  end

  def update
  end

  def destroy
  end

#  private

#  def paradigm_params
#    params.require(:paradigm).permit(:status, :comment)
#  end
end
