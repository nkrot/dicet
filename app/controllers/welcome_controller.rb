class WelcomeController < ApplicationController
  def index
    @title = "Home"
  end

  def help
    @title = "Help"
  end

  def about
    @title = "About"
  end
end
