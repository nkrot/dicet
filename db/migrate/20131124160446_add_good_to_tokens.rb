class AddGoodToTokens < ActiveRecord::Migration
  def change
    add_column :tokens, :good, :boolean, :default => true
    add_index :tokens, :good
  end
end
