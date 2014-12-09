module Profiling

  RAILS_ROOT = File.join( File.dirname(__FILE__), '..' )

  #############################################################
  # Profiling helpers to simplify profiling a block of code
  #
  # Usage:
  #
  #   Greenling.profile_start "#{Rails.root}/tmp/profile.html"
  #     # code to be profiled.
  #   Greenling.profile_stop
  #
  def self.start filename="#{RAILS_ROOT}/public/profile.html"
    require 'ruby-prof'
    @@profile_filename = filename
    RubyProf.start
  end

  def self.stop
    result = RubyProf.stop
    printer = nil
    outfile = nil
    if @@profile_filename
      outfile = File.open(@@profile_filename, 'w')
      printer = RubyProf::GraphHtmlPrinter.new(result)
    else
      outfile = STDOUT
      printer = RubyProf::FlatPrinter.new(result)
    end
    printer.print(outfile)
    outfile.close
  end
  #
  ##############################################################

end