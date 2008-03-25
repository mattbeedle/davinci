class TagsController < ApplicationController

  layout 'master'

  def show
    @effects = {}
    @width = 100
    @height = 100

    tag = params[:id]
    tag = tag.gsub(/\-/, ' ')
    @photos = Photo.find_tagged_with(tag)
    @albums = Album.find_tagged_with(tag)
  end
end
