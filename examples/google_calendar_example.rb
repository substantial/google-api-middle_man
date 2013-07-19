#!/usr/bin/env ruby

require 'google_travel_agent'

email = "google_service_account@email"
calendarId = "google_calendar_id"

google_config = {
  application_name: "google_project_name",
  key_location: 'client.p12',
  google_service_email: email
}

travel_agent = GoogleTravelAgent::Agent.new(google_config)
travel_agent.calendar_events(calendar_id)

