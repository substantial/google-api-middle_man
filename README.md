# GoogleTravelAgent

 Use a middle man for dealing with Google API

## Installation

Add this line to your application's Gemfile:

    gem 'google-api-middle_man'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install google-api-middle_man

## Usage
Look under `examples`
```ruby
  #!/usr/bin/env ruby

  require 'google-api-middle_man'

  google_config = {
    application_name: "Google Project Name"
    key_location: 'client.p12',
    google_service_email: "google_service_account_email@developer.gserviceaccount.com"
  }
  calendar_id = "google_calendar_id@group.calendar.google.com"

  agent = GoogleAPIMiddleMan::Agent.new(google_config)

  events = agent.calendar_events(calendar_id)
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

