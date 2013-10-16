class CreateSentenceTokens < ActiveRecord::Migration
  def change
    create_table :sentence_tokens do |t|
      t.references :sentence, index: true
      t.references :token,    index: true
      t.integer :position

      t.timestamps
    end
  end
end
