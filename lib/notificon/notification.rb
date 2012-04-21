# Class describing notification objects

module Notificon
  class Notification
    attr_accessor :id, :username, :item_url, :text, :occured_at, :read_at
    
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
  end
end