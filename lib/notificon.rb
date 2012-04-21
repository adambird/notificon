module Readicon
  
  class << self
    def setup
      yield self
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
    
    private 
    
      def build_logger
        logger = Logger.new(STDOUT)
        logger.progname = "Notificon"
        logger.level = Notificon.log_level
        logger
      end
      
      def coordinator
        @_coordinator ||= Coordinator.new
      end
    
  end
end