require 'spec_helper'

describe GoogleAPIMiddleMan::Agent do

  let(:google_config) {
    {
      application_name: 'Foo App',
      key_location: 'config/client.p12',
      google_service_email: 'test@example.com'
    }
  }

  before do
    Google::APIClient.stub(:new) { double.as_null_object }
  end

  it "should require a configuration object" do
    expect { GoogleAPIMiddleMan::Agent.new('foo') }.to raise_error
  end

  it "should require a complete config" do
    incomplete_config = google_config
    incomplete_config.delete(:key_location)
    expect { GoogleAPIMiddleMan::Agent.new(incomplete_config) }.to raise_error GoogleAPIMiddleMan::MissingConfigOptions
  end

  it "should create a client with the correct application name" do
    Google::APIClient.should_receive(:new).with(application_name: 'Foo App')
    GoogleAPIMiddleMan::Agent.new(google_config)
  end

  it "should allow strings or symbols for keys" do
    google_config_as_string = {
      'application_name' => 'foo app',
      'key_location' => 'some key location',
      'google_service_email' => 'email stuff'
    }
    Google::APIClient.should_receive(:new).with(application_name: 'foo app')
    GoogleAPIMiddleMan::Agent.new(google_config_as_string)
  end

  describe "#calendar_events" do
    let(:calendar_hash) { double }
    let(:travel_agent) { GoogleAPIMiddleMan::Agent.new(google_config) }
    let(:mock_service_account) { double(authorize: "authorization") }

    before do
      Google::APIClient.stub(:new) { double(:authorization= => :nil, execute: double(data: calendar_hash))}
      travel_agent.stub(:api_key) { 'api_key' }
      travel_agent.stub(:service_account) { mock_service_account }
      travel_agent.stub(:calendar_service) { c = double
                                             c.stub_chain(:events, :list) { "events_list_api" }
                                             c
      }
    end

    it "should require a calendar id" do
      expect { travel_agent.calendar_events }.to raise_error ArgumentError
    end

    it "should set the client authorization" do
      travel_agent.client.should_receive(:authorization=).with("authorization")
      travel_agent.calendar_events('calendar_id')
    end

    it "should return hash of event info from Google" do
      travel_agent.calendar_events('calendar_id').should == calendar_hash
    end
  end

  describe "private methods" do
    let(:travel_agent) { GoogleAPIMiddleMan::Agent.new(google_config) }

    describe "scopes" do
      let(:default_scope) { 'https://www.googleapis.com/auth/prediction' }
      let(:calendar_scope) { 'https://www.googleapis.com/auth/calendar.readonly' }
      let(:scopes) { [default_scope, calendar_scope]}

      it "should have a default scope" do
        travel_agent.send(:default_scope).should == default_scope
      end

      it "should have a have a calendar_scope" do
        travel_agent.send(:calendar_scope).should == calendar_scope
      end

      it "should have a have scopes" do
        travel_agent.send(:scopes).should == scopes
      end
    end

    describe "#api_key" do
      before do
        Google::APIClient::PKCS12.stub(:load_key) { 'some key' }
      end
      it "should load a valid api key" do
        Google::APIClient::PKCS12.should_receive(:load_key).with(google_config[:key_location], 'notasecret')
        travel_agent.send(:api_key).should == 'some key'
      end

      it "should memoize the key" do
        travel_agent.send(:api_key)
        Google::APIClient::PKCS12.should_not_receive(:load_key)
        travel_agent.send(:api_key)
      end
    end

    describe "#service_account" do
      let(:mock_service)  { double }

      before do
        travel_agent.stub(:api_key) { "api_key" }
        travel_agent.stub(:scopes) { "scopes" }
        Google::APIClient::JWTAsserter.stub(:new) { mock_service }
      end

      it "should return a new google service account" do
        Google::APIClient::JWTAsserter.should_receive(:new).with(
          google_config[:google_service_email],
          "scopes",
          "api_key"
        )
        travel_agent.send(:service_account).should == mock_service
      end
    end

    describe "#calendar_service" do

      let(:mock_calendar_service) { double }

      before do
        travel_agent.client.stub(:discovered_api) { mock_calendar_service }
      end

      it "should return a calendar service" do
        travel_agent.send(:calendar_service).should == mock_calendar_service
      end

      it "should discover calendar endpoint" do
        travel_agent.client.should_receive(:discovered_api).with('calendar', 'v3')
        travel_agent.send(:calendar_service)
      end
    end

    describe "#events_list_options_hash" do

      let(:options_hash) { travel_agent.send(:events_list_options_hash) }
      let(:now) { DateTime.new(2010, 1, 1, 10, 0, 0) }
      let(:tomorrow) { now + 1 }

      before do
        DateTime.stub(:now) { now }
      end

      it "should only return single events and convert repeating to single" do
        options_hash['singleEvents'].should == 'true'
      end

      it "should order by start time" do
        options_hash['orderBy'].should == 'startTime'
      end

      it "should only return events that start a day from now" do
        options_hash['timeMax'].should == tomorrow
      end

      it "should only return events that end after now" do
        options_hash['timeMin'].should == now
      end

      it "should only return the fields specified" do
        options_hash['fields'].should == 'description,items(colorId,created,creator(displayName,email),description,end,endTimeUnspecified,id,kind,location,start,status,summary),kind,summary,updated'
      end
    end
  end

end

