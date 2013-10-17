class SentencesController < ApplicationController
  protect_from_forgery :except => :upload
  skip_before_filter :require_login, only: [ :upload ]

  SPP = 15 # sentences per page in pagination

  def index
    @title = "All Sentences"
    @sentences = Sentence.all.paginate(page: params[:page], per_page: SPP)
    @tokens = SentenceToken.all
    @found_tokens = []
  end

  def search
    @title = "Search results"
    @sentences, @found_tokens = Sentence.search(search_params)
    @sentences = @sentences.paginate(page: params[:page], per_page: SPP)

    render 'index'
  end

  def upload
    fname = params["sentences"]["file"]
    bname = File.basename(fname.original_filename)
    @infos = Sentence.add_file_data(fname.read.force_encoding('utf-8'), bname)
    render 'upload_report.text.haml'
  end

  private

  def search_params
    params.permit(:word, :casesensitive)
  end
end
