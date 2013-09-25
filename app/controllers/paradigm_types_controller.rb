class ParadigmTypesController < ApplicationController
  protect_from_forgery :except => :upload
  skip_before_filter :require_login, only: [ :upload ]

  def index
    @title = "Paradigm types"
    @paradigm_types = ParadigmType.all
  end

  def upload
    fname = params["paradigm_types"]["file"]
    @infos = ParadigmType.add_file_data(fname.read)
    render 'upload_report.text.haml'
  end


end
