#!/usr/bin/env ruby

require 'google-api-middle_man'

email = "google_service_account@email"
calendarId = "google_calendar_id"

google_config = {
  application_name: "google_project_name",
  key_location: 'client.p12',
  google_service_email: email
}

travel_agent = GoogleAPIMiddleMan::Agent.new(google_config)
travel_agent.calendar_events(calendar_id)

