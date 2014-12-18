require "raj/engine"
require "raj/controller_concern"

module Raj
  mattr_accessor :app_name
  self.app_name = "RAJ"
end
