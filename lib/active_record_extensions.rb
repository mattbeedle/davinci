module ActiveRecordExtensions
  module Base
    def self.included(base)
      base.class_eval do
        alias_method_chain :to_xml, :safety
      end
    end

    def to_xml_with_safety(options = {})
      # protect attributes registered with attr_protected
      default_except = self.class.protected_attributes()
      options[:except] = (options[:except] ? options[:except] + (default_except || []) : default_except)
      to_xml_without_safety(options)
    end
  end
end
