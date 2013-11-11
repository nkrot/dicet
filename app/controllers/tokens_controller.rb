class TokensController < ApplicationController

  def index
#    puts "params: #{params.inspect}"
    @order_by_column = order_by
    @page = params[:page] || 1

    if params[:commit] =~ /(Generate|Take).+tasks/i
      generate_tasks
    end

    if params[:unknown]
      @title = "Ranked list of corpus words that are unknown to FSE"
      @tokens = unknown_tokens_for_show
#      @tokens = Token.unknown(filters).ranked(@order_by_column)
#        .paginate(page: params[:page], per_page: 50)

    else
      @title = "Ranked list of all corpus words"
      @tokens = Token.all.ranked(@order_by_column)
        .paginate(page: params[:page], per_page: 50)
    end
  end

  private

  def unknown_tokens_for_show(max=50)
    puts "Sorting unknown tokens by #{@order_by_column}"
    Token.unknown(filters).ranked(@order_by_column)
      .paginate(page: params[:page], per_page: max)
  end

  def generate_tasks
    num_tasks = 1
    tokens_per_task = 2

    puts "**** Generating tasks ****"
    puts "PARAMS: #{params}"

    user = nil
    if params[:autoassign]
      puts "Will be assigned to: #{current_user.inspect}"
      user = current_user.id
    end

    num_tasks.times do
      # get tokens filtered in the same way as the user sees them on the page
      tokens = unknown_tokens_for_show.limit(tokens_per_task)
      puts "Number of tokens for the new task: #{tokens.length}"
      puts tokens.inspect
      # make a task with these tokens
#      task = Task.
    end
  end

  def filters
    params.permit(:al, :au, :tc, :other, :assigned)
  end

  def order_by
    if params[:orderby]
      params[:orderby]
    elsif params[:al]
      'cfnd'
    else
      'upcased_cfnd'
    end
  end
end

