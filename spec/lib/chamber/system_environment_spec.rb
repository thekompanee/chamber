require 'rspectacular'
require 'chamber/system_environment'

class     Chamber
describe  SystemEnvironment do
  it 'can extract environment variables based on a hash that is passed in' do
    source_hash = {
      level_one_1: {
        level_two_1: 'value 1',
        level_two_2: {
          level_three_1: 'value 2',
          level_three_2: 'value 3',
        },
        level_two_3: 'value 4',
      level_one_2: 'value 5' }
    }

    expect(SystemEnvironment.extract_from(source_hash)).to eql({
      'LEVEL_ONE_1_LEVEL_TWO_1'               => 'value 1',
      'LEVEL_ONE_1_LEVEL_TWO_2_LEVEL_THREE_1' => 'value 2',
      'LEVEL_ONE_1_LEVEL_TWO_2_LEVEL_THREE_2' => 'value 3',
      'LEVEL_ONE_1_LEVEL_TWO_3'               => 'value 4',
      'LEVEL_ONE_1_LEVEL_ONE_2'               => 'value 5',
    })
  end

  it 'converts all items to strings so that they are usable as an environment variable' do
    source_hash = {
      value_one: Time.utc(2013, 10, 8, 18, 0, 1),
      value_two: 3,
    }

    expect(SystemEnvironment.extract_from(source_hash)).to eql({
      'VALUE_ONE' => '2013-10-08 18:00:01 UTC',
      'VALUE_TWO' => '3',
    })
  end

  it 'allows injected environment variables to be prefixed for compatibility' do
    ENV['PREFIX_VALUE_ONE'] = 'value 1'

    source_hash = {
      value_one: 'value',
    }

    environment_hash = SystemEnvironment.inject_into(source_hash, [:prefix])

    expect(environment_hash).to eql({
      'value_one' => 'value 1',
    })
  end

  it 'allows extracted environment variables to be prefixed for compatibility' do
    source_hash = {
      value_one: 'value',
    }

    environment_hash = SystemEnvironment.extract_from(source_hash, [:prefix])

    expect(environment_hash).to eql({
      'PREFIX_VALUE_ONE' => 'value',
    })
  end

  it 'can inject existing environment variable values into a hash' do
    ENV['LEVEL_ONE_1_LEVEL_TWO_1']               = 'value 1'
    ENV['LEVEL_ONE_1_LEVEL_TWO_2_LEVEL_THREE_1'] = 'value 2'
    ENV['LEVEL_ONE_1_LEVEL_TWO_2_LEVEL_THREE_2'] = 'value 3'
    ENV['LEVEL_ONE_1_LEVEL_TWO_3']               = 'value 4'
    ENV['LEVEL_ONE_1_LEVEL_ONE_2']               = 'value 5'

    source_hash = {
      level_one_1: {
        level_two_1: nil,
        level_two_2: {
          level_three_1: nil,
          level_three_2: '',
        },
        level_two_3: '',
      level_one_2: '' }
    }

    expect(SystemEnvironment.inject_into(source_hash)).to eql({
      'level_one_1' => {
        'level_two_1' => 'value 1',
        'level_two_2' => {
          'level_three_1' => 'value 2',
          'level_three_2' => 'value 3',
        },
        'level_two_3' => 'value 4',
      'level_one_2' => 'value 5' }
    })

    ENV.delete('LEVEL_ONE_1_LEVEL_TWO_1')
    ENV.delete('LEVEL_ONE_1_LEVEL_TWO_2_LEVEL_THREE_1')
    ENV.delete('LEVEL_ONE_1_LEVEL_TWO_2_LEVEL_THREE_2')
    ENV.delete('LEVEL_ONE_1_LEVEL_TWO_3')
    ENV.delete('LEVEL_ONE_1_LEVEL_ONE_2')
  end

  it 'can convert simple boolean text values to their Boolean equivalents' do
    source_hash = {
      true_text:    'true',
      true_single:  't',
      true_yes:     'yes',
      false_text:   'false',
      false_single: 'f',
      false_no:     'no',
    }

    environment_hash = SystemEnvironment.inject_into(source_hash)

    expect(environment_hash['true_text']).to    be_a TrueClass
    expect(environment_hash['true_single']).to  be_a TrueClass
    expect(environment_hash['true_yes']).to     be_a TrueClass
    expect(environment_hash['false_text']).to   be_a FalseClass
    expect(environment_hash['false_single']).to be_a FalseClass
    expect(environment_hash['false_no']).to     be_a FalseClass
  end
end
end
