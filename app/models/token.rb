class Token < ActiveRecord::Base
  has_many :sentence_tokens
  has_many :sentences, :through => :sentence_tokens

  validates :text, presence: true, uniqueness: true
  validates :upcased_text, presence: true

end
