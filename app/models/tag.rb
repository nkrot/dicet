class Tag < ActiveRecord::Base
  has_many :words
  has_many :paradigm_tags
  has_many :paradigm_types, :through => :paradigm_tags

  validates :name, presence: true, uniqueness: true

#  default_scope :include => :paradigm_tags, :order => 'paradigm_tags.order ASC'

  def Tag.tag_name2tag_id tag_name
    Tag.find_by(name: tag_name).id
  end

end
