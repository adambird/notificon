# Class describing notification objects

require 'addressable/uri'

module Notificon
  class Notification
    attr_accessor :id, :username, :item_url, :item_text, :actor, :action, :occured_at, :read_at, :item_id
    
    def initialize(attrs={})
      attrs.each_pair do |k,v| send("#{k}=", v) end
    end
    
    # provided to enable simple creation from mongo hash objects
    def _id=(value)
      @id = value.to_s
    end
    
    def read?
      !read_at.nil?
    end
    
    def url
      uri = Addressable::URI.parse(item_url)
      params = {Notificon.notification_id_param => id}
      if item_id
        params[Notificon.notification_item_id_param] = item_id 
        params[Notificon.notification_username_param] = username 
      end
      uri.query_values = (uri.query_values || {}).merge(params)
      uri.to_s
    end
  end
end