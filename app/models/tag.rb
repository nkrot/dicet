class Tag < ActiveRecord::Base
  has_many :words
  has_many :paradigm_tags
  has_many :paradigm_types, :through => :paradigm_tags

  validates :name, presence: true, uniqueness: true

#  default_scope :include => :paradigm_tags, :order => 'paradigm_tags.order ASC'

  # TODO: find case-insensitively
  def Tag.tag_name2tag_id tag_name
    Tag.find_by(name: tag_name).id
  end

  def readonly_html?
    self.name.upcase != "NOTAG"
  end

  def notag?
    self.name == "NOTAG"
  end

  def Tag.notag?(tag_id)
    Tag.find(tag_id).notag?
  end
end
