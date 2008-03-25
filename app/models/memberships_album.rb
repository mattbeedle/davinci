class MembershipsAlbum < ActiveRecord::Base
  belongs_to :membership
  belongs_to :album
end
