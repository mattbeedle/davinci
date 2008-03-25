class UserGroup < ActiveRecord::Base

  has_many :memberships,
    :dependent => :destroy
  has_many :users,
    :through => :memberships
  has_many :admins,
    :through => :memberships,
    :source => :user,
    :conditions => ['memberships.admin = ? AND memberships.accepted_at IS NOT NULL', true]
  has_many :non_admins,
    :through => :memberships,
    :source => :user,
    :conditions => ['memberships.admin = ? AND memberships.accepted_at IS NOT NULL', false]
  has_many :unapproved_memberships,
    :through => :memberships,
    :source => :user,
    :conditions => 'memberships.accepted_at IS NULL'
  has_many :approved_memberships,
    :through => :memberships,
    :source => :user,
    :conditions => 'memberships.accepted_at IS NOT NULL'

  validates_presence_of :name, :group_type

  def before_save
    self.permalink = self.name.downcase.gsub(/\s/, '-')
  end

  def to_param
    self.permalink
  end

  def is_member?(user)
    self.users.include? user
  end

  def is_approved_member?(user)
    membership = Membership.find_by_user_id_and_user_group_id(user.id, self.id)
    unless membership.blank?
      if membership.accepted_at.blank?
        return false
      else
        return true
      end
    end
    false
  end

  def is_admin?(user)
    membership = self.memberships.find(:first,
                                       :conditions => ['user_id = ? AND admin = ?', user.id, true])
    return true unless membership.blank?
    false
  end

  def public?
    self.group_type == 'public'
  end

  def protected?
    self.group_type == 'protected'
  end

  def private?
    self.group_type == 'private'
  end

  def members_awaiting_approval
    self.unapproved_memberships
  end

  def approved_members
    self.approved_memberships
  end

  def unapproved_members
    self.unapproved_memberships
  end

  def albums(options = {})
    Album.find(:all,
               :joins => 'INNER JOIN memberships_albums ON memberships_albums.album_id = albums.id ' +
               'INNER JOIN memberships ON memberships.id = memberships_albums.membership_id ' +
               'INNER JOIN user_groups ON memberships.user_group_id = user_groups.id',
               :conditions => ['user_groups.id = ? AND memberships.banned_at IS NULL', self.id],
               :order => options[:order] || nil,
               :limit => options[:limit] || nil)
  end

  def photos(options = {})
    Photo.find(:all,
               :joins => 'INNER JOIN albums ON albums.id = photos.album_id ' +
               'INNER JOIN memberships_albums ON memberships_albums.album_id = albums.id ' +
               'INNER JOIN memberships ON memberships.id = memberships_albums.membership_id ' +
               'INNER JOIN user_groups ON memberships.user_group_id = user_groups.id',
               :conditions => ['user_groups.id = ? AND memberships.banned_at IS NULL', self.id],
               :order => options[:order] || nil,
               :limit => options[:limit] || nil)
  end

  def tag_counts
    @album_tags = Tag.find(:all,
                           :select => 'tags.id, tags.name, COUNT(*) AS count',
                           :joins => 'INNER JOIN taggings ON tags.id = taggings.tag_id ' +
                           'INNER JOIN albums ON albums.id = taggings.taggable_id ' +
                           'INNER JOIN memberships_albums ON memberships_albums.album_id = albums.id ' +
                           'INNER JOIN memberships ON memberships.id = memberships_albums.membership_id ' +
                           'INNER JOIN user_groups ON user_groups.id = memberships.user_group_id',
                           :conditions => ['user_groups.id = ? AND taggings.taggable_type = ? AND memberships.banned_at IS NULL', self.id, 'Album'],
                           :group => 'tags.id, tags.name')
    @photo_tags = Tag.find(:all,
                           :select => 'tags.id, tags.name, COUNT(*) AS count',
                           :joins => 'INNER JOIN taggings ON tags.id = taggings.tag_id ' +
                           'INNER JOIN photos ON photos.id = taggings.taggable_id ' +
                           'INNER JOIN albums ON albums.id = photos.album_id ' +
                           'INNER JOIN memberships_albums ON memberships_albums.album_id = albums.id ' + 
                           'INNER JOIN memberships ON memberships.id = memberships_albums.membership_id ' +
                           'INNER JOIN user_groups ON user_groups.id = memberships.user_group_id',
                           :conditions => ['user_groups.id = ? AND taggings.taggable_type = ? AND memberships.banned_at IS NULL', self.id, 'Photo'],
                           :group => 'tags.id, tags.name')
    @album_tags.each do |album_tag|
      if @photo_tags.include? album_tag
        @photo_tags.each do |tag|
          tag.count += album_tag.count if tag == album_tag
        end
      else
        @photo_tags << album_tag
      end
    end
    @photo_tags
  end

  def recent_members
    self.users.find(:all,
                    :limit => 20,
                    :order => 'memberships.created_at ASC')
  end

  def add_album(album)
    membership = Membership.find_by_user_id_and_user_group_id(album.user.id, self.id)
    membership.albums << album
    self
  end
end
