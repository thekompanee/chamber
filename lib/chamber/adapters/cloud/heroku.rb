# frozen_string_literal: true

require 'json'
require 'net/http'
require 'uri'

module  Chamber
module  Adapters
module  Cloud
class   Heroku
  API_HOST     = 'api.heroku.com'
  API_PORT     = 443
  API_BASE_URI = ''

  attr_accessor :api_token,
                :app

  def initialize(api_token:, app:)
    self.api_token = api_token
    self.app       = app
  end

  def add_environment_variable(name, value)
    value   = value.gsub(/\n/, '\n') if value
    request = ::Net::HTTP::Patch.new(config_vars_uri)

    request['Authorization'] = "Bearer #{api_token}"
    request['Accept']        = 'application/vnd.heroku+json; version=3'
    request['Content-Type']  = 'application/json'
    request.body             = ::JSON.dump({ name => value })

    response = ::JSON.parse(response(request).body)

    fail NameError, response['message'] if response['message']

    response
  end

  def environment_variables
    request = ::Net::HTTP::Get.new(config_vars_uri)

    request['Authorization'] = "Bearer #{api_token}"
    request['Accept']        = 'application/vnd.heroku+json; version=3'

    response = ::JSON.parse(response(request).body)

    fail NameError, response['message'] if response['message']

    response
  end

  def remove_environment_variable(name)
    add_environment_variable(name, nil)
  end

  private

  def config_vars_uri
    "#{API_BASE_URI}/apps/#{app}/config-vars"
  end

  def response(request)
    connection.request(request)
  end

  def connection
    @connection ||= ::Net::HTTP.new(API_HOST, API_PORT).tap do |conn|
      conn.use_ssl = true
    end
  end
end
end
end
end
