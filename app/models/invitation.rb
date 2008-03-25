class Invitation < ActiveRecord::Base
  belongs_to :sender,
    :class_name => 'User'

  validates_presence_of :sender_id, :code, :receiver_name, :receiver_email
  validates_numericality_of :sender_id
  validates_length_of :code, :in => 20..20
  validates_uniqueness_of :receiver_email

  before_validation :generate_code

  def generate_code
    chars = ["A".."Z","a".."z","0".."9"].collect { |r| r.to_a }.join
    self.code = (1..20).collect { chars[rand(chars.size)] }.pack("C*")
  end
end
