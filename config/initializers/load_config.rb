APP_CONFIG = YAML.load_file("#{RAILS_ROOT}/config/config.yml")[RAILS_ENV]

ActiveRecord::Base.send(:include, ActiveRecordExtensions::Base)
