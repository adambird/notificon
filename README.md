# notificon

Gem for tracking and managing application notifications for users. Just an abstraction of some common functionality.

It currently uses MongoDB as a datastore

## Setup

Add the gem to your `Gemfile`

    gem 'notificon'

Configure the data store

```ruby
Notificon.setup do |config|
  config.connection_profile = mongodb://server
end
```

You can also pass in a logger and cache for the gem to use

```ruby
Notificon.setup do |config|
  config.connection_profile = mongodb://.......
  config.logger = Rails.logger
  config.cache = Rails.cache
end
```

** TODO ** rake task for ensuring indexes

## Usage

The core operations have been exposed as a class methods on the Notificon module

### Recording a notification

```ruby
Notificon.add_notification(username, item_url, item_text, actor, action, occured_at, item_id)
```

+ *username*   - The String identifying the user being notified
+ *item_url*   - A String url of the item notification relates to
+ *item_text*  - A String that describes the item
+ *actor*      - The String identifying the user that performed the action
+ *action*     - A Symbol representing the action that the actor performed
+ *occured_at* - The Time the action was performed
+ *item_id*    - A String uniquely identifying the item the notification is for


