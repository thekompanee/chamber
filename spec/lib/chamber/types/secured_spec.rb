# frozen_string_literal: true

require 'rspectacular'
require 'active_support/hash_with_indifferent_access'
require 'chamber/types/secured'

module    Chamber
module    Types
describe  Secured do
  BASE64_STRING_PATTERN = %r{[A-Za-z0-9\+/]{342}==}

  subject(:secured_type) do
    Secured.new(decryption_keys: './spec/spec_key',
                encryption_keys: './spec/spec_key.pub')
  end

  it 'allows strings to be cast from the user' do
    json_string = '{ "hello": "there", "whatever": 3 }'
    secured     = secured_type.cast(json_string)

    expect(secured).to eql('hello' => 'there', 'whatever' => 3)
  end

  it 'allows hashes to be cast from a user' do
    json_hash = { 'hello' => 'there', 'whatever' => 3 }
    secured   = secured_type.cast(json_hash)

    expect(secured).to eql('hello' => 'there', 'whatever' => 3)
  end

  it 'allows nils to be cast from a user' do
    secured = secured_type.cast(nil)

    expect(secured).to be_nil
  end

  it 'fails if passed something that it cannot be cast' do
    expect { secured_type.cast(3) }.to \
    raise_error(ArgumentError).
      with_message('Any attributes encrypted with Chamber must ' \
                 'be either a Hash or a valid JSON string')
  end

  it 'can deserialize a hash' do
    json_string = '{' \
                    '"_secure_hello":"cpsTajQ/28E0YLQBpJ2tORnLSc6wliCqrmMzU0QfQZJlUWf' \
                                     'Q1yuev2xLsX56o5QkuJiqaspH9W68qXDC17UqcV0pB0y75d' \
                                     '6ttQZbk3p9QbYgWGZOVlHEA8eJIqDUzisShrrOo+nSin6QK' \
                                     'UqizSjqhQC3Ii7CjTpMOK5RVc2y34vsVvYoJaqz5IYUEatA' \
                                     'XxzHsQ5tkcqy++a9LTJVFOt+ug+mTCstNJHW2sUK9L1XrbD' \
                                     '2+KwUNkImCbhl6qeA+4CeVXMFgcpxjaawg5cQCgfSPj8gSy' \
                                     'pisbID59P0QVXRDQTdncrRv7q16RLmTqKI0xhNGevreFkNG' \
                                     'LAtSQjFRYfAQA==",' \
                    '"whatever":3' \
                  '}'
    secured     = secured_type.deserialize(json_string)

    expect(secured).to eql('_secure_hello' => 'there', 'whatever' => 3)
  end

  # rubocop:disable Metrics/LineLength
  it 'can serialize a hash' do
    json_hash = { '_secure_hello' => 'there', 'whatever' => 3 }
    secured   = secured_type.serialize(json_hash)

    expect(secured).to be_a String
    expect(secured).to match(/{\"_secure_hello\":\"#{BASE64_STRING_PATTERN}\",\"whatever\":3}/)
  end
  # rubocop:enable Metrics/LineLength
end
end
end
