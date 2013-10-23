class TokensController < ApplicationController

  def index
    if params[:unknown]
      @title = "Ranked list of corpus words that are unknown to FSE"
      @tokens = Token.unknown.ranked.paginate(page: params[:page], per_page: 50)
    else
      @title = "Ranked list of all corpus words"
      @tokens = Token.all.ranked.paginate(page: params[:page], per_page: 50)
    end
  end

end

