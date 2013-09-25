class ParadigmType < ActiveRecord::Base
  has_many :paradigm_tags
  has_many :tags, :through => :paradigm_tags
  has_many :paradigms

  validates :name, presence: true, uniqueness: true

  def self.add_file_data(data)
    infos = {
      'added_pdg_types' => 0,
      'rejected_lines' => []
    }

    data.split(/\n/).each do |_line|
      line = _line.chomp.strip.sub(/\s+#.+/, "")

      if line =~ /^#/ || line.empty?
        # skip comments
      else
        name, *tags = line.split

        tags = tags.uniq.map {|t| Tag.where(name: t).first}

        if tags.any? {|t| t.is_a?(String)}
          # some tags do not exist in db
          infos['rejected_lines'] << _line

        elsif ParadigmType.exists?(name: name)
          # do not affect existing pdg types
          infos['rejected_lines'] << _line

        else
          pdg_type = ParadigmType.create(name: name)

          # set the proxytable ParadigmTag explicitly
          # because we need to set additional attribute <order>
          # that can not be set through an association.
          tags.each_with_index do |t, idx|
            pdg_type.paradigm_tags << ParadigmTag.create do |pt|
              pt.paradigm_type_id = pdg_type.id
              pt.tag_id           = t.id
              pt.order            = idx
            end
          end
          pdg_type.save

          infos['added_pdg_types'] += 1
        end
      end
    end
    infos
  end

end
