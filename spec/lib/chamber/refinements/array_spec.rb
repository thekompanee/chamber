# frozen_string_literal: true

require 'rspectacular'
require 'chamber/refinements/array'

module   Chamber
module   Refinements
describe Array do
  using ::Chamber::Refinements::Array

  it 'can deep transform an array' do
    array_to_convert = [
                         1,
                         2,
                         {
                           key_one:   'one',
                           key_two:   'two',
                           key_three: {
                             key_four: 'four',
                           },
                         },
                       ]

    converted_hash = array_to_convert.deep_transform_keys { |k| k.to_s.upcase }

    expect(converted_hash).to eql [
                                    1,
                                    2,
                                    {
                                      'KEY_ONE'   => 'one',
                                      'KEY_TWO'   => 'two',
                                      'KEY_THREE' => {
                                        'KEY_FOUR' => 'four',
                                      },
                                    },
                                  ]
  end
end
end
end
