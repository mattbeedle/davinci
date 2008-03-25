class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :photo

  validates_presence_of :photo_id, :user_id, :body
  validates_numericality_of :photo_id, :user_id

end
