class UsersController < ApplicationController
  skip_before_filter :require_login, only: [:new, :create]

  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
    @tasks = @user.tasks.paginate(page:     params[:page],
                                  per_page: TASKS_PER_PAGE,
                                  order:    'priority DESC')
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      sign_in @user # does signin on signup
      flash[:success] = "Welcome to our community, #{@user.login}"
      redirect_to @user
    else
      render 'new'
    end
  end

  def user_params
    params.require(:user).permit(:login, :email, :password)
  end
end
