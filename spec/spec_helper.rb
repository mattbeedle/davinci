# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'spec'
require 'spec/rails'

Spec::Runner.configure do |config|
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.fixture_path = RAILS_ROOT + '/spec/fixtures/'

  # == Fixtures
  #
  # You can declare fixtures for each example_group like this:
  #   describe "...." do
  #     fixtures :table_a, :table_b
  #
  # Alternatively, if you prefer to declare them only once, you can
  # do so right here. Just uncomment the next line and replace the fixture
  # names with your fixtures.
  #
  # config.global_fixtures = :table_a, :table_b
  #
  # If you declare global fixtures, be aware that they will be declared
  # for all of your examples, even those that don't use them.
  #
  # == Mock Framework
  #
  # RSpec uses it's own mocking framework by default. If you prefer to
  # use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
end

class Hash
  def with(overrides = {})
    self.merge overrides
  end
end

module AlbumSpecHelper
  def valid_album_attributes
    {
      :name => 'test',
      :user_id => 1,
      :privacy_type => 'public',
      :clean => false,
      :camera_info => false,
      :display_filenames => false,
      :sort_by => 'position',
      :sort_direction => 'DESC'
    }
  end
end

module PhotoSpecHelper
  def photo_effect_parameters
    {
      :size => 'original',
      :crop => true,
      :sepia => { :threshold => 80 },
      :solarize => { :threshold => 80 },
      :posterize => { :levels => 4 },
      :despeckle => 1,
      :enhance => 1,
      :quantize => { :colors => 256, :colorspace => 'gray' },
      :charcoal => { :sigma => 3.0, :radius => 3.0 },
      :modulate => { :brightness => 1.5, :saturation => 1.5, :hue => 1.5 },
      :oil_paint => { :radius => 3.0 },
      :negate => 1
    }
  end
end

module CommentSpecHelper
  def valid_comment_attributes
    {
      :photo_id => 1,
      :user_id => 0,
      :body => 'a test comment'
    }
  end
end

module UserGroupSpecHelper
  def valid_user_group_attributes
    {
      :name => 'test-group',
      :group_type => 'public'
    }
  end
end

module MembershipSpecHelper
  def valid_membership_attributes
    {
      :user_group_id => 2,
      :user_id => 1,
      :admin => true
    }
  end
end

module NotificationSpecHelper
  def valid_notification_attributes
    {
      :sender_id => 1,
      :receiver_id => 2,
      :notification_type_id => 1,
      :notifyable_id => 1
    }
  end
end

module NotificationTypeSpecHelper
  def valid_notification_type_attributes
    {
      :name => 'Group invitation',
      :subject => 'New group invitation',
      :description => 'You have been invited to GROUP by RECEIVER',
      :notifyable_type => 'Membership'
    }
  end
end

module InvitationSpecHelper
  def valid_invitation_attributes
    {
      :sender_id => 1,
      :code => 'fkenghdkslekjftislat',
      :receiver_name => 'test',
      :receiver_email => 'test@test.com'
    }
  end
end

module ProductSpecHelper
  def valid_product_attributes
    {
      :name => 'lustre',
      :price => 0.19,
      :weight => 0.0
    }
  end
end

module SizeSpecHelper
  def valid_size_attributes
    {
      :name => 'medium'
    }
  end
end

module ProductSizeSpecHelper
  def valid_product_size_attributes
    {
      :product_id => 1,
      :size_id => 2
    }
  end
end

module OrderAddressSpecHelper
  def valid_order_address_attributes
    {
      :street => 'test',
      :postal_code => 'BR3 4DA',
      :country_id => 1
    }
  end

  def new_order_address(attributes = {})
    OrderAddress.new valid_order_address_attributes.merge(attributes)
  end
end

module OrderUserSpecHelper
  def valid_order_user_post_attributes
    {
      :email => 'test@test.com',
      :email_confirmation => 'test@test.com',
      :password => 'password',
      :password_confirmation => 'password'
    }
  end

  def new_order_user(attributes = {})
    OrderUser.new valid_order_user_post_attributes.merge(attributes)
  end
end

module OrderLineItemHelper
  def valid_order_line_item_attributes
    {
      :product_id => 1,
      :order_id => 1,
      :photo_id => 1,
      :quantity => 2,
      :unit_price => 0.10
    }
  end

  def new_order_line_item(attributes = {})
    OrderLineItem.new valid_order_line_item_attributes.merge(attributes)
  end
end

module OrderAccountSpecHelper
  def valid_order_account_attributes
    {
      :cc_number => "32543455345434",
      :expiration_month => 12,
      :expiration_year => '2010'
    }
  end
end
