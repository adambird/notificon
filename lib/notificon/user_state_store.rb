# Private: Datamapper for Notification object
module Notificon
  class UserStateStore
    include MongoStore
    
    set_collection_name :notificon_user_state
    set_indexes [
      [['username']]
    ]
    
    def get(username)
      if item_hash = collection.find_one('username' => username)
        UserState.new(item_hash)
      end
    end
    
    def set_notifications(username, notifications)
      collection.update({'username' => username}, { '$set' => { 'notifications' => notifications }}, { :upsert => true } )
    end
    
    def clear_notifications(username)
      collection.update({'username' => username}, { '$set' => { 'notifications' => 0 } }, { :upsert => true })
    end
  end
end