# Class describing notification objects

require 'addressable/uri'

module Notificon
  class Notification
    attr_accessor :id, :username, :item_url, :item_text, :actor, :action, :occured_at, :read_at
    
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
      output = item_url
      output += uri.query ? "&" : "?"
      output += "#{Notificon.notification_id_param}=#{id}"
    end
  end
end