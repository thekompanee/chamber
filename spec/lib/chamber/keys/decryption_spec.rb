# frozen_string_literal: true

require 'rspectacular'
require 'chamber/keys/decryption'

module    Chamber
module    Keys
describe  Decryption do
  it 'can find default keys by reading files' do
    key = Decryption.resolve(rootpath:   'spec/fixtures/keys/',
                             namespaces: [],
                             filenames:  'spec/fixtures/keys/.chamber.pem')

    expect(key).to eql(default: "default private key\n")
  end

  it 'can find default keys by reading the environment' do
    ENV['CHAMBER_KEY'] = 'environment private key'

    key = Decryption.resolve(rootpath:   'spec/fixtures/keys/',
                             namespaces: [],
                             filenames:  'spec/fixtures/.chamber.pem')

    expect(key).to eql(default: 'environment private key')

    ENV.delete('CHAMBER_KEY')
  end

  it 'can find namespaced key files by reading files' do
    key = Decryption.resolve(rootpath:   'spec/fixtures/keys/',
                             namespaces: [],
                             filenames:  'spec/fixtures/keys/.chamber.development.pem')

    expect(key).to eql(development: "development private key\n")
  end

  it 'can find namespaced key files by reading the environment' do
    ENV['CHAMBER_DEVELOPMENT_KEY'] = 'environment private key'

    key = Decryption.resolve(rootpath:   'spec/fixtures/keys/',
                             namespaces: [],
                             filenames:  'spec/fixtures/.chamber.development.pem')

    expect(key).to eql(development: 'environment private key')

    ENV.delete('CHAMBER_DEVELOPMENT_KEY')
  end

  it 'can generate generic key filenames from namespaces' do
    key = Decryption.resolve(rootpath:   'spec/fixtures/keys/',
                             namespaces: %w{test production},
                             filenames:  %w{
                                           spec/fixtures/keys/.chamber.development.pem
                                         })

    expect(key).to eql(
                     development: "development private key\n",
                     test:        "test private key\n",
                     production:  "production private key\n",
                   )
  end

  it 'can lookup generic key from namespaces by reading the environment' do
    ENV['CHAMBER_MISSING_KEY'] = 'environment private key'

    key = Decryption.resolve(rootpath:   'spec/fixtures/keys/',
                             namespaces: %w{test missing production},
                             filenames:  [])

    expect(key).to eql(
                     missing:    'environment private key',
                     production: "production private key\n",
                     test:       "test private key\n",
                   )

    ENV.delete('CHAMBER_MISSING_KEY')
  end

  it 'removes duplicates from the filenames and namespaces if necessary' do
    key = Decryption.resolve(rootpath:   'spec/fixtures/keys/',
                             namespaces: %w{test production},
                             filenames:  %w{
                                           spec/fixtures/keys/.chamber.development.pem
                                           spec/fixtures/keys/.chamber.test.pem
                                         })

    expect(key).to eql(
                     development: "development private key\n",
                     test:        "test private key\n",
                     production:  "production private key\n",
                   )
  end

  it 'can find multiple keys' do
    key = Decryption.resolve(
            rootpath:   'spec/fixtures/keys/',
            namespaces: [],
            filenames:  [
                          'spec/fixtures/keys/.chamber.development.pem',
                          'spec/fixtures/keys/.chamber.pem',
                          'spec/fixtures/keys/.chamber.production.pem',
                          'spec/fixtures/keys/.chamber.test.pem',
                        ],
          )

    expect(key).to eql(
                        default:     "default private key\n",
                        development: "development private key\n",
                        production:  "production private key\n",
                        test:        "test private key\n",
                      )
  end

  it 'skips a key if it cannot be found' do
    key = Decryption.resolve(
            rootpath:   'spec/fixtures/keys/',
            namespaces: %w{foobar},
            filenames:  [
                          'spec/fixtures/keys/.chamber.development.pem',
                          'spec/fixtures/keys/.chamber.pem',
                          'spec/fixtures/keys/.chamber.staging.pem',
                          'spec/fixtures/keys/.chamber.test.pem',
                        ],
          )

    expect(key).to eql(
                        default:     "default private key\n",
                        development: "development private key\n",
                        test:        "test private key\n",
                      )
  end
end
end
end
