class CreateWords < ActiveRecord::Migration
  def change
    create_table :words do |t|
      t.string     :text
      t.boolean    :typo
      t.text       :comment
      t.references :tag
      t.references :paradigm, index: true
      t.references :task,     index: true

      t.timestamps
    end
  end
end
