require 'profiling'

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include RecentSearches

  include Raj::JsonHelper
  include Raj::ControllerConcern

  before_filter :update_client_json
  around_filter :profile_request

private

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

  def update_client_json
    update_raj_json(
      :load_modal => session.delete(:load_modal),
      :tags => Tag.all.inject({}) do |hash, tag|
        hash[tag.id] = tag.name
        hash
      end

    )
  end
end
