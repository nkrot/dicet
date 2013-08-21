class CreateParadigmTypes < ActiveRecord::Migration
  def change
    create_table :paradigm_types do |t|
      t.string     :name
      t.integer    :order
      t.references :tag

      t.timestamps
    end

    add_index :paradigm_types, :name
  end
end
