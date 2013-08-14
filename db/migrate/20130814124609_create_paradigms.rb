class CreateParadigms < ActiveRecord::Migration
  def change
    create_table :paradigms do |t|
      t.string :status
      t.text :comment

      t.timestamps
    end
  end
end
