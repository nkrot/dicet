class TasksController < ApplicationController

  def index
    @title = "All dictionary tasks"
    @tasks = Task.unassigned.paginate(page:     params[:page],
                                      per_page: TASKS_PER_PAGE,
                                      order:    'priority DESC')
    @user_tasks = Task.assigned_to(current_user)
  end

  def update
    if update_user_tasks(params)
      flash[:success] = "Selected tasks have been added to your task set"
    else
      flash[:error] = "Failed to add selected tasks to your task set"
    end
    redirect_to user_path(current_user)
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
    @user_tasks = Task.assigned_to(current_user)
  end

  def drop
    @task = Task.find(params[:id])

    # TODO: as in users_controller#show
    @user = @task.user

    @task.user = nil
    @task.save

    # TODO: as in users_controller#show
    @unfinished_tasks = @user.unfinished_tasks
    @new_tasks = @user.new_tasks.paginate(page:     params[:page],
                                          per_page: TASKS_PER_PAGE,
                                          order:    'priority DESC')
  end

  private

  def update_user_tasks(params)
    saved = true
    params[:tasks].keys.each do |task_id|
      # TODO: what if the task has already been taken? -- report that the task
      # could not be assigned to the current user.
      task = Task.where(id: task_id, user_id: nil).first
      saved = task.update_attributes(user_id: current_user.id) && saved
    end
    saved
  end
end
