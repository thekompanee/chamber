# frozen_string_literal: true

require 'json'
require 'net/http'
require 'uri'

module  Chamber
module  Adapters
module  Cloud
class   CircleCi
  API_HOST     = 'circleci.com'
  API_PORT     = 443
  API_BASE_URI = '/api/v1.1'

  attr_accessor :api_token,
                :project,
                :username,
                :vcs_type

  def initialize(options = {})
    self.api_token = options.fetch(:api_token)
    self.project   = options.fetch(:project)
    self.username  = options.fetch(:username)
    self.vcs_type  = options.fetch(:vcs_type)
  end

  def add_environment_variable(name, value)
    value   = value.gsub(/\n/, '\n')
    request = ::Net::HTTP::Post.new(request_uri(resource: 'envvar'))

    request.basic_auth api_token, ''
    request['Content-Type'] = 'application/json'
    request.body            = ::JSON.dump(name: name, value: value)

    response = ::JSON.parse(response(request).body)

    fail NameError, response['message'] if response['message']

    response['name']
  end

  # rubocop:disable Layout/MultilineAssignmentLayout
  def environment_variables
    @environment_variables ||= \
      begin
        request = ::Net::HTTP::Get.new(request_uri(resource: 'envvar'))

        request.basic_auth api_token, ''
        request['Content-Type'] = 'application/json'

        ::JSON
          .parse(response(request).body)
          .each_with_object({}) { |e, m| m[e['name']] = e['value'] }
      end
  end
  # rubocop:enable Layout/MultilineAssignmentLayout

  def remove_environment_variable(name)
    request = ::Net::HTTP::Delete.new(request_uri(resource: "envvar/#{name}"))

    request.basic_auth api_token, ''
    request['Content-Type'] = 'application/json'

    ::JSON.parse(response(request).body)['message'] == 'ok'
  end

  private

  def request_uri(resource:)
    "#{API_BASE_URI}/project/#{vcs_type}/#{username}/#{project}/#{resource}"
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
