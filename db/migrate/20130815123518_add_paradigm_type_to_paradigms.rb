class AddParadigmTypeToParadigms < ActiveRecord::Migration
  def change
    add_column :paradigms, :paradigm_type, :string
  end
end
