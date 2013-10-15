class CreateSentences < ActiveRecord::Migration
  def change
    create_table :sentences do |t|
      t.references :document

      t.timestamps
    end
  end
end
