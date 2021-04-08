# cache the server boot time and use as a cache key - if server is restarted, this will change, busting cache
Rails.application.configure do
  config.cooke_cache_time = Time.now.to_i
end
