# Public : Module to include in ApplicationController to support notification read tracking
#
# class ApplicationController
#   include Notificon::Controller
#   before_filter :notificon_tracker
#
# end
module Notificon
  module Controller
    # Public : method to use as a before filter on the application controller to track read status
    # of notifications
    #
    # Returns bookean indicating whether updates made
    def notificon_tracker
      _track_explicit_read | _track_implicit_read
    rescue => e
      Notificon.logger.error { "Notificon::Controller#notificon_tracker error processing notification params - #{params.inspect} error - #{e.inspect}" }
    end

    # Private : uses notificon explicit parameters to track reads for items
    def _track_explicit_read
      if params[Notificon.notification_item_id_param] && params[Notificon.notification_username_param]
        Notificon.mark_all_read_for_item(params[Notificon.notification_username_param], params[Notificon.notification_item_id_param], _notificon_read_at)
        true
      elsif id = params[Notificon.notification_id_param]
        Notificon.mark_notification_read(id, _notificon_read_at)
        true
      end
    end

    # Private : uses controller methods to track implicit reads for items
    def _track_implicit_read
      if respond_to?(:current_username) && respond_to?(:current_item_id) && current_username && current_item_id
        Notificon.mark_all_read_for_item(current_username, current_item_id, _notificon_read_at)
        true
      end
    end

    # Private : lazy assignment of read_at  time
    def _notificon_read_at
      @_notificon_read_at ||= ((respond_to?(:current_time) && current_time) || Time.now)
    end
  end
end