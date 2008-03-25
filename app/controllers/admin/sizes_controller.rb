class Admin::SizesController < ApplicationController

  layout 'master'

  before_filter :login_required
  permit 'administrator'

  def index
    @sizes = Size.find(:all)
  end

  def new
    @size = Size.new
  end

  def create
    @size = Size.new(params[:size])
    @size.save!
    flash[:notice] = 'Size created.'
    redirect_to admin_sizes_path
  end

  def edit
    @size = Size.find_by_id(params[:id])
  end

  def update
    @size = Size.find_by_id(params[:id])
    @size.update_attributes params[:size]
    flash[:notice] = 'Size updated.'
    redirect_to admin_sizes_path
  end

  def destroy
    @size = Size.find_by_id(params[:id])
    @size.destroy
    flash[:notice] = 'Size deleted.'
    redirect_to admin_sizes_path
  end
end
