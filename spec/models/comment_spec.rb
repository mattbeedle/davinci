require File.dirname(__FILE__) + '/../spec_helper'

describe Comment do
  include CommentSpecHelper

  before(:each) do
    @comment = Comment.new
  end

  it "should not be valid without photo id" do
    @comment.attributes = valid_comment_attributes.except(:photo_id)
    @comment.should_not be_valid
    @comment.photo_id = 1
    @comment.should be_valid
  end

  it "should not be valid if photo id is not numerical" do
    @comment.attributes = valid_comment_attributes.with(:photo_id => 'a')
    @comment.should_not be_valid
    @comment.photo_id = 1
    @comment.should be_valid
  end

  it "should not be valid if user id is not numerical" do
    @comment.attributes = valid_comment_attributes.with(:user_id => 'a')
    @comment.should_not be_valid
    @comment.user_id = 0
    @comment.should be_valid
  end

  it "should not be valid without body" do
    @comment.attributes = valid_comment_attributes.except(:body)
    @comment.should_not be_valid
    @comment.body = 'lksjdhfjewfwh'
    @comment.should be_valid
  end

  it "should be valid" do
    @comment.attributes = valid_comment_attributes
    @comment.should be_valid
  end
end
