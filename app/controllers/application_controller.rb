require 'profiling'

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include Raj::JsonHelper
  include Raj::ControllerConcern

  before_filter :update_client_json
  before_filter :init_recent_searches
  around_filter :profile_request

  def recent_searches_cache_key
    "recent-searches"
  end

  def recent_searches
    recent_searches = Rails.cache.read(recent_searches_cache_key) || []
    logger.debug("Recent Searches Accessor: #{recent_searches}")
    recent_searches
  end
  helper_method :recent_searches

  def recent_searches=(list)
    logger.debug("Recent Searches Writer: #{list}")
    Rails.cache.write(recent_searches_cache_key, list)
    self.recent_searches
  end
  helper_method :recent_searches=

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

  def init_recent_searches
    self.recent_searches ||= []
  end
end
