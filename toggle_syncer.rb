require 'awesome_print'
require 'yaml'
require 'togglv8'

class ToggleSyncer
  def initialize(workspace_id = '605711')
    @workspace_id = workspace_id
  end

  def all_time_entries
    api.get_time_entries(
      start_date: Date.today.next_day.to_time.strftime('%Y-%m-%dT%H:%M:%S.%L%z'),
      end_date: Date.today.to_time.strftime('%Y-%m-%dT%H:%M:%S.%L%z')
    )
  end


  private

  def api
    @api ||= TogglV8::API.new(ENV['TOGGLE_API_TOKEN'])
  end
end
