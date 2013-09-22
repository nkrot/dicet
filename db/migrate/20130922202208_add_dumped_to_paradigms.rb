class AddDumpedToParadigms < ActiveRecord::Migration
  def change
    add_column :paradigms, :dumped, :boolean, :default => false
    add_index  :paradigms, :dumped
  end
end
