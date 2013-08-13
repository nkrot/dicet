class WordsController < ApplicationController

  def index
    # show all
  end

  def show
    # show given word
    @word = Word.find(params[:id])
  end

  def new
    # empty form for creating a new word
  end

  def create
    # no page
  end

  def edit
    # edit given word
  end

  def update
    # no page
  end

  def destroy
    # no page
  end
end
