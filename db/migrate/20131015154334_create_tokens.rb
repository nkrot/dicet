class CreateTokens < ActiveRecord::Migration
  def change
    create_table :tokens do |t|
      t.string :text
      t.string :upcased_text

      t.timestamps
    end

    add_index :tokens, :text
    add_index :tokens, :upcased_text
  end
end
