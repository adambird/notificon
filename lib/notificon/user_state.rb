# Public: Encapsulates the user state
module Notificon
  class UserState
    
    # Public : Gets the username
    attr_reader :username
      
    # Public : Gets the number of unread notifications
    def notifications
      @_notifications ||= 0
    end
    
    def initialize(attrs)
      @username = attrs['username']
      @_notifications = attrs['notifications']
    end
  end
end