class TagsController < ApplicationController
  protect_from_forgery :except => :upload
  skip_before_filter :require_login, only: [ :upload ]

  def index
    @title = "Tagset"
    @tags = Tag.all
  end

  # example:
  # curl -F "tags[file]=@tmp/tagset.txt" http://localhost:3000/tags/upload
  # NOTE: @ is mandatory
  def upload
    fname = params["tags"]["file"]
    @infos = TagsController.add_file_data(fname.read)
    render 'upload_report.text.haml'
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
