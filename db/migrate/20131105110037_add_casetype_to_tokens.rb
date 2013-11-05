class AddCasetypeToTokens < ActiveRecord::Migration
  def change
    add_column :tokens, :casetype,        :string,  index: true
    add_column :tokens, :hrmmean,         :integer, index: true
    add_column :tokens, :upcased_hrmmean, :integer, index: true
  end
end
