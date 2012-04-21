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
    
    def mark_notification_read(id, read_at)
      notification_store.mark_as_read(id, read_at)
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