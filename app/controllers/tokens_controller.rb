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

  def take
    puts "Token.take PARAMS: #{params.inspect}"
    token = Token.find(params[:id])
    @task = Task.create_with_tokens([token], current_user)
    puts @task.inspect
    puts @task.tokens.inspect
  end

  private

  def unknown_tokens_for_show(max=50)
    puts "Sorting unknown tokens by #{@order_by_column}"
    Token.unknown(filters).ranked(@order_by_column)
      .paginate(page: params[:page], per_page: max)
  end

  def generate_tasks
    num_tasks = 1
    tokens_per_task = 3

    puts "**** Generating tasks ****"
    puts "PARAMS: #{params}"

    user = params[:autoassign] ? current_user : nil

    num_tasks.times do
      # get tokens filtered in the same way as the user sees them on the page
      # TODO: have to convert to array to be able to take specific quantity of records
      # from the relation.
      tokens = unknown_tokens_for_show.to_a.take(tokens_per_task)
      task = Task.create_with_tokens(tokens, user)
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

