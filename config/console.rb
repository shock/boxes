# Code we only want to run when in the Rails console.

# In rails3, this file is required by overriding the initialize_console method of the
# Rails application in application.rb

require 'hirb'

silence_warnings { Object.const_set( "RAILS_CONSOLE", true ) }
puts "Initializing Boxes Rails console."

# Set the acts_as_audited user so we can track changes made from the console.
Thread.current[:acts_as_audited_user] = "Rails 2 Console"
Thread.current[:audited_user] = "Rails 3 Console"

module BoxesConsoleHelpers
  def self.simple_time(time)
    if time.is_a?(Time)
      time.strftime("%Y-%m-%d %H:%M:%S")
    else
      time.strftime("%Y-%m-%d")
    end
  end


  module ActiveRecord
    extend ActiveSupport::Concern

    module ClassMethods
      def [](id)
        find(id)
      end
    end

    def to_s
      output = []
      self.attributes.sort{|a,b|a.first <=> b.first}.each do |a|
        output << "#{'%30s' % a.first}: #{a.last}"
      end
      output * "\n"
    end

    # General Hirb Helper methods
    def created; BoxesConsoleHelpers.simple_time(created_at) rescue "nil"; end
    def updated; BoxesConsoleHelpers.simple_time(updated_at) rescue "nil"; end
  end

end

class Object
  def self.descendants
    ObjectSpace.each_object(Class).select { |klass| klass < self }
  end

  def load_url_writers(admin=true)
    unless Object.respond_to?(:default_url_options)
      if RAILS3
        Object.send(:include, Rails.application.routes.url_helpers)
      else
        Object.send(:include, ActionController::UrlWriter)
      end
    end
    case admin
    when true
      host = ADMIN_HOST.split('://').last
      protocol = ADMIN_HOST.split('://').first
    else
      host = HOST
      protocol = 'http'
    end
    Object.default_url_options = {
      :host => host,
      :protocol => protocol
    }
  end

  # Hirb Printer shortcut
  def hp(*args)
    puts Hirb::Helpers::AutoTable.render(*args)
  end

  # Hirb resizer and helper reloader shortcut
  def hr
    Hirb::View.resize

    ActiveRecord::Base.send(:include, BoxesConsoleHelpers::ActiveRecord)

    silence_warnings {
      # Shortcut aliases for common AR classes
      Object.const_set "T", Thing
    }
    true
  end

  def hirb_off
    Hirb.enable :pager=>false
    Hirb.enable :formatter=>false
  end

  def hirb_on
    Hirb.enable :pager=>true
    Hirb.enable :formatter=>true
  end

  def reload
    ActionDispatch::Reloader.cleanup!
    ActionDispatch::Reloader.prepare!
    hr
    true
  end

end

hirb_on
hr unless Rails.env.test?

require 'pry'
