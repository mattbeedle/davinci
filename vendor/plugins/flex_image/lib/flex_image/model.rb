module FlexImage
  GRAVITIES = {
    :center       => Magick::CenterGravity,
    :top          => Magick::NorthGravity,
    :top_right    => Magick::NorthEastGravity,
    :right        => Magick::EastGravity,
    :bottom_right => Magick::SouthEastGravity,
    :bottom       => Magick::SouthGravity,
    :bottom_left  => Magick::SouthWestGravity,
    :left         => Magick::WestGravity,
    :top_left     => Magick::NorthWestGravity,
  } unless defined?(GRAVITIES) 
  
  # Most of the work is done in the model object.  The class methods manipulate global options for all images
  # like what your database binary column is named, or how to process the file on upload.
  # 
  # The instance methods allow you to manipulate the image itself, or its data.  <tt>process!</tt> will perform
  # both a  <tt>resize!</tt> and an <tt>overlay!</tt>, or you can call them explicitly.
  # 
  # After any manipulations you should be able to save the record and the saved image will updated itself in the
  # database.
  # 
  class Model < ActiveRecord::Base
    require 'open-uri'
    
    class InvalidImage < ArgumentError #:nodoc:
    end
    
    self.abstract_class = true
    
    after_destroy :delete_image_from_file_store
    
    dsl_accessor  :require_image_data, 
                  :default => true,
                  :writer => Proc.new { |value| 
                    if [true, false].include?(value)
                      value
                    else
                      raise ArgumentError, "Boolean expected, argument was #{value.class}"
                    end
                  }
    
    dsl_accessor :upload_options
    dsl_accessor :invalid_image_message, :default => 'must be a valid image file, such as JPG, GIF or PNG'
    
    # Allows you to set a custom field name for the binary data column in your database.  Default is +data+.
    # 
    #   class Foo < FlexImage::Model
    #     binary_column :my_wierd_binary_column_name
    #   end
    dsl_accessor  :binary_column, 
                  :default => Proc.new { :data },
                  :writer => Proc.new { |field_name|
                    field_name == field_name.to_sym
                    alias_method field_name, :data
                    alias_method :"#{field_name}=", :data=
                    field_name
                  }
    
    # If you want to store your image on disk rather than the DB, set this attribute to a directory relative to +RAILS_ROOT+.
    # All images files will be pulled from here.  If left to defaults, the binary image data is stored in the database.
    # 
    # *NOTE*:
    # * You still need page caching if you are using the file store.  This is only the path that the master images are
    #   in.  All images that are the result of image procesing actions wil still need to be cached via page caching.
    # 
    # * You do not need to set your file store in your public directory.  Your rails app will read the images
    #   from anywhere in your application structure, process them, and then send them to your browser.
    #   
    #     class ExampleImage < FlexImage::Model
    #       self.file_store = 'public/images/flex_images'
    #       # or even
    #       self.file_store = 'non_public/folder/on/webserver'
    #     end
    dsl_accessor :file_store
    
    # By default the master images are stored as JPG images.  The image is then manipulated and compressed on 
    # the way to the client.  If you want to use a lossless format for your master image, set this to 
    # <tt>:png</tt>, but files will take up much more space.
    #   
    #   class Foo < FlexImage::Model
    #     storage_format :png
    #   end
    dsl_accessor :storage_format, 
      :default => Proc.new { :jpg }, 
      :writer => Proc.new { |value| 
        if [:jpg, :png].include?(value)
          value
        else
          raise ArgumentError, 'storage_format must me :png or :jpg.  :png is default.'
        end
      }
    
    def initialize(*args) #:nodoc:
      @invalid_image = false
      super(*args)
    end
    
    # Defines image transformation done on uploaded images and saves the new records having been processed
    # according to the provided options.
    # 
    # Accepts all of the same options as <tt>process!</tt>.
    # 
    #   class Foo < FlexImage::Model
    #     pre_process_image :size => '1000x1000'
    #   end
    # 
    def self.pre_process_image(options)
      upload_options(options)
    end
    
    # Use this method to define a custom message for an invalid uploaded file.  The default message, which will be used
    # if you leave this out is: "must be a valid image file, such as JPG, GIF or PNG" and is applied to the 'data' field.
    # 
    #   class Foo < FlexImage::Model
    #     validates_image_validity :message => 'was bunk.  You sent me a file that wasn't an image you dummy!'
    #   end
    #   
    def self.validates_image_validity(options = {})
      self.class.invalid_image_message = options[:message] if options.has_key?(:message)
    end
    
    def validate #:nodoc:
      errors.add self.class.binary_column, self.class.invalid_image_message if @invalid_image
    end
    
    # Sets the data field in the database to an uploaded file.  
    #   
    #   image = ExampleImage.new
    #   image.data = params[:image][:data]
    #   
    # Can also be invoked indirectly via:
    # 
    #   ExampleImage.new(:data => params[:image][:data])
    #   ExampleImage.create(:data => params[:image][:data])
    #  
    # or even:
    # 
    #   ExampleImage.new(params[:image])
    #   ExampleImage.create(params[:image])
    # 
    # or from an association:
    # 
    #   p = Product.find(1)
    #   p.images.create(params[:image])
    # 
    # You get the idea.
    # 
    def data=(file)
      file_is_a_url = file =~ %r{^https?://}
      file_is_a_string = file.class == String
      
      if self.class.require_image_data && !file.respond_to?(:read) && !file_is_a_url && !file_is_a_string
        raise InvalidImage, 'Uploaded file contains no binary data.  Be sure that {:multipart => true} is set on your form.'
      end
      
      if file.size > 0
        # Convert a string URL to a file object 
        file = open(file) if file_is_a_url && !file_is_a_string
        
        begin
          # Create RMagick Image object from uploaded file
          if file_is_a_string
            img = Magick::Image.from_blob(file).first
          elsif file.path
            img = Magick::Image.read(file.path).first
          else
            img = Magick::Image.from_blob(file.read).first
          end
          
          # Ensure file RMagick object validity
          raise InvalidImage, 'from_blob method on file returned nil.  Invalid format.' if img.nil?
          
          # Convert to a lossless format for saving the master image
          img.format = self.class.storage_format.to_s.upcase
          
          # Set image quality and save result to record
          self.rmagick_image = img
          
          # Perform image pre-processing
          process! self.class.upload_options if self.class.upload_options
        
        rescue
          # File was not an image, mark for adding validation error
          invalidate_image_field
          
        ensure
          GC.start
        end
      else
        invalidate_image_field if self.class.require_image_data
      end
      
      self[self.class.binary_column]
    end
    
    def [](field_name, *args) #:nodoc:
      if field_name.to_sym == self.class.binary_column.to_sym && self.class.file_store
        @data ||= rmagick_image.to_blob
      else
        super(field_name, *args)
      end
    end
    
    def []=(field_name, value, *args) #:nodoc:
      if field_name.to_sym == self.class.binary_column.to_sym && self.class.file_store 
        @data = value
      else
        super(field_name, value, *args)
      end
    end
    
    # --------------
    # - OPERATIONS -
    # --------------
    
    
    # Process an image.  This method performs a <tt>resize!</tt> and all other effects in one fell swoop.
    # Format options with the resize parameters in the root of the hash and the effect parameters in a key
    # with the effect name.
    # 
    # This method also lets you set a +quality+ which is the amount of compression in the output JPG.  Use a value 
    # from 1 to 100.  100 is a very good image with a large filesize while 1 is a poor image with a very small 
    # filesize.
    #   
    #   image = MyImage.find(1)
    #   image.process! :size => '100x75',
    #                  :crop => true,
    #                  :quality => 90,
    #                  :overlay => {
    #                    :file => 'public/images/overlays/foo.png',
    #                    :alignment => :bottom_right,
    #                  },
    #                  :border => {
    #                    :size => 5,
    #                    :color => 'green'
    #                  },
    #                  :shadow => {
    #                     :blur => 10,
    #                    :offset => 5
    #                  }
    #                 
    def process!(options)
      options = options.symbolize_keys
      
      # order of operations
      operations = [
        :resize,
        :overlay,
        :crop,
        :border,
        :shadow,
      ]
      
      # perform operations
      operations.each do |operation|
        case operation
        when :resize
          resize!(options)                         if options[:size]
        when :crop
          crop!(options[:crop])                    if options[:crop].is_a?(Hash)
        else
          send "#{operation}!", options[operation] if options[operation]
        end
      end
      
      # save processed image to data field as a BLOB
      save_image(options[:quality])
      
      # return self for ! method
      self
    end
    
    # Resize this image.  Use the following options
    #
    # * +size+: size of the output image after the resize operation.  See the :+crop+ option for more details
    #   on exactly how this works.
    #   
    # * +crop+: pass true to this option to make the ouput image exactly 
    #   the same dimensions as <tt>:size</tt>.  The default behaviour will resize the image without
    #   cropping any part meaning the image will be no bigger than the <tt>:size</tt>.  When <tt>:crop</tt>
    #   is non-false the final image is resized to fit as much as possible in the frame, and then crops it 
    #   to make it exactly the dimensions declared by the <tt>:size</tt> parameter.
    #  
    # * +upsample+: By default the image will never display larger than its original dimensions, 
    #   no matter how large the :+size parameter is.  Pass +true+ to use this option to allow
    #   upsampling, disabling the default behaviour.
    #
    # * +padding+: This option will pad the around your image with a solid color to make it exactly the requested
    #   size.  Pass +true+, for the default of +white+, or give it a text or pixel color like <tt>"red"</tt> or 
    #   <tt>color(255, 127, 0)</tt>.  This is like the opposite of the +crop+ option.  Instead of trimming the 
    #   image to make it exactly the requested size, it will make sure the entire image is visible, but adds space 
    #   around the edges to make it the right dimensions.
    #
    # * +stretch+: Set this option to true and the image will not preserve its aspect ratio.  The final image will
    #   stretch to fit the requested +size+.  The resulting image is exactly the size you ask for.
    # 
    # Example:
    # 
    #   image = MyImage.find(1)
    #   image.resize! :size => '100x75',
    #                 :crop => true
    #                  
    def resize!(options)
      options = options.symbolize_keys
      raise ArgumentError,
        ':size or size_string must be inlcuded in resize options' unless options[:size] or options[:size_string]
      
      # load image
      img = rmagick_image
      
      # Find dimensions
      x, y = size_to_xy(options[:size])

      # Custom find dimensions - Matt
      options[:size_string] = options[:size_string].split('.')[0]
      case options[:size_string]
      when 'thumbnail'
        x, y = 100.00, 100.00
      when 'albumcover'
        x, y = 150.00, 150.00
      when 'preview'
        x, y = 500.00, 99999999999999.00
      when 'fullscreen'
        x, y = 900.00, 700.00
      when 'original'
        x, y = self.width, self.height
      end
      
      # prevent upscaling unless :usample param exists.
      unless options[:upsample]
        x = img.columns if x > img.columns
        y = img.rows    if y > img.rows
      end
      
      # Perform image resize
      case
      when options[:crop] && !options[:crop].is_a?(Hash) && img.respond_to?(:crop_resized!)
        # perform resize and crop
        scale_and_crop(img, [x, y])
        
      when options[:stretch]
        # stretch the image, ignoring aspect ratio
        stretch(img, [x, y])
        
      else
        # perform the resize without crop
        scale(img, [x, y])
        
      end
      
      # apply padding if necesary
      if padding_color = options[:padding]
        # get color
        padding_color = 'white' if padding_color == true
        
        # get original x and y.  This makes it play nice if the requested size is larger 
        # than the image and upsampling is not allowed.
        x, y = size_to_xy(options[:size])
        
        # get proper border sizes
        x_border = [0, (x - img.columns + 1) / 2].max
        y_border = [0, (y - img.rows    + 1) / 2].max

        # apply padding
        img.border!(x_border, y_border, padding_color)
        
        # crop to remove possible extra pixel
        img.crop!(0, 0, x, y, true)
      end
      
      #save changes
      self.rmagick_image = img
      
      # warn about old RMagick version
      if options[:crop] && !options[:crop].is_a?(Hash) && !img.respond_to?(:crop_resized!)
        logger.warn 'WARNING :: FlexImage :: Your version of RMagick does not support the "crop_resized!" method.  Upgrade RMagick to get this functionality.'
      end
      
      self
    end
    
    # Adds an overlay to the base image.  It's useful for things like attaching a logo,
    # watermark, or even a border to the image.  It will work best with a 24-bit PNG with
    # alpha channel since it will properly deal with partial transparency.
    # 
    # It accepts the following options:
    # 
    # * +file+: *REQUIRED*. This is a path, from your application root, to the file you want 
    #   to overlay.
    # 
    # * +size+: The size of the overlayed image, in FlexImage *size* format.  
    #   By default the overlay is not resized before compositing.
    #   Use this options if you want to resize the overlay, perhaps to have a small
    #   logo on thumbnails and a big logo on full size images.  The size parameter takes 2 special
    #   values :+scale_to_fit+ and :+stretch_to_fit+.  :+scale_to_fit+ will make the overlay fit as 
    #   much as it can inside the image without changing the aspect ratio.  :+stretch_to_fit+
    #   will make the overlay the exact same size as the image but with a distorted aspect ratio to make
    #   it fit.  :+stretch_to_fit+ is designed to add border to images.
    # 
    # * +alignment+: A symbol that tells FlexImage where to put the overlay.  Can be any of the following:
    #   <tt>:center, :top, :top_right, :right, :bottom_right, :bottom, :bottom_left, :left, :top_left</tt>.
    #   Default is :+center+
    # 
    # * +offset+: the number of pixels to offset the overlay from it's :+alignment+ anchor, in FlexImage 
    #   *size* format.  Useful to give a bit a space between your logo and the edge of the image, for instance.
    #   *NOTE:* Due to some unexpected (buggy?) RMagick behaviour :+offset+ will work strangely
    #   if :+alignment+ is set to a corner non-corner value, such as :+top+ or :+center+.  Using :+offset+ in
    #   these cases will force the overlay into a corner anyway.
    # 
    # * +blending+: The blending mode governs how the overlay gets composited onto the image.  You can 
    #   get some funky effects with modes like :+copy_cyan+ or :+screen+.  For a full list of blending
    #   modes checkout the RMagick documentation (http://www.simplesystems.org/RMagick/doc/constants.html#CompositeOperator).
    #   To use a blend mode remove the +CompositeOp+ form the name and "unserscorize" the rest.  For instance,
    #   +MultiplyCompositeOp+ becomes :+multiply+, and +CopyBlackCompositeOp+ becomes :+copy_black+.
    #
    # Example:
    # 
    #     image = MyImage.find(1)
    #     image.overlay!(
    #       :file      => 'path/to/image.png',
    #       :size      => '25x25',
    #       :alignment => :top_right 
    #     )
    #     
    def overlay!(options)
      # If the owner does not have pro privileges, they cannot add an overlay
      return self unless self.album.user.has_role? 'pro'

      options = options.symbolize_keys
      raise ArgumentError, ':file (a path to a valid image file) or :image (an rmagick image) must be included in overlay options.' unless options[:file] || options[:image] 
      
      #load image
      img = rmagick_image
      
      #load overlay
      if options[:file]
        overlay = Magick::Image.read(options[:file]).first
      else
        overlay = options[:image]
      end
      
      #resize overlay
      if options[:size]
        if options[:size].is_a?(String) || options[:size].is_a?(Fixnum)
          x, y = size_to_xy(options[:size])
        elsif options[:size] == :scale_to_fit || options[:size] == :stretch_to_fit
          x, y = img.columns, img.rows
        end
        
        method = options[:size] == :stretch_to_fit ? :stretch : :scale
        send(method, overlay, [x, y])
      end
      
      #prepare arguments for composite!
      args = []
      args << overlay                                               #overlay image
      args << FlexImage::GRAVITIES[options[:alignment] || :center]  #gravity
      args += size_to_xy(options[:offset]) if options[:offset]      #offset
      args << symbol_to_blending_mode(options[:blending] || :over)  #compositing mode
      
      #composite
      img.composite!(*args)
      
      #save changes
      self.rmagick_image = img
      self
    end
    
    # Add a border to the outside of the image
    # 
    # * +size+: Width of the border on each side.  You can use a 2 dimensional value ('5x10') if you want
    #   different widths for the sides and top borders, but a single integer will aply the same border on 
    #   all sides.
    #   
    # * +color+: the color of the border. Use an RMagick named color or use the +color+ method in 
    #   FlexImage::Controller, or a Magick::Pixel object.
    #   
    # This example shows usage and the default settings.
    # 
    #     image.border!(
    #       :size  => 10,
    #       :color => 'white'    # or color(255, 255, 255)
    #     )
    #   
    def border!(options = {})
      options = options.symbolize_keys if options.respond_to?(:symbolize_keys)
      defaults = {
        :size => '10',
        :color => 'white'
      }
      options = options.is_a?(Hash) ? defaults.update(options) : defaults
      
      options[:size] = size_to_xy(options[:size])
      
      # load image
      image = rmagick_image
      
      # apply border
      image.border!(options[:size][0], options[:size][1], options[:color])
      
      # save image
      self.rmagick_image = image
      self
    end 
    
    # Add a drop shadow to the image.
    # 
    # * +offset+: distance of the dropsahdow form the image, in FlexImage *size* format.  Positive
    #   number move it down and right, negative numbers move it up and left.
    #   
    # * +blur+: how blurry the shadow is.  Roughly corresponds to distance in pixels of the blur.
    # 
    # * +background+: a color for the background of the image.  What the shadow fades into.  
    #   Use an RMagick named color or use the +color+ method in FlexImage::Controller, or a
    #   Magick::Pixel object.
    #   
    # * +color+: color of the shadow itself.
    #   Use an RMagick named color or use the +color+ method in FlexImage::Controller, or a
    #   Magick::Pixel object.
    #   
    # * +opacity+: opacity of the shadow.  A value between 0.0 and 1.0, where 1 is opaqe and 0 is
    #   transparent.
    # 
    # This example shows usage and the default settings.
    # 
    #     image.shadow!(
    #       :color      => 'black',    # or color(0, 0, 0)
    #       :background => 'white',    # or color(255, 255, 255)
    #       :blur       => 8,
    #       :offset     => '2x2',
    #       :opacity    => 0.75 
    #     )
    def shadow!(options = {})
      options = options.symbolize_keys if options.respond_to?(:symbolize_keys)
      defaults = {
        :offset     => 2,
        :blur       => 8,
        :background => 'white',
        :color      => 'black',
        :opacity    => 0.75
      }
      options = options.is_a?(Hash) ? defaults.update(options) : defaults
      
      # verify options
      options[:offset] = size_to_xy(options[:offset])
      options[:blur]   = options[:blur].to_i
      
      options[:background]    = Magick::Pixel.from_color(options[:background]) unless options[:background].is_a?(Magick::Pixel)
      options[:color]         = Magick::Pixel.from_color(options[:color])      unless options[:color].is_a?(Magick::Pixel)
      options[:color].opacity = (1 - options[:opacity]) * 255
      
      # load image
      image = rmagick_image
      
      # generate shadow image
      shadow = image.dup
      shadow.background_color = options[:color]
      shadow.erase!
      shadow.border!(options[:offset].max + options[:blur] * 3, options[:offset].max + options[:blur] * 3, options[:background])
      shadow = shadow.blur_image(0, options[:blur] / 2)
      
      # apply shadow
      image = shadow.composite(
        image, 
        FlexImage::GRAVITIES[:top_left], 
        (shadow.columns - image.columns) / 2 - options[:offset][0], 
        (shadow.rows    - image.rows)    / 2 - options[:offset][1], 
        symbol_to_blending_mode(:over)
      )
      image.trim!
      
      # save
      self.rmagick_image = image
      self
    end
    
    # Crops the image without doing any resizing first.  The operation crops from the :+from+ coordinate,
    # and returns an image of size :+size+ down and right from there.
    # 
    # * +from+: coorinates in the standard *size* format for the upper left corner of resulting image.
    # * +size+: The size of the resulting image, going down and to the left of :+from+.
    # 
    #     image.crop!(
    #       :from => '100x50',
    #       :size => '500x350'
    #     )
    #     
    def crop!(options)
      options = options.symbolize_keys
      
      # required integer keys
      [:from, :size].each do |key|
        raise ArgumentError, ":#{key} must be included in crop! options" unless options[key]
        options[key] = size_to_xy(options[key])
      end
      
      # width and height must not be zero
      options[:size].each do |dimension|
        raise ArgumentError, ":size must not be zero for X or Y, or there would be no image left!" if dimension.zero?
      end
      
      # load image
      img = rmagick_image
      
      # crop
      img.crop!(options[:from][0], options[:from][1], options[:size][0], options[:size][1], true)
      
      # save changes
      self.rmagick_image = img
      self
    end
    
    # Better description coming sometime soon...
    # 
    # options:
    # 
    # * alignment: symbol like in <tt>overlay!</tt>
    # * position: size string
    # * antialias: boolean
    # * color: string or <tt>color(r, g, b)</tt>
    # * font_size: integer
    # * font: path to a font file relative to +RAILS_ROOT+
    # * rotate: integer
    # * shadow: <tt>{:blur => 1, :opacity => 1.0}</tt>
    #  
    def text!(string_to_write, options = {})
      options = {
        :alignment  => :top_left,
        :position   => '0x0',
        :antialias  => true,
        :color      => 'black',
        :font_size  => '12',
        :font       => nil,
        :text_align => :left,
        :rotate     => 0,
        :shadow     => nil,
      }.merge(options)
      options[:position] = size_to_xy(options[:position])
      
      image = rmagick_image
      
      # prepare drawing surface
      text                = Magick::Draw.new
      text.gravity        = FlexImage::GRAVITIES[options[:alignment]]
      text.fill           = options[:color]
      text.text_antialias = options[:antialias]
      text.pointsize      = options[:font_size].to_i
      text.rotation       = options[:rotate]
      
      # assign font path with to rails root unless the path is absolute
      if options[:font]
        font = options[:font]
        font = "#{RAILS_ROOT}/#{font}" unless font =~ %r{^(~?|[A-Za-z]:)/}
        text.font = font
      end
      
      # draw text on transparent image
      temp_image = Magick::Image.new(image.columns, image.rows) { self.background_color = Magick::Pixel.new(0, 0, 0, 255) }
      temp_image = temp_image.annotate(text, 0, 0, options[:position][0], options[:position][1], string_to_write)
      
      # add drop shadow to text image
      if options[:shadow]
        shadow_args = [2, 2, 1, 1]
        if options[:shadow].is_a?(Hash)
          #shadow_args[0], shadow_args[1] = size_to_xy(options[:shadow][:offset]) if options[:shadow][:offset]
          shadow_args[2] = options[:shadow][:blur]                               if options[:shadow][:blur]
          shadow_args[3] = options[:shadow][:opacity]                            if options[:shadow][:opacity]
        end
        shadow = temp_image.shadow(*shadow_args)
        temp_image = shadow.composite(temp_image, 0, 0, symbol_to_blending_mode(:over))
      end
      
      # composite text on original image
      image.composite!(temp_image, 0, 0, symbol_to_blending_mode(:over))
      
      # save changes
      self.rmagick_image = image
      self
    end
    
    # Trim off all the pixels around the image border that have the same color.
    def trim!
      # load image
      image = rmagick_image
      
      # trim image
      image.trim!
      
      # save
      self.rmagick_image = image
      self
    end
    
    # Sharpen an image using an unsharp mask filter
    def unsharp_mask!(options = {})
    
      options = {
        :radius    => 0.0,
        :sigma     => 1.0,
        :amount    => 0.5,
        :threshold => 0.05
      }.merge(options)
      
      # load image
      image = rmagick_image
      
      # sharpen image
      image = image.unsharp_mask(options[:radius], options[:sigma], options[:amount], options[:threshold])
      
      # save
      self.rmagick_image = image
      self
    end
    
    # The path the master image file for this record.  Obviously this is only relevant
    # if you are using the file_store instead of the database storage.
    # 
    #   MyImage.find(123).file_path
    #   #=> "/var/www/my_app/public/flex_images/123.jpg"
    #    
    def file_path
      suffix = '_test' if ENV['RAILS_ENV'].to_s.downcase == 'test'
      "#{RAILS_ROOT}/#{self.class.file_store}/#{id}#{suffix}.#{self.class.storage_format.to_s.downcase}"
    end
    
    def to_jpg!(quality = nil)
      rmagick_image.format = 'JPG'
      
      # TODO: GraphicsMagick does not support this method. Figure out a way to run it conditionally.
      #rmagick_image.strip!
      
      save_image(quality)
    end

      def sepia!(threshold=80)
        return self if threshold.nil? or threshold.to_i == 0

        image = rmagick_image

        image = image.sepiatone(threshold.to_f)
                                
        self.rmagick_image = image
        self
      end

      def solarize!(threshold=50)
        return self if threshold.nil? or threshold.to_i == 0

        image = rmagick_image

        image = image.solarize(threshold.to_f)

        self.rmagick_image = image
        self
      end

      def quantize!(colors=256, colorspace='grey')
        return self if colors.nil? or colors.to_i == 0

        image = rmagick_image

        case colorspace.upcase
        when 'RGB'
          image = image.quantize(colors.to_i, Magick::RGBColorspace)
        when 'YUV'
          image = image.quantize(colors.to_i, Magick::YUVColorspace)
        else
          image = image.quantize(colors.to_i, Magick::GRAYColorspace)
        end

        self.rmagick_image = image
        self
      end

      def posterize!(levels=4)
        return self if levels.nil? or levels.to_i == 0 or levels.to_i == 1

        image = rmagick_image

        image = image.posterize(levels.to_i)

        self.rmagick_image = image
        self
      end

      def charcoal!(radius=0.0, sigma=1.0)
        return self if radius.nil? or radius.to_i == 0 or sigma.nil? or sigma.to_i == 0

        image = rmagick_image

        image = image.charcoal(radius.to_f, sigma.to_f)

        self.rmagick_image = image
        self
      end

      def despeckle!
        image = rmagick_image

        image = image.despeckle

        self.rmagick_image = image
        self
      end

      def enhance!
        image = rmagick_image

        image = image.enhance

        self.rmagick_image = image
        self
      end

      def modulate!(brightness=1.0, saturation=1.0, hue=1.0)
        image = rmagick_image

        image = image.modulate(brightness.to_f, saturation.to_f, hue.to_f)

        self.rmagick_image = image
        self
      end

      def oil_paint!(radius=3.0)
        return self if radius.to_i == 1
        image = rmagick_image

        image = image.oil_paint(radius.to_f)

        self.rmagick_image = image
        self
      end

      def negate!(greyscale=true)
        image = rmagick_image

        image = image.negate(greyscale)

        self.rmagick_image = image
        self
      end
          
    after_save :write_image_to_disk
    
    private
      
      def write_image_to_disk
        rmagick_image.write(file_path) if @rmagick_image && self.class.file_store  
      end
      
      def size_to_xy(size)
        if size.is_a?(Array) && size.size == 2
          size
        elsif size.to_s.include?('x')
          size.split('x').collect(&:to_i)
        else
          [size.to_i, size.to_i]
        end
      end
      
      def save_image(quality = nil)
        blob = quality ? rmagick_image.to_blob { self.quality = quality.to_i } : rmagick_image.to_blob
        if self.class.file_store
          @data = blob
        else
          self[self.class.binary_column] = blob 
        end
        GC.start
      end
      
      def rmagick_image
        return @rmagick_image if @rmagick_image
        
        if self.class.file_store
          @rmagick_image = Magick::Image.read(file_path).first
        else
          @rmagick_image = Magick::Image.from_blob(self[self.class.binary_column]).first
        end
      end
      
      def rmagick_image=(new_image)
        @rmagick_image = new_image
        save_image
        @rmagick_image
      end
      
      def scale(img, size)
        img.change_geometry!(size_to_xy(size).join('x')) do |cols, rows, _img|
          cols = 1 if cols < 1
          rows = 1 if rows < 1
          _img.resize!(cols, rows)
        end
      end
      
      def scale_and_crop(img, size)
        img.crop_resized!(*size_to_xy(size))
      end
      
      def stretch(img, size)
        img.resize!(*size_to_xy(size))
      end
      
      def symbol_to_blending_mode(mode)
        "Magick::#{mode.to_s.camelize}CompositeOp".constantize
      rescue NameError
        raise ArgumentError, ":#{mode} is not a valid blending mode."
      end
      
      def invalidate_image_field
      	self[self.class.binary_column] = 'Invalid Image'
        @invalid_image = true
      end
      
      def delete_image_from_file_store
        File.delete(file_path) if self.class.file_store && File.exists?(file_path)
      end
  end # Model
end # FlexImage
