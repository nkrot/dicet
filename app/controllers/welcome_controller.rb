class WelcomeController < ApplicationController
  skip_before_filter :require_login

  def index
    @title = "Home"
  end

  def help
    @title = "Help"
  end

  def about
    @title = "About"
  end

  def todo
    @title = "Secret page: TODO items"
  end
end
