class TasksController < ApplicationController

  def index
    @title = "All dictionary tasks"
    @tasks = Task.where(user_id: nil).paginate(page:     params[:page],
                                               per_page: TASKS_PER_PAGE,
                                               order:    'priority DESC')
  end

  def update
    if update_user_tasks(params)
      flash[:success] = "Selected tasks have been added to your task set"
    else
      flash[:error] = "Failed to add selected tasks to your task set"
    end
    redirect_to user_path(current_user)
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