require 'rspectacular'
require 'chamber/heroku_configuration'
require 'chamber'

class     Chamber
describe  HerokuConfiguration do
  it 'can push configuration to Heroku' do
    heroku_configuration = HerokuConfiguration.new  :variables => {
                                                      'TEST_VAR'         => 'MY_VALUE',
                                                    }

    allow(heroku_configuration).to receive(:system)

    heroku_configuration.push

    expect(heroku_configuration).to have_received(:system).
                                    with 'heroku config:set TEST_VAR=MY_VALUE'
  end

  it 'can push multiple configuration values to Heroku' do
    heroku_configuration = HerokuConfiguration.new  :variables => {
                                                      'TEST_VAR'         => 'MY_VALUE',
                                                      'ANOTHER_TEST_VAR' => 'ANOTHER_VALUE',
                                                    }

    allow(heroku_configuration).to receive(:system)

    heroku_configuration.push

    expect(heroku_configuration).to have_received(:system).
                                    with 'heroku config:set TEST_VAR=MY_VALUE ANOTHER_TEST_VAR=ANOTHER_VALUE'
  end

  it 'can push the configuration for a specific app' do
    heroku_configuration = HerokuConfiguration.new :app => 'test_app'

    allow(heroku_configuration).to receive(:system)

    heroku_configuration.push

    expect(heroku_configuration).to have_received(:system).
                                    with 'heroku config:set  --app test_app'
  end
end
end
