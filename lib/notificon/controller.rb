module Notificon
  module Controller
    def notificon_tracker
      if params[Notificon.notification_id_param]
        read_at = (respond_to?(:current_time) && current_time) || Time.now
        Notificon.mark_notification_read(params[Notificon.notification_id_param], read_at)
      end
    end
  end
end