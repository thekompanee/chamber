# frozen_string_literal: true

require 'chamber'
require 'securerandom'
require 'rspectacular'
require 'chamber/adapters/cloud/heroku'

module   Chamber
module   Adapters
module   Cloud
describe Heroku do
  before(:each) { Chamber.load }

  it 'can retrieve environment variables' do
    adapter = Heroku.new(app:       ::Chamber['heroku']['test_app_name'],
                         api_token: ::Chamber['heroku']['api_token'])

    expect(adapter.environment_variables['FOO']).to eql 'BAR'
  end

  it 'can add environment variables' do
    adapter         = Heroku.new(app:       ::Chamber['heroku']['test_app_name'],
                                 api_token: ::Chamber['heroku']['api_token'])
    environment_key = ::SecureRandom.base64(64).gsub(/[^a-zA-Z]+/, '')[0..16]

    adapter.add_environment_variable(environment_key, '12341234')

    expect(adapter.environment_variables[environment_key]).to eql '12341234'

    adapter.remove_environment_variable(environment_key)
  end

  it 'knows to convert newlines to literal \\n strings' do
    adapter         = Heroku.new(app:       ::Chamber['heroku']['test_app_name'],
                                 api_token: ::Chamber['heroku']['api_token'])
    environment_key = ::SecureRandom.base64(64).gsub(/[^a-zA-Z]+/, '')[0..16]

    adapter.add_environment_variable(environment_key, "123412\n34")

    expect(adapter.environment_variables[environment_key]).to eql '123412\n34'

    adapter.remove_environment_variable(environment_key)
  end

  it 'can properly display errors' do
    adapter                 = Heroku.new(app:       ::Chamber['heroku']['test_app_name'],
                                         api_token: ::Chamber['heroku']['api_token'])
    invalid_environment_key = '12345\!-[]=!'

    expect {
      adapter.add_environment_variable(invalid_environment_key, '12341234')
    }.to raise_error(NameError)
           .with_message('Config var key must not include =.')
  end

  it 'can remove environment variables' do
    adapter         = Heroku.new(app:       ::Chamber['heroku']['test_app_name'],
                                 api_token: ::Chamber['heroku']['api_token'])
    environment_key = ::SecureRandom.base64(64).gsub(/[^a-zA-Z]+/, '')[0..16]

    adapter.add_environment_variable(environment_key, '12341234')

    adapter.remove_environment_variable(environment_key)

    expect(adapter.environment_variables[environment_key]).to be nil
  end
end
end
end
end
