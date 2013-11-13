require 'simplecov'
SimpleCov.start

require 'rspec'
require 'chamber'

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.filter_run focused: true
  config.alias_example_to :fit, focused: true
  config.run_all_when_everything_filtered = true
end
