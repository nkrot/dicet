class TasksController < ApplicationController

  def index
    @title = "All dictionary tasks"
    @tasks = Task.where(user_id: nil).paginate(page:     params[:page],
                                               per_page: TASKS_PER_PAGE,
                                               order:    'priority DESC')

    @user_tasks = Task.where(user_id: current_user)
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

#    @tasks = Task.where(user_id: nil) # all unassigned tasks
#    @user_tasks = @task.user.tasks

    # TODO: same as in #index
    @tasks = Task.where(user_id: nil).paginate(page:     params[:page],
                                               per_page: TASKS_PER_PAGE,
                                               order:    'priority DESC')
    @user_tasks = Task.where(user_id: current_user)
  end

  def drop
    @task = Task.find(params[:id])

    # TODO: as in users_controller#show
    @user = @task.user

    @task.user = nil
    @task.save

    # TODO: as in users_controller#show
    @tasks = @user.tasks.paginate(page: params[:page],
                                        per_page: TASKS_PER_PAGE,
                                        order:    'priority DESC')

  end

  private

  def update_user_tasks(params)
    saved = true
    params[:tasks].keys.each do |task_id|
      # TODO: what if the task has already been taken? -- report that the task
      # could not be assigned to the current user.
      task = Task.find_by(id: task_id, user_id: nil)
      saved = task.update_attributes(user_id: current_user.id) && saved
    end
    saved
  end
end
