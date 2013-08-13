class Word < ActiveRecord::Base
  validates :text, presence: true, length: { maximum: 400 },
                   uniqueness: true
end
