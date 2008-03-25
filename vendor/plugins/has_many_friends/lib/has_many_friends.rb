module HasManyFriends

  module UserExtensions
  
    def self.included( recipient )
      recipient.extend( ClassMethods )
    end
    
    module ClassMethods
      def has_many_friends(options={})
        has_many :friendships_by_me,
                 :foreign_key => 'user_id',
                 :class_name => 'Friendship'
        
        has_many :friendships_for_me,
                 :foreign_key => 'friend_id',
                 :class_name => 'Friendship'
        
        has_many :friends_by_me,
                 :through => :friendships_by_me,
                 :source => :friendshipped_for_me,
                 :conditions => 'accepted_at IS NOT NULL' do
                  def family
                    find(:all, :conditions => ['friendship_type = ?', 'Family'])
                  end
                  def friends
                    find(:all, :conditions => ['friendship_type = ?', 'Friend'])
                  end
                  def online
                    find(:all, :conditions => ['status <> ? AND updated_at > ?', 'offline', 65.seconds.ago]) if options[:online_method]
                  end
                 end
        
        has_many :friends_for_me,
                 :through => :friendships_for_me,
                 :source => :friendshipped_by_me,
                 :conditions => 'accepted_at IS NOT NULL' do
                  def family
                    find(:all, :conditions => ['friendship_type = ?', 'Family'])
                  end
                  def friends
                    find(:all, :conditions => ['friendship_type = ?', 'Friend'])
                  end
                  def online
                    find(:all, :conditions => ['status <> ? AND updated_at > ?', 'offline', 65.seconds.ago]) if options[:online_method]
                  end
                 end
        
        has_many :pending_friends_by_me,
                 :through => :friendships_by_me,
                 :source => :friendshipped_for_me,
                 :conditions => 'accepted_at IS NULL' do
                  def family
                    find(:all, :conditions => ['friendship_type = ?', 'Family'])
                  end
                  def friends
                    find(:all, :conditions => ['friendship_type = ?', 'Friend'])
                  end
                 end
        
        has_many :pending_friends_for_me,
                 :through => :friendships_for_me,
                 :source => :friendshipped_by_me,
                 :conditions => 'accepted_at IS NULL' do
                  def family
                    find(:all, :conditions => ['friendship_type = ?', 'Family'])
                  end
                  def friends
                    find(:all, :conditions => ['friendship_type = ?', 'Friend'])
                  end
                 end
        
        include HasManyFriends::UserExtensions::InstanceMethods
      end
    end
    
    module InstanceMethods

      # Returns a list of all of a users accepted relationships.
      def relationships
        self.friends_for_me + self.friends_by_me
      end
      
      # Returns a list of all of a users accepted friends.
      def friends
        self.friends_for_me.friends + self.friends_by_me.friends
      end

      # Returns a list of all of a users accepted friends.
      def family
        self.friends_for_me.family + self.friends_by_me.family
      end

      # Returns true if the user has friends or family, false otherwise
      def has_relations?
        return self.relationships.length > 0 ? true : false
      end
      
      # Return a list of all friends who are currently online.
      # This won't return anything unless you passed the :online_method
      # option to has_many_friends.
      def online_friends
        self.friends_by_me.online + self.friends_for_me.online
      end

      # Returns a list of all pending relationships
      def pending_relationships
        self.pending_friends_by_me + self.pending_friends_for_me
      end
      
      # Returns a list of all pending friendships.
      def pending_friends
        self.pending_friends_by_me.friends + self.pending_friends_for_me.friends
      end

      # Returns a list of all pending family.
      def pending_family
        self.pending_friends_by_me.family + self.pending_friends_for_me.family
      end

      # Returns a full list of all pending and accepted relationships.
      def pending_or_accepted_relationships
        self.relationships + self.pending_relationships
      end
      
      # Returns a full list of all pending and accepted friends.
      def pending_or_accepted_friends
        self.friends + self.pending_friends
      end

      # Returns a full list of all pending and accepted family.
      def pending_or_accepted_family
        self.family + self.pending_family
      end
      
      # Accepts a user object and returns the friendship object 
      # associated with both users.
      def friendship(friend)
        Friendship.find(:first, :conditions => ['(user_id = ? AND friend_id = ?) OR (friend_id = ? AND user_id = ?)', self.id, friend.id, self.id, friend.id])
      end
      
      # Accepts a user object and returns true if both users are
      # friends and the friendship has been accepted.
      def is_friends_with?(friend)
        self.friends.include?(friend)
      end

      def is_family_of?(family)
        self.family.include?(family)
      end
      
      # Accepts a user object and returns true if both users are
      # friends or family but the friendship hasn't been accepted yet.
      def has_pending_relationship_with?(friend)
        self.pending_friends.include?(friend)
      end

      # Accepts a user object and returns true if both users are
      # friends but the friendship hasn't been accepted yet.
      def is_pending_friends_with?(friend)
        self.pending_friends.friends.include?(friend)
      end

      # Accepts a user object and returns true if both users are
      # family but the relationship hasn't been accepted yet.
      def is_pending_family_with?(friend)
        self.pending_friends.family.include?(friend)
      end
      
      # Accepts a user object and returns true if both users are
      # friends or family regardless of acceptance.
      def has_relationship_or_pending_with?(friend)
        self.pending_or_accepted_relationships.include?(friend)
      end

      # Accepts a user object and returns true if both users are
      # friends but the friendship hasn't been accepted yet.
      def is_friends_or_pending_with?(friend)
        self.pending_or_accepted_friends.include?(friend)
      end

      # Accepts a user object and returns true if both users are
      # family but the relationship hasn't been accepted yet.
      def is_family_or_pending_with?(friend)
        self.pending_or_accepted_family.include?(friend)
      end
      
      # Accepts a user object and creates a friendship request
      # between both users.
      def request_friendship_with(friend, type='friend')
        Friendship.create!(:friendshipped_by_me => self, 
                           :friendshipped_for_me => friend,
                           :friendship_type => type) unless self.is_friends_or_pending_with?(friend) || self == friend
      end
      
      # Accepts a user object and updates an existing friendship to
      # be accepted.
      def accept_friendship_with(friend)
        self.friendship(friend).update_attribute(:accepted_at, Time.now)
      end
      
      # Accepts a user object and deletes a friendship between both 
      # users.
      def delete_friendship_with(friend)
        self.friendship(friend).destroy if self.has_relationship_or_pending_with?(friend)
      end
      
      # Accepts a user object and creates a friendship between both 
      # users. This method bypasses the request stage and makes both
      # users friends without needing to be accepted.
      def become_friends_with(friend, type='friend')
        unless self.is_friends_with?(friend)
          unless self.is_pending_friends_with?(friend)
            Friendship.create!(:friendshipped_by_me => self, :friendshipped_for_me => friend,
                               :friendship_type => type, :accepted_at => Time.now)
          else
            self.friendship(friend).update_attribute(:accepted_at, Time.now)
          end
        else
          self.friendship(friend)
        end
      end
      
    end  
  end
end
