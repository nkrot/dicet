class TasksController < ApplicationController
  TASKS_PER_PAGE = 4

  def index
    @title = "All dictionary tasks"
    # TODO: sort by priority
#    @tasks = Task.where(user_id: nil)

    # ok, this works
    # TODO: limit to unassigned tasks only
    @tasks = Task.where(user_id: nil).paginate(page:     params[:page],
                                               per_page: TASKS_PER_PAGE,
                                               order:    'priority DESC')
  end

  def update
  end
end
