class SessionsController < ApplicationController

  def new
    # empty login form for signing in
  end

  def create
    # starts a new session
    # by accepting the filled in form and storing it in db
    user = User.find_by(login: params[:session][:login])
    if user && user.authenticate(params[:session][:password])
      sign_in user
      redirect_to user
    else
      flash.now[:error] = 'Invalid login/password combination'
      render 'new'
    end
  end

  def destroy
    # finishes the session
    sign_out
    redirect_to root_url
  end
end
