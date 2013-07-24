#!/usr/bin/env ruby

require 'google-api-middle_man'

google_config = {
  application_name: "Google Project Name"
  key_location: 'client.p12',
  google_service_email: "google_service_account_email@developer.gserviceaccount.com"
}
calendar_id = "google_calendar_id@group.calendar.google.com"

travel_agent = GoogleAPIMiddleMan::Agent.new(google_config)
events = travel_agent.calendar_events(calendar_id)

puts events.items.inspect


