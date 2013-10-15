class Sentence < ActiveRecord::Base
  has_many :tokens, :through => :sentence_tokens
end
