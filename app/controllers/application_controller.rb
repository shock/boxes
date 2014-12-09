require 'profiling'

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  around_filter :profile_request

  def profile_request
    unless rp = params[:_rp].present?
      yield
      return
    end
    if rp
      logger.info("Ruby Profiling started")
      Profiling.start
    end
    yield
    if rp
      Profiling.stop
      logger.info("Ruby Profiling stopped")
    end
  end
end
