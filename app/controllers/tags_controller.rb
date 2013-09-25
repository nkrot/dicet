class TagsController < ApplicationController
  protect_from_forgery :except => :upload
  skip_before_filter :require_login, only: [ :upload ]

  def index
    @title = "Tagset"
    @tags = Tag.all
  end

  def upload
    fname = params["tags"]["file"]
    @infos = Tag.add_file_data(fname.read)
    render 'upload_report.text.haml'
  end
end
