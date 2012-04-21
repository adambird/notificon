# Datamapper for Notification object

module Notificon
  class NotificationStore
    include MongoStore
    
    set_collection_name :notificon_notifications
    set_indexes [
      [['username'], ['occured_at', Mongo::DESCENDING]]
    ]
    
    def add(notification)
      collection.insert('username' => notification.username, 'item_url' => notification.item_url, 
        'text' => notification.text, 'occured_at' => notification.occured_at && notification.occured_at.utc).to_s
    end
    
    def get(id)
      if item_hash = collection.find_one('_id' => BSON::ObjectId.from_string(id))
        Notification.new(item_hash)
      end
    end
    
    def get_for_user(username, limit=100)
      collection.find({'username' => username}, { :limit => limit, :sort => [['occured_at', :descending]]}).collect { |item_hash|
          Notification.new(item_hash)
        }
    end
    
    def mark_as_read(id, read_at)
      collection.update({'_id' => BSON::ObjectId.from_string(id)}, { '$set' => { 'read_at' => read_at.utc } })
    end
  end
end