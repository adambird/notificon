module Notificon
  module Controller
    def notificon_tracker
      if id = params[Notificon.notification_id_param]
        Notificon.logger.info { "notificon_tracker marking #{id} as read" }
        read_at = (respond_to?(:current_time) && current_time) || Time.now
        Notificon.mark_notification_read(id, read_at)
      end
    rescue => e
      Notificon.logger.error { "Notificon::Controller#notificon_tracker error processing notification params - #{params.inspect} error - #{e.inspect}" }
    end
  end
end