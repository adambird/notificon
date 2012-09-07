# Public : Module to include in ApplicationController to support notification read tracking
#
# class ApplicationController
#   include Notificon::Controller
#
# end
module Notificon
  module Controller

    def self.included(base)
      if base.respond_to?(:before_filter)
        base.before_filter :notificon_tracker
        Notificon.logger.info { "Notificon::Controller.included wired up before_filter :notificon_tracker" }
      else
        Notificon.logger.info { "Notificon::Controller.included before_filter method not found" }
      end
    end

    # Public : method to use as a before filter on the application controller to track read status
    # of notifications
    #
    # Returns bookean indicating whether updates made
    def notificon_tracker
      request.get? && (_track_explicit_read | _track_implicit_read)
    rescue => e
      Notificon.logger.info { "Notificon::Controller#notificon_tracker error processing notification params - #{params.inspect} error - #{e.inspect}" }
    end

    # Private : uses notificon explicit parameters to track reads for items
    def _track_explicit_read
      if params[Notificon.notification_item_id_param] && params[Notificon.notification_username_param]
        Notificon.mark_all_read_for_item(params[Notificon.notification_username_param], params[Notificon.notification_item_id_param], _notificon_read_at)
        Notificon.logger.info { "Notificon::Controller#_track_explicit_read - all for item #{params[Notificon.notification_item_id_param]} #{params[Notificon.notification_username_param]}" }
        true
      elsif id = params[Notificon.notification_id_param]
        Notificon.mark_notification_read(id, _notificon_read_at)
        Notificon.logger.info { "Notificon::Controller#_track_explicit_read - specific notification #{params[Notificon.notification_id_param]}" }
        true
      end
    end

    # Private : uses controller methods to track implicit reads for items
    def _track_implicit_read
      if respond_to?(:current_username) && respond_to?(:current_item_id) && current_username && current_item_id
        Notificon.mark_all_read_for_item(current_username, current_item_id, _notificon_read_at)
        Notificon.logger.info { "Notificon::Controller#_track_implicit_read - for user #{current_username} and item #{current_item_id}" }
        true
      end
    end

    # Private : lazy assignment of read_at  time
    def _notificon_read_at
      @_notificon_read_at ||= ((respond_to?(:current_time) && current_time) || Time.now)
    end
  end
end