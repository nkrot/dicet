class SentenceToken < ActiveRecord::Base
  belongs_to :sentence
  belongs_to :token
end
