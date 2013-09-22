class AddDumpedAtToParadigm < ActiveRecord::Migration
  def change
    add_column :paradigms, :dumped_at, :datetime
  end
end
