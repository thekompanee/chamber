# frozen_string_literal: true

require 'chamber'
require 'securerandom'
require 'rspectacular'
require 'chamber/adapters/cloud/heroku'

module   Chamber
module   Adapters
module   Cloud
describe Heroku do
  it 'can retrieve environment variables' do
    adapter = Heroku.new(app: ::Chamber.env.heroku.test_app_name)

    expect(adapter.environment_variables['FOO']).to eql 'BAR'
  end

  it 'can add environment variables' do
    adapter         = Heroku.new(app: ::Chamber.env.heroku.test_app_name)
    environment_key = ::SecureRandom.base64(64).gsub(/[^a-zA-Z]+/, '')[0..16]

    adapter.add_environment_variable(environment_key, '12341234')

    expect(adapter.environment_variables[environment_key]).to eql '12341234'

    adapter.remove_environment_variable(environment_key)
  end

  it 'can properly display errors' do
    adapter                 = Heroku.new(app: ::Chamber.env.heroku.test_app_name)
    invalid_environment_key = '12345\!-[]=!'

    expect {
      adapter.add_environment_variable(invalid_environment_key, '12341234')
    }.to raise_error(NameError)
           .with_message("The variable name '12345\\!-[]=!' is invalid")
  end

  it 'can remove environment variables' do
    adapter         = Heroku.new(app: ::Chamber.env.heroku.test_app_name)
    environment_key = ::SecureRandom.base64(64).gsub(/[^a-zA-Z]+/, '')[0..16]

    adapter.add_environment_variable(environment_key, '12341234')

    adapter.remove_environment_variable(environment_key)

    expect(adapter.environment_variables[environment_key]).to be nil
  end
end
end
end
end
