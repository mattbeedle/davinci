require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::SizesController do

  describe 'GET index' do

    def do_get
      get :index
    end

    describe 'when administrator' do

      before(:each) do
        @user = mock_model(User, :id => 1, :has_role? => true)
        User.stub!(:find_by_id).and_return(@user)
        session[:user] = 1
        @size = mock_model(Size)
        @sizes = [@size]
        Size.stub!(:find).and_return(@sizes)
      end

      it "should find all sizes" do
        Size.should_receive(:find).once.and_return(@sizes)
        do_get
      end

      it "should assign the found sizes" do
        do_get
        assigns[:sizes].should == @sizes
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
      before(:each) do
        @size = mock_model(Size)
        @sizes = [@size]
        Size.stub!(:find).and_return(@sizes)
      end

      it "should redirect" do
        do_get
        response.should be_redirect
      end
    end
  end

  describe 'GET new' do

    def do_get
      get :new
    end
    
    describe 'when administrator' do
      before(:each) do
        @user = mock_model(User, :id => 1, :has_role? => true)
        User.stub!(:find_by_id).and_return(@user)
        session[:user] = 1
        @size = mock_model(Size)
        Size.stub!(:new).and_return(@size)
      end

      it "should instantiate a new size object" do
        Size.should_receive(:new).once.and_return(@size)
        do_get
      end

      it "should assign the size object" do
        do_get
        assigns[:size].should == @size
      end
    end

    describe 'when not administrator' do
      it "should redirect" do
        do_get
        response.should be_redirect
      end
    end
  end

  describe 'POST create' do

    def do_post
      post :create, :size => { :name => 'medium' }
    end

    describe 'when administrator' do
      before(:each) do
        @user = mock_model(User, :id => 1, :has_role? => true)
        User.stub!(:find_by_id).and_return(@user)
        session[:user] = 1
        @size = mock_model(Size, :save! => @size)
        Size.stub!(:new).and_return(@size)
      end

      it "should create a new user from the parameters" do
        Size.should_receive(:new).once.and_return(@size)
        do_post
      end

      it "should assign the size" do
        do_post
        assigns[:size].should == @size
      end

      it "should save the size" do
        @size.should_receive(:save!).once.and_return(@size)
        do_post
      end

      it "should create a flash notice" do
        do_post
        flash[:notice].should == 'Size created.'
      end

      it "should redirect to index" do
        do_post
        response.should redirect_to(admin_sizes_path)
      end
    end

    describe 'when not administrator' do
      it "should redirect" do
        do_post
        response.should be_redirect
      end
    end
  end

  describe 'GET edit' do

    def do_get
      get :edit, :id => '1'
    end

    describe 'when administrator' do
      before(:each) do
        @user = mock_model(User, :id => 1, :has_role? => true)
        User.stub!(:find_by_id).and_return(@user)
        session[:user] = 1
        @size = mock_model(Size, :id => 1)
        Size.stub!(:find_by_id).and_return(@size)
      end

      it "should find the specified size" do
        Size.should_receive(:find_by_id).once.with('1').and_return(@size)
        do_get
      end

      it "should assign the specified size" do
        do_get
        assigns[:size].should == @size
      end
    end

    describe 'when not administrator' do
      it "should redirect" do
        do_get
        response.should be_redirect
      end
    end
  end

  describe 'PUT update' do

    def do_put
      put :update, :id => '1', :size => { :name => 'test' }
    end

    describe 'when administrator' do
      before(:each) do
        @user = mock_model(User, :id => 1, :has_role? => true)
        User.stub!(:find_by_id).and_return(@user)
        session[:user] = 1
        @size = mock_model(Size, :id => 1, :update_attributes => @size)
        Size.stub!(:find_by_id).and_return(@size)
      end

      it "should find the specified size" do
        Size.should_receive(:find_by_id).once.with('1').and_return(@size)
        do_put
      end

      it "should update the size" do
        @size.should_receive(:update_attributes).once.and_return(@size)
        do_put
      end

      it "should create a flash success notice" do
        do_put
        flash[:notice].should == 'Size updated.'
      end

      it "should redirect to index" do
        do_put
        response.should redirect_to(admin_sizes_path)
      end
    end

    describe 'when not administrator' do
      it "should redirect" do
        do_put
        response.should be_redirect
      end
    end
  end

  describe 'DELETE destroy' do
    def do_delete
      delete :destroy, :id => '1'
    end

    describe 'when administrator' do
      before(:each) do
        @user = mock_model(User, :id => 1, :has_role? => true)
        User.stub!(:find_by_id).and_return(@user)
        session[:user] = 1
        @size = mock_model(Size, :id => 1, :destroy => @size)
        Size.stub!(:find_by_id).and_return(@size)
      end

      it "should find the specified size" do
        Size.should_receive(:find_by_id).once.with('1').and_return(@size)
        do_delete
      end

      it "should delete the specified size" do
        @size.should_receive(:destroy).once.and_return(@size)
        do_delete
      end

      it "should create flash notice" do
        do_delete
        flash[:notice].should == 'Size deleted.'
      end

      it "should redirect to index" do
        do_delete
        response.should redirect_to(admin_sizes_path)
      end
    end

    describe 'when not administrator' do
      it "should redirect" do
        do_delete
        response.should be_redirect
      end
    end
  end
end
