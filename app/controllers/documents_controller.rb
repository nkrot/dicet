class DocumentsController < ApplicationController
  SPP = 30

  def show
    @document = Document.find(params[:id])
    @title = "Document ##{@document.id}"
    @sentences = @document.sentences.paginate(page: params[:page], 
                                              per_page: SPP)
  end
end

