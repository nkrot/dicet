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
#    puts "#{self.class}#upload: #{params.inspect}"
    fname = params["words"]["file"]
    @infos = add_file_data(fname.read)
    render 'upload_report.text.haml'
  end

  private

  # strong parameters
  # extract from params only required and permitted attributes
  def word_params
    params.require(:word).permit(:text, :typo, :comment, :task_id)
  end

  def add_file_data(data)
    tasksize = Task::NUMWORDS
    priority = Task::PRIORITY

    task = nil

    infos = {
      'number_of_tasks' => 0,
      'number_of_words' => 0,
      'rejected_lines'  => []
    }

    data.split(/\n/).each do |line|
      line.chomp!
      case line
      when line.empty?
        # skip
      when /^#/
        # skip comments
      when /^tasksize=(\d+)/i
        tasksize = $1.to_i
      when /^priority=(\d+)/i
        priority = $1.to_i
      else
        # word \t priority
        word, prty = line.sub(/\s#.+/, "").split
        prty = prty ? prty.to_i : priority

        if Word.exists?(text: word)
          infos['rejected_lines'] << line
        else
          unless task
            task = Task.create(priority: prty)
          end

          task.words.create(text: word)
          infos ['number_of_words'] += 1

          if task.words.count >= tasksize
            task.save
            task = nil
            infos ['number_of_tasks'] += 1
          end
        end
      end
    end

    infos
  end

end
