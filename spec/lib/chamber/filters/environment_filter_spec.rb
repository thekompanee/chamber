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
  end
end
end
end
