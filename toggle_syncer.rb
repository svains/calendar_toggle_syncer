require 'awesome_print'
require 'yaml'
require 'togglv8'
require 'active_support/time'

class ToggleSyncer
  PROJECT_ID_DEV_OTHER = 8453932
  BLUEBERRY_WORKSPACE_ID = 605711

  def initialize(workspace_id = '605711')
    @workspace_id = workspace_id
  end

  def my_time_entries
    api.get_time_entries
  end

  def create_event(duration:, wid: BLUEBERRY_WORKSPACE_ID, pid: PROJECT_ID_DEV_OTHER, description:, start_time:)
    unless my_time_entries.select { |entry|
      entry['description'] == description &&
      Time.parse(entry['start']) == Time.parse(start_time.to_s)
    }.empty?
      puts "- #{description} already exists"
    else
      api.create_time_entry(
        'duration' => duration,
        'wid' => wid,
        'description' => description,
        'start' => iso8601(start_time),
        'created_with' => description,
        'billable' => true,
        'pid' => pid
      )
    end
  end

  def iso8601(timestamp)
    api.iso8601(timestamp.to_datetime)
  end

  private

  def api
    @api ||= TogglV8::API.new(ENV['TOGGLE_API_TOKEN'])
  end
end
