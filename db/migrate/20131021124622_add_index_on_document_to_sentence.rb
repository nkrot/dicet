class AddIndexOnDocumentToSentence < ActiveRecord::Migration
  def change
    add_index :sentences, :document_id
  end
end
