# frozen_string_literal: true
require 'rspectacular'
require 'chamber/filters/environment_filter'

module    Chamber
module    Filters
describe  EnvironmentFilter do
  context 'string variables' do
    it 'can extract data from the environment if an existing variable matches the ' \
       'composite key' do

      ENV['TEST_SETTING_GROUP_TEST_SETTING_LEVEL_TEST_SETTING'] = 'value 2'

      filtered_data = EnvironmentFilter.execute(data: {
                                                  test_setting_group: {
                                                    test_setting_level: {
                                                      test_setting: 'value 1',
                                                    },
                                                  },
                                                })

      test_setting  = filtered_data.test_setting_group.test_setting_level.test_setting

      expect(test_setting).to eql 'value 2'

      ENV.delete('TEST_SETTING_GROUP_TEST_SETTING_LEVEL_TEST_SETTING')
    end

    it 'does not affect items which are not stored in the environment' do
      ENV['TEST_SETTING_GROUP_TEST_SETTING_LEVEL_TEST_SETTING'] = 'value 2'

      filtered_data = EnvironmentFilter.execute(data: {
                                                  test_setting_group: {
                                                    test_setting_level: {
                                                      test_setting:    'value 1',
                                                      another_setting: 'value 3',
                                                    },
                                                  },
                                                })

      another_setting = filtered_data.test_setting_group.test_setting_level.another_setting

      expect(another_setting).to eql 'value 3'

      ENV.delete('TEST_SETTING_GROUP_TEST_SETTING_LEVEL_TEST_SETTING')
    end

    it 'can extract an array from the environment if an existing set of' \
       'variables match the composite key' do
      ENV['TEST_SETTING_GROUP_TEST_SETTING_LEVEL_TEST_ARRAY_0'] = 'value 4'
      ENV['TEST_SETTING_GROUP_TEST_SETTING_LEVEL_TEST_ARRAY_1'] = 'value 5'

      filtered_data = EnvironmentFilter.execute(data: {
                                                  test_setting_group: {
                                                    test_setting_level: {
                                                      test_array: [
                                                        'value 1',
                                                        'value 2',
                                                        'value 3'
                                                      ]
                                                    },
                                                  },
                                                })

      test_array  = filtered_data.test_setting_group.test_setting_level.test_array

      expect(test_array).to eql [ 'value 4', 'value 5' ]

      ENV.delete('TEST_SETTING_GROUP_TEST_SETTING_LEVEL_TEST_ARRAY_0')
      ENV.delete('TEST_SETTING_GROUP_TEST_SETTING_LEVEL_TEST_ARRAY_1')
    end

    it 'can replace an array in numerical order' do
      ENV['TEST_SETTING_GROUP_TEST_SETTING_LEVEL_TEST_ARRAY_0'] = 'value 4'
      ENV['TEST_SETTING_GROUP_TEST_SETTING_LEVEL_TEST_ARRAY_2'] = 'value 6'
      ENV['TEST_SETTING_GROUP_TEST_SETTING_LEVEL_TEST_ARRAY_1'] = 'value 5'

      filtered_data = EnvironmentFilter.execute(data: {
                                                  test_setting_group: {
                                                    test_setting_level: {
                                                      test_array: [
                                                        'value 1',
                                                        'value 2',
                                                        'value 3'
                                                      ]
                                                    },
                                                  },
                                                })

      test_array  = filtered_data.test_setting_group.test_setting_level.test_array

      expect(test_array).to eql [ 'value 4', 'value 5', 'value 6' ]

      ENV.delete('TEST_SETTING_GROUP_TEST_SETTING_LEVEL_TEST_ARRAY_0')
      ENV.delete('TEST_SETTING_GROUP_TEST_SETTING_LEVEL_TEST_ARRAY_1')
      ENV.delete('TEST_SETTING_GROUP_TEST_SETTING_LEVEL_TEST_ARRAY_2')

    end

    it 'can replace an array with an empty array' do
      ENV['TEST_SETTING_GROUP_TEST_SETTING_LEVEL_TEST_ARRAY'] = '0'

      filtered_data = EnvironmentFilter.execute(data: {
                                                  test_setting_group: {
                                                    test_setting_level: {
                                                      test_array: [
                                                        'value 1',
                                                        'value 2',
                                                        'value 3'
                                                      ]
                                                    },
                                                  },
                                                })

      test_array  = filtered_data.test_setting_group.test_setting_level.test_array

      expect(test_array).to eql [ ]

      ENV.delete('TEST_SETTING_GROUP_TEST_SETTING_LEVEL_TEST_ARRAY')
    end

    it 'defaults to strings in an empty array' do
      ENV['TEST_SETTING_GROUP_TEST_SETTING_LEVEL_TEST_ARRAY_0'] = '123'

      filtered_data = EnvironmentFilter.execute(data: {
                                                  test_setting_group: {
                                                    test_setting_level: {
                                                      test_array: []
                                                    },
                                                  },
                                                })

      test_array  = filtered_data.test_setting_group.test_setting_level.test_array

      expect(test_array[0]).to be_a String

      ENV.delete('TEST_SETTING_GROUP_TEST_SETTING_LEVEL_TEST_ARRAY')
    end
  end

  context 'integer variables' do
    it 'can extract an integer from the environment if an existing variable' \
       'matches the composite key' do

      ENV['TEST_SETTING_GROUP_TEST_SETTING_LEVEL_TEST_SETTING'] = '2'

      filtered_data = EnvironmentFilter.execute(data: {
                                                  test_setting_group: {
                                                    test_setting_level: {
                                                      test_setting: 1,
                                                    },
                                                  },
                                                })

      test_setting  = filtered_data.test_setting_group.test_setting_level.test_setting

      expect(test_setting).to eql 2

      ENV.delete('TEST_SETTING_GROUP_TEST_SETTING_LEVEL_TEST_SETTING')
    end

    it 'does not affect integers that are not stored in the environment' do

      ENV['TEST_SETTING_GROUP_TEST_SETTING_LEVEL_TEST_SETTING'] = '2'

      filtered_data = EnvironmentFilter.execute(data: {
                                                  test_setting_group: {
                                                    test_setting_level: {
                                                      test_setting: 1,
                                                      another_setting: 3
                                                    },
                                                  },
                                                })

      another_setting  = filtered_data.test_setting_group.test_setting_level.another_setting

      expect(another_setting).to eql 3

      ENV.delete('TEST_SETTING_GROUP_TEST_SETTING_LEVEL_TEST_SETTING')
    end

    it 'can extract an array from the environment if an existing set of' \
       'variables match the composite key' do
      ENV['TEST_SETTING_GROUP_TEST_SETTING_LEVEL_TEST_ARRAY_0'] = '4'
      ENV['TEST_SETTING_GROUP_TEST_SETTING_LEVEL_TEST_ARRAY_1'] = '5'

      filtered_data = EnvironmentFilter.execute(data: {
                                                  test_setting_group: {
                                                    test_setting_level: {
                                                      test_array: [ 1, 2, 3 ]
                                                    },
                                                  },
                                                })

      test_array  = filtered_data.test_setting_group.test_setting_level.test_array

      expect(test_array).to eql [ 4, 5 ]

      ENV.delete('TEST_SETTING_GROUP_TEST_SETTING_LEVEL_TEST_ARRAY_0')
      ENV.delete('TEST_SETTING_GROUP_TEST_SETTING_LEVEL_TEST_ARRAY_1')
    end

    it 'can replace an array with an empty array' do
      ENV['TEST_SETTING_GROUP_TEST_SETTING_LEVEL_TEST_ARRAY'] = '0'

      filtered_data = EnvironmentFilter.execute(data: {
                                                  test_setting_group: {
                                                    test_setting_level: {
                                                      test_array: [ 1, 2, 3 ]
                                                    },
                                                  },
                                                })

      test_array  = filtered_data.test_setting_group.test_setting_level.test_array

      expect(test_array).to eql [ ]

      ENV.delete('TEST_SETTING_GROUP_TEST_SETTING_LEVEL_TEST_ARRAY')
    end
  end

  context 'float variables' do
    it 'can extract a float from the environment if an existing variable' \
       'matches the composite key' do

      ENV['TEST_SETTING_GROUP_TEST_SETTING_LEVEL_TEST_SETTING'] = '2.3'

      filtered_data = EnvironmentFilter.execute(data: {
                                                  test_setting_group: {
                                                    test_setting_level: {
                                                      test_setting: 1.2,
                                                    },
                                                  },
                                                })

      test_setting  = filtered_data.test_setting_group.test_setting_level.test_setting

      expect(test_setting).to eql 2.3

      ENV.delete('TEST_SETTING_GROUP_TEST_SETTING_LEVEL_TEST_SETTING')
    end

    it 'does not affect integers that are not stored in the environment' do

      ENV['TEST_SETTING_GROUP_TEST_SETTING_LEVEL_TEST_SETTING'] = '2.3'

      filtered_data = EnvironmentFilter.execute(data: {
                                                  test_setting_group: {
                                                    test_setting_level: {
                                                      test_setting: 1.2,
                                                      another_setting: 3.4
                                                    },
                                                  },
                                                })

      another_setting  = filtered_data.test_setting_group.test_setting_level.another_setting

      expect(another_setting).to eql 3.4

      ENV.delete('TEST_SETTING_GROUP_TEST_SETTING_LEVEL_TEST_SETTING')
    end

    it 'can extract an array from the environment if an existing set of' \
       'variables match the composite key' do
      ENV['TEST_SETTING_GROUP_TEST_SETTING_LEVEL_TEST_ARRAY_0'] = '4.2'
      ENV['TEST_SETTING_GROUP_TEST_SETTING_LEVEL_TEST_ARRAY_1'] = '5.3'

      filtered_data = EnvironmentFilter.execute(data: {
                                                  test_setting_group: {
                                                    test_setting_level: {
                                                      test_array: [ 1.9, 2.8, 3.7 ]
                                                    },
                                                  },
                                                })

      test_array  = filtered_data.test_setting_group.test_setting_level.test_array

      expect(test_array).to eql [ 4.2, 5.3 ]

      ENV.delete('TEST_SETTING_GROUP_TEST_SETTING_LEVEL_TEST_ARRAY_0')
      ENV.delete('TEST_SETTING_GROUP_TEST_SETTING_LEVEL_TEST_ARRAY_1')
    end

    it 'can replace an array with an empty array' do
      ENV['TEST_SETTING_GROUP_TEST_SETTING_LEVEL_TEST_ARRAY'] = '0'

      filtered_data = EnvironmentFilter.execute(data: {
                                                  test_setting_group: {
                                                    test_setting_level: {
                                                      test_array: [ 1.9, 2.8, 3.7 ]
                                                    },
                                                  },
                                                })

      test_array  = filtered_data.test_setting_group.test_setting_level.test_array

      expect(test_array).to eql [ ]

      ENV.delete('TEST_SETTING_GROUP_TEST_SETTING_LEVEL_TEST_ARRAY')
    end
  end
end
end
end
