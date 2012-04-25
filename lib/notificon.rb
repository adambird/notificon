module Notificon
  require "notificon/notification"
  require "notificon/mongo_store"
  require "notificon/notification_store"
  require "notificon/controller"
  
  class << self
    def setup
      yield self
    end
    
    def notification_id_param
      @_notification_id_param ||= '_notificon_id'
    end

    def notification_id_param=(value)
      @_notification_id_param = value
    end
    
    def connection_profile
      @_connection_profile ||= "mongodb://localhost/notificon_default"
    end

    def connection_profile=(value)
      @_connection_profile = value
    end
    
    def log_level
      @_log_level ||= Logger::INFO
    end
    
    def log_level=(value)
      @_log_level = value
    end
    
    def logger
      @_logger ||= build_logger
    end
    
    def logger=(value)
      @_logger = value
    end
    
    # Mark a notification as read
    # 
    # @param [String] id of the notifcation to mark as read
    # @param [Time] time the item was read
    def mark_notification_read(id, read_at)
      raise ArgumentError.new("id must be a String") unless id.is_a? String
      raise ArgumentError.new("read_at must be a Time") unless read_at.is_a? Time
      
      notification_store.mark_as_read(id, read_at)
    end
    
    # Add a notification to the users lists
    # 
    # @param [String] username for whom the notification is for
    # @param [String] item_url the url of the item on which the actor performed the action
    # @param [String] item_text the text that describes the item
    # @param [String] actor the username of the user that performed the action
    # @param [Symbol] action the action that the actor performed
    # @param [Time] occured_at when the action was performed
    def add_notification(username, item_url, item_text, actor, action, occured_at)
      raise ArgumentError.new("username must be a String") unless username.is_a? String
      raise ArgumentError.new("item_url must be a String") unless item_url.is_a? String
      raise ArgumentError.new("item_text must be a String") unless item_text.is_a? String
      raise ArgumentError.new("actor must be a String") unless actor.is_a? String
      raise ArgumentError.new("action must be a Symbol") unless action.is_a? Symbol
      raise ArgumentError.new("occured_at must be a Time") unless occured_at .is_a? Time

      notification_store.add(Notification.new(:username => username, :item_url => item_url, 
        :item_text => item_text, :actor => actor, :action => action, :occured_at => occured_at))
    end
    
    # Get the latest notifications for a given user
    # 
    # @param [String] username for whom the notifications are for
    # @param [Fixnum, 100] limit the number of records to return
    def get_notifications(username, limit=100)
      notification_store.get_for_user(username, limit)
    end
    
    private 
    
      def build_logger
        logger = Logger.new(STDOUT)
        logger.progname = "Notificon"
        logger.level = Notificon.log_level
        logger
      end
      
      def notification_store
        @_notification_store ||= NotificationStore.new
      end
    
  end
end