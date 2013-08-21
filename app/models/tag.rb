class Tag < ActiveRecord::Base
  belongs_to :paradigm_type
  belongs_to :word

  validates :name, presence: true, uniqueness: true
end
