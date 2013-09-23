class WordsController < ApplicationController

  protect_from_forgery :except => :upload
  skip_before_filter :require_login, only: [ :upload ]

  def index
    # show all
    @words = Word.all
#    puts @words.first.methods.sort
#    puts @words.first.inspect
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

  # example:
  # curl -F "words[file]=@tmp/newwords.txt" http://localhost:3000/words/upload
  # NOTE: @ is mandatory
  def upload
    puts "#{self.class}#upload: #{params.inspect}"
    fname = params["words"]["file"]
    data = fname.read
    puts "Data read:\n#{data}"
    render :text => "File uploaded\n"
  end

  private

  # strong parameters
  # extract from params only required and permitted attributes
  def word_params
    params.require(:word).permit(:text, :typo, :comment, :task_id)
  end

end
