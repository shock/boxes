module RecentSearches
  extend ActiveSupport::Concern

  included do
    helper_method :recent_searches, :time_sorted_recent_searches
    helper_method :recent_searches=
  end

  def recent_searches_cache_key
    "recent-searches-v5"
  end

  def recent_searches
    recent_searches = Rails.cache.read(recent_searches_cache_key) || {}
    logger.debug("Recent Searches Accessor: #{recent_searches}")
    recent_searches
  end

  def recent_searches=(list)
    logger.debug("Recent Searches Writer: #{list}")
    Rails.cache.write(recent_searches_cache_key, list)
    self.recent_searches
  end

  def time_sorted_recent_searches
    recent_searches.keys.sort do |a,b|
      recent_searches[a]["ts"] <=> recent_searches[b]["ts"]
    end.sort do |a,b|
      recent_searches[a]["count"] <=> recent_searches[b]["count"]
    end.reverse
  end

  def process_recent_searches(query, search_tags)
    max_history = 10
    rs = recent_searches
    if query.present?
      search_params = {
        "query" => query,
        "search_tags" => search_tags
      }
      count = rs[search_params] && rs[search_params]["count"] || 0
      count = count + 1
      att = {
        "count" => count,
        "ts" => Time.now.to_i
      }
      rs[search_params] = att
      if rs.keys.length > max_history
        lowest_count = nil
        oldest_ts = nil
        rs.each do |params, att|
          if lowest_count.nil?
            lowest_count = params
          else
            if att["count"] < rs[lowest_count]["count"]
              lowest_count = params
            end
          end
          if oldest_ts.nil?
            oldest_ts = params
          else
            if att["ts"] > rs[oldest_ts]["ts"]
              oldest_ts = params
            end
          end
        end

        lc = rs[lowest_count] && rs[lowest_count]["count"]
        ot = rs[oldest_ts] && rs[oldest_ts]["ts"]
        if lc
          oldest = rs.keys.select do |e|
            rs[e]["count"] == lc
          end.sort{|a,b|rs[a]["ts"] <=> rs[b]["ts"]}.first
          rs.delete(oldest) if oldest
        else
          rs.delete(oldest_ts) if oldest_ts
        end
      end
      self.recent_searches = rs
    end
  end
end