# Public: Api for the Notificon gem for tracking notifications for users
#
# Examples
#
#   Notificon.add_notification('sam', 'http://company.com/items/audha,
#     'Item title', 'bill', :commented, Time.now)
#
module Notificon
  require "notificon/notification"
  require "notificon/user_state"
  require "notificon/mongo_store"
  require "notificon/cache"
  require "notificon/notification_store"
  require "notificon/user_state_store"
  require "notificon/controller"
  require 'logger'

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

    # Public: cache to be used
    attr_accessor :cache

    # Public: Returns the query string parameter used to identify the notification.
    #   defaults to '_notificon_id' if not set
    def notification_id_param
      @_notification_id_param ||= '_notificon_id'
    end

    # Public: Returns the query string parameter used to identify the notification item.
    def notification_item_id_param
      "#{notification_id_param}_item"
    end

    # Public: Returns the query string parameter used to identify the user.
    def notification_username_param
      "#{notification_id_param}_user"
    end

    # Public: Sets the String to use for the notification_id_param
    def notification_id_param=(value)
      raise ArgumentError.new("value must a string or nil") unless value.nil? || value.is_a?(String)

      @_notification_id_param = value
    end

    # Public: Returns the connection profile for the datastore. Currently only mongo
    #   supported. Defaults to mongodb://localhost/notificon_default if not set
    def connection_profile
      @_connection_profile ||= "mongodb://localhost/notificon_default"
    end

    # Public: Sets the String for the connection_profile
    def connection_profile=(value)
      raise ArgumentError.new("value must a string or nil") unless value.nil? || value.is_a?(String)

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

      notification = notification_store.mark_as_read(id, read_at)
      update_user_unread_counts(notification.username)
    end

    # Public: Mark a notification as read
    #
    # username  - The String identifying the user
    # item_id   - The String identifying the notification item
    # read_at   - The Time the notitication was read
    #
    # Returns nothing
    def mark_all_read_for_item(username, item_id, read_at)
      raise ArgumentError.new("username must be a String") unless username.is_a? String
      raise ArgumentError.new("item_id must be a String") unless item_id.is_a? String
      raise ArgumentError.new("read_at must be a Time") unless read_at.is_a? Time

      notification_store.mark_all_read_for_item(username, item_id, read_at)
      update_user_unread_counts(username)
    end

    # Public: Add a notification to the users lists
    #
    # username   - The String identifying the user being notified
    # item_url   - A String url of the item notification relates to
    # item_text  - A String that describes the item
    # actor      - The String identifying the user that performed the action
    # action     - A Symbol representing the action that the actor performed
    # occured_at - The Time the action was performed
    # item_id    - A String uniquely identifying the item the notification is for
    #
    # Returns the String id of the Notification generated
    def add_notification(username, item_url, item_text, actor, action, occured_at, item_id=nil)
      raise ArgumentError.new("username must be a String") unless username.is_a? String
      raise ArgumentError.new("item_url must be a String") unless item_url.is_a? String
      raise ArgumentError.new("item_text must be a String") unless item_text.is_a? String
      raise ArgumentError.new("actor must be a String") unless actor.is_a? String
      raise ArgumentError.new("action must be a Symbol") unless action.is_a? Symbol
      raise ArgumentError.new("occured_at must be a Time") unless occured_at .is_a? Time

      notification_store.add(Notification.new(:username => username, :item_url => item_url,
        :item_text => item_text, :actor => actor, :action => action, :occured_at => occured_at, :item_id => item_id))
      update_user_unread_counts(username)
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

    # Public: Retrieve the known state of the user, ie notifcation count
    #
    # username   - The String identifying the user
    #
    # Returns UserState object describing the state
    def get_user_state(username)
      raise ArgumentError.new("username must be a String") unless username.is_a? String

      user_state_store.get(username)
    end

    # Public: Clear all unread notifications for the user
    #
    # username    - The String identifying the user
    #
    # Returns nothing
    def clear_notifications(usernames)
      raise ArgumentError.new("username must be a String") unless username.is_a? String

      notification_store.mark_all_read_for_user(username)
      user_state_store.clear_notifications(username)
    end

    def update_user_unread_counts(username)
      user_state_store.set_notifications(username, notification_store.unread_count_for_user(username))
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

    def user_state_store
      @_user_states_store ||= UserStateStore.new
    end
  end
end