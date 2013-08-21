class ParadigmTags < ActiveRecord::Migration
  def change
    create_table :paradigm_tags do |t|
      t.belongs_to :paradigm_type
      t.belongs_to :tag
      t.integer    :order
      t.timestamps
    end
  end
end
