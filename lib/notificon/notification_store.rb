# Private: Datamapper for Notification object
module Notificon
  class NotificationStore
    include MongoStore
    
    set_collection_name :notificon_notifications
    set_indexes [
      [['username'], ['occured_at', Mongo::DESCENDING]]
    ]
    
    def add(notification)
      collection.insert('username' => notification.username, 'item_url' => notification.item_url, 
        'item_text' => notification.item_text, 'actor' => notification.actor, 'action' => notification.action,
        'occured_at' => notification.occured_at && notification.occured_at.utc).to_s
    end
    
    def get(id)
      if item_hash = collection.find_one('_id' => BSON::ObjectId.from_string(id))
        Notification.new(item_hash)
      end
    end
    
    def get_for_user(username, limit)
      collection.find({'username' => username}, { :limit => limit, :sort => [['occured_at', :descending]]}).collect { |item_hash|
          Notification.new(item_hash)
        }
    end
    
    def unread_count_for_user(username)
      collection.count(:query => {'username' => username, 'read_at' => { '$exists' => false }})
    end
    
    def mark_as_read(id, read_at)
      collection.update({'_id' => BSON::ObjectId.from_string(id)}, { '$set' => { 'read_at' => read_at.utc } })
      get(id)
    end
    
    def mark_all_read_for_user(username, read_at)
      collection.update({'username' => username, 'read_at' => { '$exists' => false } }, { '$set' => { 'read_at' => read_at.utc}}, { :multi => true})
    end

  end
end