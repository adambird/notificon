module Notificon
  module Controller
    def notificon_tracker
      if id = params[Notificon.notification_id_param]
        read_at = (respond_to?(:current_time) && current_time) || Time.now
        if params[Notificon.notification_item_id_param] && params[Notificon.notification_username_param]
          Notificon.mark_all_read_for_item(params[Notificon.notification_username_param], params[Notificon.notification_item_id_param], read_at)
        else
          Notificon.mark_notification_read(id, read_at)
        end
      end
    rescue => e
      Notificon.logger.error { "Notificon::Controller#notificon_tracker error processing notification params - #{params.inspect} error - #{e.inspect}" }
    end
  end
end