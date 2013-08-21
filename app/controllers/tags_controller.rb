class TagsController < ApplicationController
  def index
    @title = "Tagset"
    @tags = Tag.all
  end
end
