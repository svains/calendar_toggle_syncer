#!/usr/bin/env ruby

require_relative 'google_calendar.rb'
require_relative 'toggle_syncer.rb'

require 'dotenv/load'
require 'fileutils'
require 'awesome_print'

puts "Today's events:"

google_calendar = GoogleCalendar.new
toggle_syncer   = ToggleSyncer.new

events = google_calendar.fetch.items

if events.empty?
  puts "No upcoming events found"
else
  events.each do |event|
    # Skip if we're filtering this
    next if google_calendar.skip?(event.summary)

    # Skip if declined event
    next if event.attendees.select {|attendee| attendee.email.start_with?(ENV['BB_LOGIN']) && %w(accepted tentative).include?(attendee.response_status)}.empty?

    start_time = event.start.date || event.start.date_time
    end_time   = event.end.date   || event.end.date_time

    duration = (end_time.to_time - start_time.to_time)

    puts "- #{event.summary} - #{duration} - (#{start_time} - #{end_time})"

    toggle_syncer.create_event(
      duration: duration,
      start_time: start_time,
      description: event.summary
    )
  end
end
