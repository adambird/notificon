# Private: wrapper for the assigned cache
#
module Notificon
  module Cache

    def cache_enabled?
      Notificon.cache
    end

    def cache_fetch(key)
      if cache_enabled?
        Notificon.cache.fetch("notificon_#{key}") { yield }
      else
        yield
      end
    end

    def cache_delete(key)
      Notificon.cache.delete("notificon_#{key}") if cache_enabled?
    end
  end

end