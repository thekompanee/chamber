# frozen_string_literal: true

require 'chamber'
require 'securerandom'
require 'rspectacular'
require 'chamber/adapters/cloud/circle_ci'

module   Chamber
module   Adapters
module   Cloud
describe CircleCi do
  it 'can retrieve environment variables' do
    adapter = CircleCi.new(api_token: ::Chamber.env.circle_ci.api_token,
                           project:   'chamber',
                           username:  'thekompanee',
                           vcs_type:  'github')

    expect(adapter.environment_variables['CHAMBER_KEY']).to eql 'xxxx----'
  end

  it 'can add environment variables' do
    adapter = CircleCi.new(api_token: ::Chamber.env.circle_ci.api_token,
                           project:   'chamber',
                           username:  'thekompanee',
                           vcs_type:  'github')

    environment_key = ::SecureRandom.base64(64).gsub(/[^a-zA-Z]+/, '')[0..16]

    adapter.add_environment_variable(environment_key, '12341234')

    expect(adapter.environment_variables[environment_key]).to eql 'xxxx1234'

    adapter.remove_environment_variable(environment_key)
  end

  it 'knows to convert newlines to literal \\n strings' do
    adapter = CircleCi.new(api_token: ::Chamber.env.circle_ci.api_token,
                           project:   'chamber',
                           username:  'thekompanee',
                           vcs_type:  'github')

    environment_key = ::SecureRandom.base64(64).gsub(/[^a-zA-Z]+/, '')[0..16]

    adapter.add_environment_variable(environment_key, "123412\n34")

    expect(adapter.environment_variables[environment_key]).to eql 'xxxx\n34'

    adapter.remove_environment_variable(environment_key)
  end

  it 'can properly display errors' do
    adapter = CircleCi.new(api_token: ::Chamber.env.circle_ci.api_token,
                           project:   'chamber',
                           username:  'thekompanee',
                           vcs_type:  'github')

    invalid_environment_key = '12345=!'

    expect {
      adapter.add_environment_variable(invalid_environment_key, '12341234')
    }.to raise_error(NameError)
           .with_message("The variable name '12345=!' is invalid")
  end

  it 'can remove environment variables' do
    adapter = CircleCi.new(api_token: ::Chamber.env.circle_ci.api_token,
                           project:   'chamber',
                           username:  'thekompanee',
                           vcs_type:  'github')

    environment_key = ::SecureRandom.base64(64).gsub(/[^a-zA-Z]+/, '')[0..16]

    adapter.add_environment_variable(environment_key, '12341234')

    adapter.remove_environment_variable(environment_key)

    expect(adapter.environment_variables[environment_key]).to be nil
  end
end
end
end
end
