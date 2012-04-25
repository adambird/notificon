# Public: Api for the Notificon gem for tracking notifications for users
#
# Examples
#
#   Notificon.add_notification('sam', 'http://company.com/items/audha,
#     'Item title', 'bill', :commented, Time.now)
#   
module Notificon
  require "notificon/notification"
  require "notificon/mongo_store"
  require "notificon/notification_store"
  require "notificon/controller"
  
  class << self
    # Public: accessor method used to config the gem
    # 
    # Yields the Notificon module 
    # 
    # Examples
    # 
    #  Notificon.setup do |config|
    #    config.connection_profile = 'mongo://myserver/notifications'
    #  end
    # 
    # Returns nothing
    def setup
      yield self
    end
    
    # Public: Returns the query string parameter used to identify the notification.
    #   defaults to '_notificon_id' if not set
    def notification_id_param
      @_notification_id_param ||= '_notificon_id'
    end

    # Public: Sets the String to use for the notification_id_param
    def notification_id_param=(value)
      @_notification_id_param = value
    end
    
    # Public: Returns the connection profile for the datastore. Currently only mongo
    #   supported. Defaults to mongodb://localhost/notificon_default if not set
    def connection_profile
      @_connection_profile ||= "mongodb://localhost/notificon_default"
    end

    # Public: Sets the String for the connection_profile
    def connection_profile=(value)
      raise ArgumentError.new("value must a string or nil") unless id id.is_a? String
      
      @_connection_profile = value
    end
    
    # Public: Returns the Logger currently enabled for the gem
    #   If none specified, will create one pointing at STDOUT
    #
    # Returns the Logger currently configured   
    def logger
      @_logger ||= build_logger
    end
    
    # Public: Setter for the Logger for the gem to use. Allows host system
    #   loggers to be inject, eg Rails.logger
    # 
    # value     - The Logger to use
    # 
    # Returns the assigned Logger
    def logger=(value)
      raise ArgumentError.new("value must be a Logger") unless id.is_a? Logger
      
      @_logger = value
    end
    
    # Public: Mark a notification as read
    #
    # id        - The String identifying the notification
    # read_at   - The Time the notitication was read
    #
    # Returns nothing
    def mark_notification_read(id, read_at)
      raise ArgumentError.new("id must be a String") unless id.is_a? String
      raise ArgumentError.new("read_at must be a Time") unless read_at.is_a? Time
      
      notification_store.mark_as_read(id, read_at)
    end
    
    # Public: Add a notification to the users lists
    #
    # username   - The String identifying the user being notified
    # item_url   - A String url of the item notification relates to
    # item_text  - A String that describes the item
    # actor      - The String identifying the user that performed the action
    # action     - A Symbol representing the action that the actor performed
    # occured_at - The Time the action was performed
    #
    # Returns the String id of the Notification generated
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
    
    # Public: Retrieve the most recent Notifications for user
    #
    # username   - The String identifying the user
    # limit      - The Fixnum maximum number of items to return (default: 100)
    #
    # Returns Enumerable list of Notification elements
    def get_notifications(username, limit=100)
      raise ArgumentError.new("username must be a String") unless username.is_a? String
      raise ArgumentError.new("limit must be a Fixnum") unless limit.is_a? Fixnum
       
      notification_store.get_for_user(username, limit)
    end
    
    private 
    
      def build_logger
        logger = Logger.new(STDOUT)
        logger.progname = "Notificon"
        logger
      end
      
      def notification_store
        @_notification_store ||= NotificationStore.new
      end
    
  end
end