class AddTaskRefToWords < ActiveRecord::Migration
  def change
    add_reference :words, :task, index: true
  end
end
