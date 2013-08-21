class AddParadigmTypeRefToParadigms < ActiveRecord::Migration
  def change
    #add_column :paradigms, :paradigm_type, :string
    add_reference :paradigms, :paradigm_type, index: true
  end
end
