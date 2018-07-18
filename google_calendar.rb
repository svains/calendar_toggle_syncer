require 'awesome_print'
require 'google/apis/calendar_v3'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'
require 'yaml'

class GoogleCalendar
  OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'.freeze
  UESR_ID = 'default'

  def initialize
    @event_object = nil
  end

  def fetch
    @event_object ||= service.list_events(
      'primary',
      max_results: 100,
      order_by: 'startTime',
      single_events: true,
      time_max: Date.today.next_day.to_time.strftime('%Y-%m-%dT%H:%M:%S.%L%z'),
      time_min: Date.today.to_time.strftime('%Y-%m-%dT%H:%M:%S.%L%z')
    )

    @event_object
  end

  def skip?(event_name)
    skip_event_names.map(&:downcase).include?(event_name.downcase)
  end


  private

  CLIENT_SECRETS_PATH = 'client_secrets.json'.freeze
  CREDENTIALS_PATH = 'token.yaml'.freeze

  def service
    @service ||= begin
      api = Google::Apis::CalendarV3::CalendarService.new
      api.client_options.application_name = 'Google calendar to Toggle syncer'
      api.authorization = authorize
      api
    end
  end

  def authorize
    @authorize ||= begin
      # If we can't find credentials let's prompt for them
      if credentials.nil?
        url = authorizer.get_authorization_url(base_url: OOB_URI)

        puts 'Open the following URL in the browser and enter the resulting code after authorization:\n' + url

        code = gets

        authorizer.get_and_store_credentials_from_code(
          user_id: USER_ID, code: code, base_url: OOB_URI
        )
      else
        credentials
      end
    end
  end

  def skip_event_names
    @skip_event_names ||= begin
      YAML.load(File.read('skip_event_names.json'))
    end
  end

  def client_id
    @client_id ||= Google::Auth::ClientId.from_file(CLIENT_SECRETS_PATH)
  end

  def token_store
    @token_store ||= Google::Auth::Stores::FileTokenStore.new(file: CREDENTIALS_PATH)
  end

  def authorizer(scope = Google::Apis::CalendarV3::AUTH_CALENDAR_READONLY)
    @authorizer ||= Google::Auth::UserAuthorizer.new(client_id, scope, token_store)
  end

  def credentials
    @credentials ||= authorizer.get_credentials(UESR_ID)
  end
end
