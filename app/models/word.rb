class Word < ActiveRecord::Base
  belongs_to :paradigm
  validates :text, presence: true, length: { maximum: 400 },
                   uniqueness: true
end
