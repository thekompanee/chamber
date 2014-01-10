require 'rspectacular'
require 'chamber/system_environment'

module    Chamber
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

  it 'allows extracted environment variables to be prefixed for compatibility' do
    source_hash = {
      value_one: 'value',
    }

    environment_hash = SystemEnvironment.extract_from(source_hash, [:prefix])

    expect(environment_hash).to eql({
      'PREFIX_VALUE_ONE' => 'value',
    })
  end
end
end
