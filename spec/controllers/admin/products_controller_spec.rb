require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::ProductsController do
  describe '/admin/products' do

    def do_get
      get :index
    end

    describe 'when administrator' do
      before(:each) do
        @user = mock_model(User, :id => 1, :has_role? => true)
        User.stub!(:find_by_id).and_return(@user)
        session[:user] = 1
        @product = mock_model(Product)
        @products = [@product]
        Product.stub!(:paginate).and_return(@products)
      end

      it "should find all products using pagination" do
        Product.should_receive(:paginate).once.and_return(@products)
        do_get
      end

      it "should assign the found products" do
        do_get
        assigns[:products].should == @products
      end

      it "should be success" do
        do_get
        response.should be_success
      end

      it "should render index template" do
        do_get
        response.should render_template(:index)
      end
    end

    describe 'when not administrator' do
      it "should be redirect" do
        do_get
        response.should be_redirect
      end
    end
  end

  describe 'GET /admin/products/lustre' do
    
    def do_get
      get :show, :id => 'lustre'
    end

    describe 'when administrator' do
      before(:each) do
        @user = mock_model(User, :id => 1, :has_role? => true)
        User.stub!(:find_by_id).and_return(@user)
        session[:user] = 1
        @size = mock_model(Size)
        @sizes = [@size]
        @product = mock_model(Product, :name => 'lustre', :sizes => @sizes)
        Product.stub!(:find_by_name).and_return(@product)
      end

      it "should find the specified product" do
        Product.should_receive(:find_by_name).once.with('lustre').and_return(@product)
        do_get
      end

      it "should assign the found product" do
        do_get
        assigns[:product].should == @product
      end

      it "should find the sizes associated with the found product" do
        @product.should_receive(:sizes).once.and_return(@sizes)
        do_get
      end

      it "should assign the sizes" do
        do_get
        assigns[:sizes].should == @sizes
      end

      it "should be success" do
        do_get
        response.should be_success
      end

      it "should render show template" do
        do_get
        response.should render_template(:show)
      end
    end

    describe 'when not administrator' do
      it "should redirect" do
        do_get
        response.should be_redirect
      end
    end
  end

  describe 'GET /admin/products/new' do
    def do_get
      get :new
    end

    describe 'when administrator' do
      before(:each) do
        @user = mock_model(User, :id => 1, :has_role? => true)
        User.stub!(:find_by_id).and_return(@user)
        session[:user] = 1
        @product = mock_model(Product)
        Product.stub!(:new).and_return(@product)
      end

      it "should instantiate a new product" do
        Product.should_receive(:new).and_return(@product)
        do_get
      end

      it "should assign the new product" do
        do_get
        assigns[:product].should == @product
      end

      it "should be success" do
        do_get
        response.should be_success
      end

      it "should render 'new' template" do
        do_get
        response.should render_template(:new)
      end
    end

    describe 'when not administator' do
      it "should redirect" do
        do_get
        response.should be_redirect
      end
    end
  end

  describe 'POST /admin/products' do
    include ProductSpecHelper

    def do_post
      post :create, :product => valid_product_attributes
    end

    describe 'when administrator' do
      before(:each) do
        @user = mock_model(User, :id => 1, :has_role? => true)
        User.stub!(:find_by_id).and_return(@user)
        session[:user] = 1
        @product = mock_model(Product, :save! => @product)
        Product.stub!(:new).and_return(@product)
      end

      it "should instantiate a new product using the posted parameters" do
        Product.should_receive(:new).once.and_return(@product)
        do_post
      end

      it "should save the product" do
        @product.should_receive(:save!).once.and_return(@product)
        do_post
      end

      it "should create a flash success notice" do
        do_post
        flash[:notice].should == 'Product created.'
      end

      it "should redirect to index page" do
        do_post
        response.should redirect_to(admin_products_path)
      end
    end

    describe 'when not administrator' do
      it "should redirect" do
        do_post
        response.should be_redirect
      end
    end
  end

  describe 'GET /admin/products/lustre' do
    def do_get
      get :edit, :id => 'lustre'
    end

    describe 'when administrator' do
      before(:each) do
        @user = mock_model(User, :id => 1, :has_role? => true)
        User.stub!(:find_by_id).and_return(@user)
        session[:user] = 1
        @product = mock_model(Product)
        Product.stub!(:find_by_name)
      end

      it "should find the specified product" do
        Product.should_receive(:find_by_name).once.with('lustre').and_return(@product)
        do_get
      end

      it "should assign the found product"
    end

    describe 'when not administrator' do
      it "should redirect" do
        do_get
        response.should be_redirect
      end
    end
  end

  describe 'PUT /admin/products/lustre' do
    include ProductSpecHelper

    def do_put
      put :update, :id => 'lustre', :product => valid_product_attributes
    end

    describe 'when administrator' do
      before(:each) do
        @user = mock_model(User, :id => 1, :has_role? => true)
        User.stub!(:find_by_id).and_return(@user)
        session[:user] = 1
        @product = mock_model(Product, :save! => @product, :attributes= => @product)
        Product.stub!(:find_by_name).and_return(@product)
      end

      it "should find the specified product" do
        Product.should_receive(:find_by_name).once.with('lustre').and_return(@product)
        do_put
      end

      it "should assign the product" do
        do_put
        assigns[:product].should == @product
      end

      it "should set the products attributes" do
        @product.should_receive(:attributes=).once.and_return(@product)
        do_put
      end

      it "should save the product" do
        @product.should_receive(:save!).once.and_return(@product)
        do_put
      end

      it "should create a flash success notice" do
        do_put
        flash[:notice].should == 'Product updated.'
      end

      it "should redirect to index page" do
        do_put
        response.should redirect_to(admin_products_path)
      end
    end

    describe 'when not administrator' do
      it "should redirect" do
        do_put
        response.should be_redirect
      end
    end
  end

  describe 'DELETE /admin/products/lustre' do

    def do_delete
      delete :destroy, :id => 'lustre'
    end

    describe 'when administrator' do
      before(:each) do
        @user = mock_model(User, :id => 1, :has_role? => true)
        User.stub!(:find_by_id).and_return(@user)
        session[:user] = 1
        @product = mock_model(Product, :name => 'lustre', :destroy => @product)
        Product.stub!(:find_by_name).and_return(@product)
      end

      it "should find the specified product" do
        Product.should_receive(:find_by_name).once.with('lustre').and_return(@product)
        do_delete
      end

      it "should delete the found product" do
        @product.should_receive(:destroy).once.and_return(@product)
        do_delete
      end

      it "should create a flash success notice" do
        do_delete
        flash[:notice].should == 'Product deleted.'
      end

      it "should redirect to index page" do
        do_delete
        response.should redirect_to(admin_products_path)
      end
    end

    describe 'when not administrator' do
      it "should redirect" do
        do_delete
        response.should be_redirect
      end
    end
  end

  describe 'PUT /admin/products/lustre/add_size' do
    def do_put
      put :add_size, :id => 'lustre', :product_size => { :size_id => '1' }
    end

    describe 'when administrator' do
      before(:each) do
        @user = mock_model(User, :id => 1, :has_role? => true)
        User.stub!(:find_by_id).and_return(@user)
        session[:user] = 1
        @size = mock_model(Size, :id => 1)
        @sizes = [@size]
        Size.stub!(:find_by_id).and_return(@size)
        @product = mock_model(Product, :sizes => @sizes, :to_param => 'lustre')
        Product.stub!(:find_by_name).and_return(@product)
      end

      it "should find the specified product" do
        Product.should_receive(:find_by_name).once.with('lustre').and_return(@product)
        do_put
      end

      it "should find the specified size" do
        Size.should_receive(:find_by_id).once.with('1').and_return(@size)
        do_put
      end

      it "should add the size to the products sizes" do
        @product.should_receive(:sizes).once.and_return(@sizes)
        do_put
      end

      it "should create flash success message" do
        do_put
        flash[:notice].should == 'Size added.'
      end

      it "should redirect to show page" do
        do_put
        response.should redirect_to(admin_product_path(@product))
      end
    end

    describe 'when not administrator' do
      it "should redirect" do
        do_put
        response.should be_redirect
      end
    end
  end
end
