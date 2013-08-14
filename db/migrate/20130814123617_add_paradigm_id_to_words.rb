class AddParadigmIdToWords < ActiveRecord::Migration
  def change
    add_column    :words, :tag, :string
    add_reference :words, :paradigm, index: true
  end
end
