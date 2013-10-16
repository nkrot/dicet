class SentencesController < ApplicationController
  protect_from_forgery :except => :upload
  skip_before_filter :require_login, only: [ :upload ]

  def index
    @title = "All Sentences"
    @sentences = Sentence.all.paginate(page: params[:page], per_page: 7)
    @tokens = SentenceToken.all
  end

  def upload
    fname = params["sentences"]["file"]
    @infos = Sentence.add_file_data(fname.read)
    render 'upload_report.text.haml'
  end
end
