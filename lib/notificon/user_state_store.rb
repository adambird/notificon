# Private: Datamapper for Notification object
module Notificon
  class UserStateStore
    include MongoStore
    include Cache

    set_collection_name :notificon_user_state
    set_indexes [
      [['username']]
    ]

    def get(username)
      if item_hash = cache_fetch("user_state_#{username}") { collection.find_one('username' => username) }
        UserState.new(item_hash)
      end
    end

    def set_notifications(username, notifications)
      collection.update({'username' => username}, { '$set' => { 'notifications' => notifications }}, { :upsert => true } )
      delete_cached(username)
    end

    def clear_notifications(username)
      collection.update({'username' => username}, { '$set' => { 'notifications' => 0 } }, { :upsert => true })
      delete_cached(username)
    end

    def delete_cached(username)
      cache_delete("user_state_#{username}")
    end
  end
end