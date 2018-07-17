#!/usr/bin/env ruby

require_relative 'google_calendar.rb'
require_relative 'toggle_syncer.rb'

require 'dotenv/load'
require 'fileutils'
require 'awesome_print'

puts "Today's events:"

google_calendar = GoogleCalendar.new
toggle_syncer = TogglV8::API.new(ENV['TOGGLE_API_TOKEN'])
toggle_syncer.debug(true)

events = google_calendar.fetch.items

if events.empty?
  puts "No upcoming events found"
else
  events.each do |event|
    # Skip if we're filtering this
    next if google_calendar.skip?(event.summary)

    # Skip if it already exists


    start_time = event.start.date || event.start.date_time
    end_time   = event.end.date   || event.end.date_time

    toggle_syncer.create_time_entry({
      'description' => event.summary,
      'wid' => '605711',
      'duration' => 1200,
      'start' => start_time.strftime('%Y-%m-%dT%H:%M:%S.%L%z'),
      'stop' => end_time.strftime('%Y-%m-%dT%H:%M:%S.%L%z'),
      'created_with' => event.summary,
      'pid' => '8453932',
      'billable' => true,
    })

    puts "- #{event.summary} (#{start})"
  end
end

# raise toggle_syncer.all_time_entries.inspect

# raise toggl_api.get_time_entries({start_date: Date.today.next_day.to_time.strftime('%Y-%m-%dT%H:%M:%S.%L%z'), end_date: Date.today.to_time.strftime('%Y-%m-%dT%H:%M:%S.%L%z')}).inspect
