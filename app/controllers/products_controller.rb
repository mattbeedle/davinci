class ProductsController < ApplicationController

  layout 'master'

  def index
    @user = User.find_by_login(params[:user_id])
    @album = @user.albums.find_by_permalink(params[:album_id])
    @photo = @album.photos.find_by_permalink(params[:photo_id])
    @products = Product.find(:all)
  end

  def show
    @user = User.find_by_login(params[:user_id])
    @album = @user.albums.find_by_permalink(params[:album_id])
    @photo = @album.photos.find_by_permalink(params[:photo_id])
    @product = Product.find_by_name(params[:id])
  end
end
