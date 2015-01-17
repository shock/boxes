require "raj/engine"
require "raj/controller_concern"

module Raj
  mattr_accessor :app_name
  mattr_accessor :log_json_responses
  self.log_json_responses = false
  self.app_name = "RAJ"
end
