class CreateTokens < ActiveRecord::Migration
  def change
    create_table :tokens do |t|
      t.string     :text,         index: true
      t.string     :upcased_text, index: true

      t.boolean    :unknown,      index: true, default: false

      t.integer    :corpus_freq
      t.integer    :number_docs
      t.integer    :cfnd,         index: true

      t.integer    :upcased_corpus_freq
      t.integer    :upcased_number_docs
      t.integer    :upcased_cfnd, index: true

      t.references :task,         index: true

      t.timestamps
    end
  end
end
