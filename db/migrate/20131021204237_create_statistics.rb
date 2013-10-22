class CreateStatistics < ActiveRecord::Migration
  def change
    create_table :statistics do |t|
      t.references  :token, index: true

      t.integer     :corpus_freq
      t.integer     :number_docs
      t.integer     :cfnd,  index: true

      t.integer     :upcased_corpus_freq
      t.integer     :upcased_number_docs
      t.integer     :upcased_cfnd, index: true
#      t.timestamps
    end

#    add_index :statistics, :cfnd
#    add_index :statistics, :upcased_cfnd
  end
end
