require 'rspectacular'
require 'chamber/filters/boolean_conversion_filter'

module    Chamber
module    Filters
describe  BooleanConversionFilter do
  it 'can convert string boolean values into TrueClass and FalseClass even if they are deeply nested' do
    filtered_data = BooleanConversionFilter.execute(
                                              data: {
                                                true_boolean:   'true',
                                                boolean_group:  {
                                                  yes_boolean:        'yes',
                                                  t_boolean:          't',
                                                  non_boolean:        'hello',
                                                  sub_boolean_group:  {
                                                    false_boolean:      'false',
                                                    no_boolean:         'no',
                                                    nilly:              nil,
                                                    non_boolean:        3, },
                                                  f_boolean:          'f',
                                                  non_boolean:        Time.utc(2012, 8, 1),
                                                  nilly:              nil, },
                                                false_boolean:        'false',
                                                nilly:                nil,
                                                non_boolean:          [1, 2, 3] })

    expect(filtered_data).to eql(true_boolean:       true,
                                  boolean_group:      {
                                    yes_boolean:        true,
                                    t_boolean:          true,
                                    non_boolean:        'hello',
                                    sub_boolean_group:  {
                                      false_boolean:      false,
                                      no_boolean:         false,
                                      nilly:              nil,
                                      non_boolean:        3, },
                                    f_boolean:          false,
                                    non_boolean:        Time.utc(2012, 8, 1),
                                    nilly:              nil, },
                                  false_boolean:        false,
                                  nilly:                nil,
                                  non_boolean:          [1, 2, 3])
  end
end
end
end
