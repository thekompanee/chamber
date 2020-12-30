# frozen_string_literal: true

require 'rspectacular'
require 'chamber/refinements/array'
require 'chamber/refinements/hash'

module   Chamber
module   Refinements
describe Hash do
  using ::Chamber::Refinements::Array
  using ::Chamber::Refinements::Hash

  it 'can deep transform a hash' do
    hash_to_convert = {
      key_one:   'one',
      key_two:   'two',
      key_three: {
        key_four: 'four',
      },
    }

    converted_hash = hash_to_convert.deep_transform_keys { |k| k.to_s.upcase }

    expect(converted_hash).to \
      eql(
        'KEY_ONE'   => 'one',
        'KEY_TWO'   => 'two',
        'KEY_THREE' => {
          'KEY_FOUR' => 'four',
        },
      )
  end

  it 'can deep transform a hash with an array' do
    hash_to_convert = {
      key_one:   'one',
      key_two:   'two',
      key_three: {
        key_four: [
                    { key_five: 'five' },
                    { key_six:  'six' },
                    {
                      key_seven: [
                                   1,
                                   2,
                                   { key_eight: 'eight' },
                                 ],
                    },
                  ],
      },
    }

    converted_hash = hash_to_convert.deep_transform_keys { |k| k.to_s.upcase }

    expect(converted_hash).to \
      eql(
        'KEY_ONE'   => 'one',
        'KEY_TWO'   => 'two',
        'KEY_THREE' => {
          'KEY_FOUR' => [
                          { 'KEY_FIVE' => 'five' },
                          { 'KEY_SIX' =>  'six' },
                          {
                            'KEY_SEVEN' => [
                                             1,
                                             2,
                                             { 'KEY_EIGHT' => 'eight' },
                                           ],
                          },
                        ],
        },
      )
  end

  it 'can merge two Hashes' do
    hash_1 = {
      key_one:   'one',
      key_two:   'two',
      key_three: {
        key_four: {
          key_five:  'five',
          key_six:   'six',
          key_seven: [
                       1,
                       2,
                       { key_eight: 'eight' },
                     ],
        },
      },
    }

    hash_2 = {
      key_three: {
        key_four:     {
          key_nine: [
                      { key_ten:    'ten' },
                      { key_eleven: 'eleven' },
                    ],
        },
        key_twelve:   'twelve',
        key_thirteen: 13,
      },
    }

    transformed_hash = hash_1.deep_merge(hash_2)

    expect(transformed_hash).to \
      eql(
        key_one:   'one',
        key_two:   'two',
        key_three: {
          key_four:     {
            key_five:  'five',
            key_six:   'six',
            key_seven: [
                         1,
                         2,
                         { key_eight: 'eight' },
                       ],
            key_nine:  [
                         { key_ten:    'ten' },
                         { key_eleven: 'eleven' },
                       ],
          },
          key_twelve:   'twelve',
          key_thirteen: 13,
        },
      )
  end
end
end
end
