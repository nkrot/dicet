class Tag < ActiveRecord::Base
  has_many :words
  has_many :paradigm_tags
  has_many :paradigm_types, :through => :paradigm_tags

  validates :name, presence: true, uniqueness: true

#  default_scope :include => :paradigm_tags, :order => 'paradigm_tags.order ASC'

  # TODO: find case-insensitively
  def self.tag_name2tag_id tag_name
    Tag.find_by(name: tag_name).id
  end

  def readonly_html?
    self.name.upcase != "NOTAG"
  end

  def notag?
    self.name == "NOTAG"
  end

  def self.notag?(tag_id)
    Tag.find(tag_id).notag?
  end

  def self.add_file_data(data)

    infos = {
      'added_tags' => 0,
      'updated_descriptions' => 0,
      'rejected_lines' => []
    }

    data.split(/\n/).each do |_line|
      line = _line.chomp.strip.sub(/\s+#.+/, "")

      if line =~ /^#/ || line.empty?
        # skip comments
      else
        tag, descr = line.split(/\s+/, 2)
        attrs = {name: tag, description: descr}

        if Tag.exists?(attrs)
          infos['rejected_lines'] << _line

        elsif Tag.exists?(name: tag)
          Tag.find_by({name: tag}).update_attributes({description: descr})
          infos['updated_descriptions'] += 1

        else
          Tag.create(attrs)
          infos['added_tags'] += 1
        end
      end

    end

    infos
  end

end
