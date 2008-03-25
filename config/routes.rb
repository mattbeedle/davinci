ActionController::Routing::Routes.draw do |map|
  map.resource :session
  map.resource :payment
  map.resource :cart, :member => { :shipping => :get, :set_shipping => :put, :checkout => :get,
    :billing => :get, :set_billing => :put, :show_order => :get, :confirm_order => :post }
  map.resources :order_users
  map.resource :order_session
  map.resources :orders

  map.resource :homepage_settings

  map.resources :notifications
  map.resources :tags
  map.resources :homes, :collection => { :update_stylesheet => :put }

  map.resources :users, :member => { :set_profile_photo => :put, :my_groups => :get } do |user|

    user.resources :friendships,
      :singular => 'friend'
    user.resources :invitations
    user.resource :history
    user.resources :albums,
      :member => { :login_form => :get, :login => :post } do |album|

      album.resources :geocodings
      album.resources :photos,
        :singular => 'photo',
        :member => { :move_form => :get, :move => :put, :download => :get } do |photo|

        photo.resources :geocodings,
          :member => { :select => :put }
        photo.resources :versions
        photo.resources :comments
        photo.resources :products, :name_prefix => ''
      end
    end
  end

  map.resources :user_groups,
    :singular => 'user_group',
    :member => { :invite => :get, :add_album_form => :get, :add_album => :put } do |user_group|
    
    user_group.resources :memberships,
      :collection => { :awaiting_approval => :get, :mass_approve => :put, :invite => :post }
  end

  # ADMIN AREA
  map.namespace(:admin) do |admin|
    admin.resources :user_groups,
      :has_many => [:memberships]
    admin.resources :notification_types
    admin.resources :products, :member => { :add_size => :put }
    admin.resources :countries
    admin.resources :sizes
  end

  map.login '/login', :controller => 'sessions', :action => 'new'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.register '/register', :controller => 'users', :action => 'new'
  map.order_register '/order-register', :controller => 'order_users', :action => 'new'
  map.contact_us '/contact-us', :controller => 'homes', :action => 'contact'

  map.index '/', :controller => 'homes', :action => 'index'
  map.home_logged_in '/home', :controller => 'homes', :action => 'index_logged_in'

  map.home '/:id', :controller => 'users', :action => 'show'
  map.user '/:id', :controller => 'users', :action => 'show'
end
