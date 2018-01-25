# frozen_string_literal: true

require 'rspectacular'
require 'chamber/keys/encryption'

module    Chamber
module    Keys
describe  Encryption do
  it 'can find default keys by reading files' do
    key = Encryption.resolve(rootpath:   'spec/fixtures/keys/',
                             namespaces: [],
                             filenames:  'spec/fixtures/keys/.chamber.pub.pem')

    expect(key).to eql(__default: "default public key\n")
  end

  it 'always includes the default key even if nothing is passed in' do
    key = Encryption.resolve(rootpath:   'spec/fixtures/keys/',
                             namespaces: [],
                             filenames:  [])

    expect(key).to eql(__default: "default public key\n")
  end

  it 'can find default keys by reading the environment' do
    ENV['CHAMBER_PUBLIC_KEY'] = 'environment public key'

    key = Encryption.resolve(rootpath:   'spec/fixtures/',
                             namespaces: [],
                             filenames:  'spec/fixtures/.chamber.pub.pem')

    expect(key).to eql(__default: 'environment public key')

    ENV.delete('CHAMBER_PUBLIC_KEY')
  end

  it 'can find namespaced key files by reading files' do
    key = Encryption.resolve(rootpath:   'spec/fixtures/keys/',
                             namespaces: [],
                             filenames:  'spec/fixtures/keys/.chamber.test.pub.pem')

    expect(key).to eql(test:    "test public key\n")
  end

  it 'can find namespaced key files by reading the environment' do
    ENV['CHAMBER_DEVELOPMENT_PUBLIC_KEY'] = 'environment public key'

    key = Encryption.resolve(rootpath:   'spec/fixtures/keys/',
                             namespaces: [],
                             filenames:  'spec/fixtures/.chamber.development.pub.pem')

    expect(key).to eql(development: 'environment public key')

    ENV.delete('CHAMBER_DEVELOPMENT_PUBLIC_KEY')
  end

  it 'can generate generic key filenames from namespaces' do
    key = Encryption.resolve(rootpath:   'spec/fixtures/keys/',
                             namespaces: %w{test production},
                             filenames:  %w{
                                           spec/fixtures/keys/.chamber.development.pub.pem
                                         })

    expect(key).to eql(
                     development: "development public key\n",
                     test:        "test public key\n",
                     production:  "production public key\n",
                   )
  end

  it 'can lookup generic key from namespaces by reading the environment' do
    ENV['CHAMBER_MISSING_PUBLIC_KEY'] = 'environment public key'

    key = Encryption.resolve(rootpath:   'spec/fixtures/keys/',
                             namespaces: %w{test missing production},
                             filenames:  [])

    expect(key).to eql(
                     __default:  "default public key\n",
                     missing:    'environment public key',
                     production: "production public key\n",
                     test:       "test public key\n",
                   )

    ENV.delete('CHAMBER_MISSING_PUBLIC_KEY')
  end

  it 'removes duplicates from the filenames and namespaces if necessary' do
    key = Encryption.resolve(rootpath:   'spec/fixtures/keys/',
                             namespaces: %w{test production},
                             filenames:  %w{
                                           spec/fixtures/keys/.chamber.development.pub.pem
                                           spec/fixtures/keys/.chamber.test.pub.pem
                                         })

    expect(key).to eql(
                     development: "development public key\n",
                     test:        "test public key\n",
                     production:  "production public key\n",
                   )
  end

  it 'ignores non-standard key name namespace detection' do
    key = Encryption.resolve(rootpath:   'spec/fixtures/keys/',
                             namespaces: [],
                             filenames:  %w{
                                           spec/fixtures/keys/.foo.development.pub.pem
                                         })

    expect(key).to eql(
                     __default: "non-standard public key\n",
                   )
  end

  it 'can find multiple keys' do
    key = Encryption.resolve(
            rootpath:   'spec/fixtures/keys/',
            namespaces: [],
            filenames:  [
                          'spec/fixtures/keys/.chamber.development.pub.pem',
                          'spec/fixtures/keys/.chamber.pub.pem',
                          'spec/fixtures/keys/.chamber.production.pub.pem',
                          'spec/fixtures/keys/.chamber.test.pub.pem',
                          'spec/fixtures/keys/.chamber.example-host.com.pub.pem',
                        ],
          )

    expect(key).to eql(
                        :"example-host.com" => "example-host.com public key\n",
                        __default:   "default public key\n",
                        development: "development public key\n",
                        production:  "production public key\n",
                        test:        "test public key\n",
                      )
  end

  it 'skips a key if it cannot be found' do
    key = Encryption.resolve(
            rootpath:   'spec/fixtures/keys/',
            namespaces: %w{foobar},
            filenames:  [
                          'spec/fixtures/keys/.chamber.development.pub.pem',
                          'spec/fixtures/keys/.chamber.pub.pem',
                          'spec/fixtures/keys/.chamber.staging.pub.pem',
                          'spec/fixtures/keys/.chamber.test.pub.pem',
                        ],
          )

    expect(key).to eql(
                        __default:   "default public key\n",
                        development: "development public key\n",
                        test:        "test public key\n",
                      )
  end
end
end
end
