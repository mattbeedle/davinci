class Admin::ProductsController < ApplicationController

  layout 'master'

  before_filter :login_required
  permit 'administrator'

  def index
    @products = Product.paginate(:all,
                                 :page => params[:page] || 1,
                                 :per_page => 10)
  end

  def show
    @product = Product.find_by_name(params[:id])
    @sizes = @product.sizes
  end

  def new
    @product = Product.new
  end

  def create
    @product = Product.new(params[:product])
    @product.save!
    flash[:notice] = 'Product created.'
    redirect_to admin_products_path
  end

  def edit
    @product = Product.find_by_name(params[:id])
  end

  def update
    @product = Product.find_by_name(params[:id])
    @product.attributes = params[:product]
    @product.save!
    flash[:notice] = 'Product updated.'
    redirect_to admin_products_path
  end

  def destroy
    @product = Product.find_by_name(params[:id])
    @product.destroy
    flash[:notice] = 'Product deleted.'
    redirect_to admin_products_path
  end

  def add_size
    @product = Product.find_by_name(params[:id])
    @size = Size.find_by_id(params[:product_size][:size_id])
    @product.sizes << @size
    flash[:notice] = 'Size added.';
    redirect_to admin_product_path(@product)
  end
end
