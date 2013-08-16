class Word < ActiveRecord::Base
  belongs_to :paradigm
  validates :text, presence: true, length: { maximum: 400 }
  # uniqueness: true -- word can legally repeat several times if
  #  it has different tags and/or belongs to several paradigms
end
