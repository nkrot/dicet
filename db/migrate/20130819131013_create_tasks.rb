class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.integer    :priority
      t.string     :status
      t.references :user

      t.timestamps
    end

    add_index :tasks, :user_id
    add_index :tasks, [:user_id, :priority]
    add_index :tasks, :priority
  end
end
