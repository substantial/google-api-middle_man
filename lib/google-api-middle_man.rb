require "google-api-middle_man/version"

module GoogleAPIMiddleMan
  class MissingConfigOptions < Exception; end

  class Agent
    require 'google/api_client'

    attr_reader :client

    def initialize(config)
      [:application_name, :key_location, :google_service_email].each do |key|
        unless config.has_key?(key) || config.has_key?(key.to_s)
          raise MissingConfigOptions, "config is missing #{key}"
        end
      end

      @application_name = config[:application_name] || config['application_name']
      @key_location = config[:key_location] || config['key_location']
      @google_service_email = config[:google_service_email] || config['google_service_email']

      @client = Google::APIClient.new(application_name: @application_name)
    end

    def calendar_events(calendar_id)
      @client.authorization = service_account.authorize

      options = events_list_options_hash.merge('calendarId' => calendar_id)

      result = @client.execute(api_method: calendar_service.events.list, parameters: options)

      result.data
    end

    private

    def default_scope
      'https://www.googleapis.com/auth/prediction'
    end

    def calendar_scope
      'https://www.googleapis.com/auth/calendar.readonly'
    end

    def scopes
      s = []
      s << default_scope
      s << calendar_scope
      s
    end

    def api_key
      @api_key ||= Google::APIClient::PKCS12.load_key(@key_location, 'notasecret')
    end

    def service_account
      Google::APIClient::JWTAsserter.new(@google_service_email, scopes, api_key)
    end

    def calendar_service
      @client.discovered_api('calendar', 'v3')
    end

    def events_list_options_hash
      {
        'singleEvents' => 'true',
        'orderBy' => 'startTime',
        'timeMax' => DateTime.now + 1,
        'timeMin' => DateTime.now,
        'fields' => 'description,items(colorId,created,creator(displayName,email),description,end,endTimeUnspecified,id,kind,location,start,status,summary),kind,summary,updated'
      }
    end
  end
end

