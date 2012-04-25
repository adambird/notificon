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
    
    def increment_notifications(username)
      change_notifications(username, 1)
    end
    
    def decrement_notifications(username)
      change_notifications(username, -1)
    end
    
    def change_notifications(username, delta)
      collection.update({'username' => username}, { '$inc' => { 'notifications' => delta } }, { :upsert => true })
    end
    
    def clear_notifications(username)
      collection.update({'username' => username}, { '$set' => { 'notifications' => 0 } }, { :upsert => true })
    end
  end
end