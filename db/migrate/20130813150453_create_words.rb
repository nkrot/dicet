class CreateWords < ActiveRecord::Migration
  def change
    create_table :words do |t|
      t.string :text
      t.boolean :typo
      t.text :comment

      t.timestamps
    end
  end
end
