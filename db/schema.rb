# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 64) do

  create_table "albums", :force => true do |t|
    t.string   "name",                              :default => "",         :null => false
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id",                                                   :null => false
    t.string   "permalink",                         :default => "",         :null => false
    t.string   "privacy_type",                      :default => "public",   :null => false
    t.string   "salt",                :limit => 40
    t.string   "crypted_password",    :limit => 40
    t.boolean  "clean",                             :default => false,      :null => false
    t.boolean  "camera_info",                       :default => false,      :null => false
    t.boolean  "display_filenames",                 :default => false,      :null => false
    t.string   "sort_by",             :limit => 10, :default => "position", :null => false
    t.string   "sort_direction",      :limit => 4,  :default => "DESC",     :null => false
    t.boolean  "friends_edit",                      :default => false,      :null => false
    t.boolean  "family_edit",                       :default => false,      :null => false
    t.boolean  "commentable",                       :default => true,       :null => false
    t.float    "unsharp_radius",                    :default => 0.0,        :null => false
    t.float    "unsharp_sigma",                     :default => 1.0,        :null => false
    t.float    "unsharp_amount",                    :default => 1.0,        :null => false
    t.float    "unsharp_threshold",                 :default => 0.05,       :null => false
    t.boolean  "featured",                          :default => false,      :null => false
    t.string   "style"
    t.string   "theme"
    t.float    "default_photo_price",               :default => 0.0,        :null => false
  end

  add_index "albums", ["user_id"], :name => "index_albums_on_user_id"
  add_index "albums", ["permalink"], :name => "index_albums_on_permalink"
  add_index "albums", ["privacy_type"], :name => "index_albums_on_privacy_type"
  add_index "albums", ["featured"], :name => "index_albums_on_featured"

  create_table "comments", :force => true do |t|
    t.integer  "photo_id",                  :null => false
    t.integer  "user_id",    :default => 0, :null => false
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["photo_id"], :name => "index_comments_on_photo_id"
  add_index "comments", ["user_id"], :name => "index_comments_on_user_id"

  create_table "countries", :force => true do |t|
    t.string  "name",             :limit => 100, :default => "", :null => false
    t.string  "fedex_code",       :limit => 50
    t.string  "ufsi_code",        :limit => 4
    t.integer "number_of_orders",                :default => 0,  :null => false
  end

  add_index "countries", ["number_of_orders"], :name => "index_countries_on_number_of_orders"

  create_table "fast_sessions", :id => false, :force => true do |t|
    t.integer   "session_id_crc", :limit => 10,                 :null => false
    t.string    "session_id",     :limit => 32, :default => "", :null => false
    t.timestamp "updated_at",                                   :null => false
    t.text      "data"
  end

  add_index "fast_sessions", ["session_id_crc", "session_id"], :name => "session_id", :unique => true
  add_index "fast_sessions", ["updated_at"], :name => "updated_at"

  create_table "friendships", :force => true do |t|
    t.integer  "user_id",                         :null => false
    t.integer  "friend_id",                       :null => false
    t.datetime "created_at"
    t.datetime "accepted_at"
    t.string   "friendship_type", :default => "", :null => false
  end

  create_table "geocodes", :force => true do |t|
    t.decimal "latitude",    :precision => 15, :scale => 12
    t.decimal "longitude",   :precision => 15, :scale => 12
    t.string  "query"
    t.string  "street"
    t.string  "locality"
    t.string  "region"
    t.string  "postal_code"
    t.string  "country"
  end

  add_index "geocodes", ["query"], :name => "geocodes_query_index", :unique => true
  add_index "geocodes", ["longitude"], :name => "geocodes_longitude_index"
  add_index "geocodes", ["latitude"], :name => "geocodes_latitude_index"

  create_table "geocodings", :force => true do |t|
    t.integer "geocodable_id"
    t.integer "geocode_id"
    t.string  "geocodable_type"
  end

  add_index "geocodings", ["geocodable_type"], :name => "geocodings_geocodable_type_index"
  add_index "geocodings", ["geocode_id"], :name => "geocodings_geocode_id_index"
  add_index "geocodings", ["geocodable_id"], :name => "geocodings_geocodable_id_index"

  create_table "invitations", :force => true do |t|
    t.integer  "sender_id",                      :null => false
    t.string   "code",           :default => "", :null => false
    t.string   "receiver_name",  :default => "", :null => false
    t.string   "receiver_email", :default => "", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "invitations", ["code"], :name => "index_invitations_on_code"

  create_table "memberships", :force => true do |t|
    t.integer  "user_group_id"
    t.integer  "user_id"
    t.boolean  "admin",          :default => false, :null => false
    t.datetime "accepted_at"
    t.integer  "accepted_by_id"
    t.datetime "invited_at"
    t.integer  "invited_by_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "banned_at"
    t.integer  "banned_by_id"
  end

  add_index "memberships", ["user_group_id"], :name => "index_memberships_on_user_group_id"
  add_index "memberships", ["user_id"], :name => "index_memberships_on_user_id"

  create_table "memberships_albums", :force => true do |t|
    t.integer  "membership_id", :null => false
    t.integer  "album_id",      :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "memberships_albums", ["membership_id"], :name => "index_memberships_albums_on_membership_id"
  add_index "memberships_albums", ["album_id"], :name => "index_memberships_albums_on_album_id"

  create_table "notification_types", :force => true do |t|
    t.string   "name",            :default => "", :null => false
    t.string   "subject",         :default => "", :null => false
    t.text     "description"
    t.string   "notifyable_type", :default => "", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "notifications", :force => true do |t|
    t.integer  "sender_id",            :null => false
    t.integer  "receiver_id",          :null => false
    t.integer  "notification_type_id", :null => false
    t.integer  "notifyable_id",        :null => false
    t.datetime "read_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "notifications", ["sender_id"], :name => "index_notifications_on_sender_id"
  add_index "notifications", ["receiver_id"], :name => "index_notifications_on_receiver_id"

  create_table "order_account_types", :force => true do |t|
    t.string   "name",       :limit => 30, :default => "", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "order_accounts", :force => true do |t|
    t.integer  "order_account_type_id",               :default => 1, :null => false
    t.string   "cc_number",             :limit => 17
    t.string   "string",                :limit => 17
    t.string   "account_number",        :limit => 20
    t.integer  "expiration_month",      :limit => 2
    t.integer  "expiration_year",       :limit => 4
    t.integer  "credit_ccv",            :limit => 5
    t.string   "routing_number",        :limit => 20
    t.string   "bank_name",             :limit => 50
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "order_accounts", ["order_account_type_id"], :name => "ids"

  create_table "order_addresses", :force => true do |t|
    t.boolean  "is_shipping",               :default => false, :null => false
    t.string   "first_name",  :limit => 50
    t.string   "last_name",   :limit => 50
    t.string   "telephone",   :limit => 20
    t.string   "street",                    :default => "",    :null => false
    t.string   "locality",    :limit => 50
    t.string   "region",      :limit => 20
    t.string   "postal_code", :limit => 10
    t.integer  "country_id",                                   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "order_addresses", ["first_name", "last_name"], :name => "index_order_addresses_on_first_name_and_last_name"

  create_table "order_line_items", :force => true do |t|
    t.integer  "product_id", :null => false
    t.integer  "order_id",   :null => false
    t.integer  "photo_id",   :null => false
    t.integer  "quantity",   :null => false
    t.float    "unit_price", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "order_shipping_types", :force => true do |t|
    t.string   "name",                :limit => 100, :default => "",    :null => false
    t.string   "code",                :limit => 50
    t.string   "company",             :limit => 20
    t.boolean  "is_domestic",                        :default => false, :null => false
    t.string   "service_type",        :limit => 50
    t.string   "transaction_type",    :limit => 50
    t.float    "shipping_multiplier",                :default => 0.0,   :null => false
    t.float    "flat_fee",                           :default => 0.0,   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "order_status_codes", :force => true do |t|
    t.string   "name",       :limit => 30, :default => "", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "order_status_codes", ["name"], :name => "index_order_status_codes_on_name"

  create_table "order_users", :force => true do |t|
    t.string   "username",      :limit => 50
    t.string   "email",         :limit => 100, :default => "", :null => false
    t.string   "password_salt", :limit => 40,  :default => "", :null => false
    t.string   "password_hash", :limit => 40,  :default => "", :null => false
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "order_users", ["email"], :name => "index_order_users_on_email"
  add_index "order_users", ["user_id"], :name => "index_order_users_on_user_id"

  create_table "orders", :force => true do |t|
    t.datetime "shipped_on"
    t.integer  "user_id",                                 :null => false
    t.integer  "order_status_code_id",   :default => 1,   :null => false
    t.text     "notes"
    t.string   "referer"
    t.integer  "order_shipping_type_id", :default => 1,   :null => false
    t.float    "product_cost",           :default => 0.0
    t.float    "shipping_cost",          :default => 0.0
    t.float    "tax"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "shipping_address_id"
    t.integer  "billing_address_id"
    t.integer  "order_account_id"
  end

  add_index "orders", ["user_id"], :name => "index_orders_on_user_id"
  add_index "orders", ["order_status_code_id"], :name => "index_orders_on_order_status_code_id"

  create_table "photo_versions", :force => true do |t|
    t.integer  "photo_id"
    t.integer  "version"
    t.binary   "data"
    t.string   "name"
    t.string   "original_filename", :default => ""
    t.string   "content_type",      :default => ""
    t.float    "lat"
    t.float    "lng"
    t.integer  "album_id"
    t.string   "permalink",         :default => ""
    t.integer  "height"
    t.integer  "width"
    t.string   "street"
    t.string   "region"
    t.string   "locality"
    t.string   "postal_code"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position"
    t.boolean  "featured",          :default => false
    t.boolean  "private",           :default => false
    t.float    "price",             :default => 0.0
  end

  create_table "photos", :force => true do |t|
    t.binary   "data"
    t.string   "name"
    t.string   "original_filename", :default => "",    :null => false
    t.string   "content_type",      :default => "",    :null => false
    t.float    "lat"
    t.float    "lng"
    t.integer  "album_id",                             :null => false
    t.string   "permalink",         :default => "",    :null => false
    t.integer  "height",                               :null => false
    t.integer  "width",                                :null => false
    t.string   "street"
    t.string   "region"
    t.string   "locality"
    t.string   "postal_code"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position"
    t.boolean  "featured",          :default => false, :null => false
    t.integer  "version"
    t.boolean  "private",           :default => false, :null => false
    t.float    "price",             :default => 0.0,   :null => false
  end

  add_index "photos", ["album_id"], :name => "index_photos_on_album_id"
  add_index "photos", ["permalink"], :name => "index_photos_on_permalink"
  add_index "photos", ["featured"], :name => "index_photos_on_featured"

  create_table "product_sizes", :force => true do |t|
    t.integer  "product_id", :null => false
    t.integer  "size_id",    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "product_sizes", ["product_id", "size_id"], :name => "ids"

  create_table "products", :force => true do |t|
    t.string   "name",        :default => "",  :null => false
    t.text     "description"
    t.float    "price",       :default => 0.0, :null => false
    t.float    "weight",      :default => 0.0, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "products", ["name"], :name => "index_products_on_name"

  create_table "roles", :force => true do |t|
    t.string   "name",              :limit => 40
    t.string   "authorizable_type", :limit => 30
    t.integer  "authorizable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer  "user_id"
    t.integer  "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :default => "", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "sizes", :force => true do |t|
    t.string   "name",       :default => "", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type"], :name => "index_taggings_on_taggable_id_and_taggable_type"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "user_groups", :force => true do |t|
    t.string   "name",        :default => "",       :null => false
    t.text     "description"
    t.string   "group_type",  :default => "public", :null => false
    t.integer  "photo_id"
    t.string   "permalink",   :default => "",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "crypted_password",             :limit => 40
    t.string   "salt",                         :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.string   "activation_code",              :limit => 40
    t.datetime "activated_at"
    t.string   "forename"
    t.string   "surname"
    t.string   "street"
    t.string   "locality"
    t.string   "region"
    t.string   "postal_code"
    t.date     "born_on"
    t.integer  "profile_photo_id"
    t.datetime "trial_started_at"
    t.datetime "last_paid_at"
    t.integer  "sent_invitations",                           :default => 0,  :null => false
    t.integer  "redeemed_invitations",                       :default => 0,  :null => false
    t.integer  "invited_by_id"
    t.text     "bio"
    t.date     "membership_expires_on"
    t.text     "homepage_content_preferences",               :default => "", :null => false
  end

end
