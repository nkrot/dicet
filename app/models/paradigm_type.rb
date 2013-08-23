class ParadigmType < ActiveRecord::Base
  has_many :paradigm_tags
  has_many :tags, :through => :paradigm_tags
  has_many :paradigms

  validates :name, presence: true, uniqueness: true
end
