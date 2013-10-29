class TasksController < ApplicationController

  def index
    if params[:user_id]
      @user = User.find(params[:user_id])
      set_user_tasks_data
      render 'user_tasks'
    else
      @title = "All unassigned dictionary tasks"
      @tasks = Task.unassigned.paginate(page:     params[:page],
                                        per_page: TASKS_PER_PAGE,
                                        order:    'priority DESC')
      @user_tasks = Task.assigned_to(current_user).except_ready
      render 'index'
    end
  end

  def take
#    puts "PARAMS: #{params.inspect}"

    @task = Task.find(params[:id])
    @task.user = current_user
    @task.save

    # TODO: same as in #index
    @tasks = Task.unassigned.paginate(page:     params[:page],
                                      per_page: TASKS_PER_PAGE,
                                      order:    'priority DESC')
    @user_tasks = Task.assigned_to(current_user).except_ready

  end

  def drop
    @task = Task.find(params[:id])
    @user = @task.user
    @task.user = nil
    @task.save

    set_user_tasks_data

    # TODO:
    # get rid of drop.js.haml and just render 'user_tasks' here.
    # will need to remove remote => true from drop buttons?
    # this allows merging tasks/user_tasks and tasks/_user_tasks templates
    # render 'user_tasks'
  end

  def ready
    if params[:user_id]
      @title = "Completed tasks"
      @user = User.find(params[:user_id])
      @tasks = @user.ready_tasks.paginate(page:     params[:page],
                                          per_page: TASKS_PER_PAGE,
                                          order:    'updated_at DESC')
    else
      @title = "Completed tasks by all users"
      @users = User.all
      @tasks = Task.ready.paginate(page:     params[:page],
                                   per_page: TASKS_PER_PAGE,
                                   order:    'updated_at DESC')
    end
    # we want general stats on the first page only
    @show_stats_table = params[:page].to_i-1 < 1
  end

  def generate
    user = nil
    user = User.find(params[:user_id])  if params[:user_id]

    5.times do
      task = Task.generate
      if user
        task.user = user
        task.save
      end
    end

    redirect_opts = { action: 'index' }
    redirect_opts[:user_id] = user.id  if user

    redirect_to redirect_opts
  end

  private

  # all variables necessary to render user tasks
  def set_user_tasks_data
    @title = "Tasks for #{@user.login}"

    @unfinished_tasks = @user.unfinished_tasks
    @new_tasks = @user.new_tasks.paginate(page:     params[:page],
                                          per_page: TASKS_PER_PAGE,
                                          order:    'priority DESC')
    # only on the first page
    @show_unfinished_tasks = params[:page].to_i-1 < 1
  end
end
