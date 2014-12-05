# Helper concern for managing a hstore column in an ActiveRecord model with accessors.  It expects
# for the model to have an hstore column named `properties`.

require 'hash_obj'
module HstorePropertiesConcern
  extend ActiveSupport::Concern

  included do
    cattr_accessor :hstore_data_options
    self.hstore_data_options = {}

    before_save :process_hstore_attrs
  end

  module ClassMethods
    def hstore_attr(attr_name, options={})
      reader_method = attr_name
      writer_method = "#{attr_name}="

      define_method(reader_method) do
        if hstore_data.has_key?(reader_method)
          return hstore_data.send(reader_method)
        else
          default = options[:default]
          default = default.call if default.is_a?(Proc)
          hstore_data[attr_name] = default
          return default
        end
      end

      define_method(writer_method) do |value|
        # attribute_will_change!(attr_name)
        data = self.hstore_data
        data.send(writer_method, value)
        self.hstore_data = data
      end
    end
  end

  #  ====================
  #  = Instance Methods =
  #  ====================

  def hstore_data(options={})
    @hstore_data ||= begin
      HashObj.new(self.properties || {})
    end
  end

  def hstore_data=(hstore_data)
    @hstore_data = HashObj.new(hstore_data)
  end

private

  def process_hstore_attrs
    hstore_data = self.hstore_data()
    hstore_data.keys.each {|k| hstore_data.delete(k) if hstore_data[k].nil?}
    hstore_data = hstore_data.deep_sort if self.class.hstore_data_options[:deep_sort]
    self.properties = hstore_data
    true
  end

end