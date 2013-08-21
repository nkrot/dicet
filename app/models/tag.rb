class Tag < ActiveRecord::Base
  belongs_to :word
  has_many :paradigm_tags
  has_many :paradigm_types, :through => :paradigm_tags

  validates :name, presence: true, uniqueness: true

#  default_scope :include => :paradigm_tags, :order => 'paradigm_tags.order ASC'
end
