class WordsController < ApplicationController

  def index
    # show all
  end

  def show
    # show given word
    @word = Word.find(params[:id])
    @title = @word.text
  end

  def new
    # empty form for creating a new word
    @word = Word.new
  end

  def create
    @word = Word.new(word_params)
    if @word.save
      flash[:success] = "Word #{@word.text} added successfully"
      redirect_to new_word_path
    else
      render 'new'
    end
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

  private

  # strong parameters
  # extract from params only required and permitted attributes
  def word_params
    params.require(:word).permit(:text, :typo, :comment)
  end

end
