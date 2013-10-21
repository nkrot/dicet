class Document < ActiveRecord::Base
  has_many :sentences
  has_many :tokens, :through => :sentences
end
