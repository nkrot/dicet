class DocumentsController < ApplicationController
  SPP = 30

  def index
    @title = "List of all documents"
    @documents = Document.all.paginate(page: params[:page], per_page: SPP)
  end

  def show
    @document = Document.find(params[:id])
    @title = "Document ##{@document.id}"
    @sentences = @document.sentences.paginate(page: params[:page], 
                                              per_page: SPP)
  end
end

