class TokensController < ApplicationController

  def index
#    puts "params: #{params.inspect}"
    @order_by_column = params[:orderby] || 'upcased_cfnd'

    if params[:unknown]
      @title = "Ranked list of corpus words that are unknown to FSE"
      @tokens = Token.unknown(filters).ranked(@order_by_column)
        .paginate(page: params[:page], per_page: 50)

    else
      @title = "Ranked list of all corpus words"
      @tokens = Token.all.ranked(@order_by_column)
        .paginate(page: params[:page], per_page: 50)
    end
  end

  private

  def filters
    params.permit(:al, :assigned, :orderby)
  end
end

