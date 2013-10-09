class AddTaskToParadigm < ActiveRecord::Migration
  def change
    add_reference :paradigms, :task, index: true
  end
end
