class Photo < FlexImage::Model
  #file_store 'path/to/my/image/storage/directory'
  storage_format :png
  
  validates_uniqueness_of :permalink, :scope => :album_id

  belongs_to :album
  belongs_to :user
  has_many :comments

  acts_as_geocodable
  acts_as_versioned
  acts_as_taggable

  def extension
    self.content_type.split('/')[0]
  end

  def before_save
    self.permalink = self.original_filename.split('.')[0].gsub(/\s/, '-')
    image = Magick::Image.from_blob(self.data).first
    self.height = image.rows
    self.width = image.columns
  end

  def to_param
    self.permalink
  end

  def get_exif_by_entry(entry)
    image = Magick::Image.from_blob(self.data).first
    exif = image.get_exif_by_entry(entry)
    GC.start
    exif[1]
  end

  def save_with_protection
    self.remove_pro_attributes unless self.album.user.has_role? 'pro'
    self.remove_power_attributes unless self.album.user.has_role? 'power'
    self.save_without_protection
  end

  alias_method_chain :save, :protection

  def save_with_protection!
    self.remove_pro_attributes unless self.album.user.has_role? 'pro'
    self.remove_power_attributes unless self.album.user.has_role? 'power'
    self.save_without_protection!
  end

  alias_method_chain :save!, :protection

  def remove_power_attributes
  end

  def remove_pro_attributes
    self.price = nil
  end
end
