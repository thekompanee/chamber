# frozen_string_literal: true

require 'rspectacular'
require 'chamber/context_resolver'

module    Chamber
module    Commands
describe  ContextResolver do
  let(:rails_2_path)      { ::File.expand_path('../../../rails-2-test', __FILE__) }
  let(:rails_3_path)      { ::File.expand_path('../../../rails-3-test', __FILE__) }
  let(:rails_4_path)      { ::File.expand_path('../../../rails-4-test', __FILE__) }
  let(:rails_engine_path) { ::File.expand_path('../../../rails-engine-test', __FILE__) }

  # rubocop:disable RSpec/InstanceVariable
  before(:each) { @old_chamber_key = ENV.delete('CHAMBER_KEY') }

  after(:each)  { ENV['CHAMBER_KEY'] = @old_chamber_key }
  # rubocop:enable RSpec/InstanceVariable

  it 'does not attempt to do any resolution if all valid options are passed in' do
    options = ContextResolver.resolve(basepath:   'my_path',
                                      namespaces: %w{ns})

    expect(options[:basepath].to_s).to  eql 'my_path'
    expect(options[:namespaces]).to     eql %w{ns}
  end

  it 'does not attempt to do any resolution if files are passed in in place of a ' \
     'basepath' do

    options = ContextResolver.resolve(files:      'my_files',
                                      namespaces: %w{ns})

    expect(options[:files]).to          eql 'my_files'
    expect(options[:namespaces]).to     eql %w{ns}
  end

  it 'defaults the basepath to the rootpath if none is explicitly set' do
    options = ContextResolver.resolve(rootpath:   './app',
                                      namespaces: %w{ns})

    expect(options[:basepath].to_s).to eql './app'
  end

  it 'always sets the basepath to a Pathname even if it is passed in as a String' do
    options = ContextResolver.resolve(basepath: './app')

    expect(options[:basepath]).to be_a Pathname
  end

  it 'sets the default files if none are passed in' do
    options = ContextResolver.resolve(basepath: './app')

    expect(options[:files].map(&:to_s)).to eql [
                                                 './app/settings*.yml',
                                                 './app/settings',
                                               ]
  end

  it 'sets the rootpath to the current working directory if none is passed in' do
    allow(Pathname).to  receive(:pwd).
                          and_return('my_dir')

    options = ContextResolver.resolve

    expect(options[:rootpath].to_s).to eql 'my_dir'
  end

  it 'sets the encryption key to the default if not passed in' do
    options = ContextResolver.resolve(rootpath: rails_3_path)

    expect(options[:encryption_keys][:__default]).to eql <<-HEREDOC
-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAvYcqkBjBLhSaTKOCMoq+
ZxcuxTaA5UQpf/vDXbOiI871+6x7yKbTr+Xr9oFDvFldyvUFiK6LX0rj/jgLnaTB
sLyXjH46dOmiPUO3k/QvDmRKN8zvl4x9T7YZKuoEkxZwE3T3MxKPmBorKGv/22Vb
KocqkGGgx9gKIvSfxVXfTMfcvTDrFllm1bCaXEVGcRAknJg94ul2yMgqmYA2KJcP
y2naped90yzv0A7c/UI5zjBcJPgkum79aDTSv095yl+Pk+5JM2jD85x3ph3ij++L
dAXJ1fBJrV1H39UJ4A6yOupEG3+QsZTPDXkBBnX8+mWXYCClI/GF6iA/G3njeMqU
fQIDAQAB
-----END PUBLIC KEY-----
    HEREDOC
  end

  it 'sets the decryption key to the default if not passed in' do
    options      = ContextResolver.resolve(rootpath: rails_3_path)
    key_contents = ::File.read(rails_3_path + '/.chamber.pem')

    expect(options[:decryption_keys][:__default]).to eql key_contents
  end

  it 'sets the decryption key to the value of the CHAMBER_KEY if available' do
    ENV['CHAMBER_KEY'] = 'my key'

    options = ContextResolver.resolve(rootpath: 'my_path')

    expect(options[:decryption_keys][:__default]).to eql 'my key'

    ENV['CHAMBER_KEY'] = nil
  end

  it 'does not set the encryption key if the keyfile does not exist' do
    options = ContextResolver.resolve(rootpath: './app')

    expect(options[:encryption_keys]).to eql({})
  end

  it 'does not set the decryption key if the keyfile does not exist' do
    options = ContextResolver.resolve(rootpath: './app')

    expect(options[:decryption_keys]).to eql({})
  end

  it 'unfurls namespace hashes if they are passed in' do
    options = ContextResolver.resolve(namespaces: {
                                        environment: 'foo',
                                        hostname:    'bar',
                                      })

    expect(options[:namespaces]).to eql %w{foo bar}
  end

  it 'processing lambdas and procs if they are passed in as namespaces' do
    options = ContextResolver.resolve(namespaces: {
                                        environment: -> { 'foo' },
                                        hostname:    -> { 'bar' },
                                      })

    expect(options[:namespaces]).to eql %w{foo bar}
  end

  it 'sets the information to a Rails preset even if it is not pointing to a Rails app' do
    options = ContextResolver.resolve(rootpath: './app',
                                      preset:   'rails')

    expect(options[:basepath].to_s).to  include './app/config'
    expect(options[:namespaces]).to     eql     []
  end

  it 'sets the information to a Rails preset when the rootpath is a Rails app' do
    allow(Socket).to receive(:gethostname).and_return 'my_host'

    options = ContextResolver.resolve(rootpath: rails_3_path,
                                      preset:   'rails')

    expect(options[:basepath].to_s).to  include 'rails-3-test/config'
    expect(options[:namespaces]).to     eql     %w{development my_host}
  end

  it 'removes dashes and dots from hostnames for the purposes of namespace resolution' do
    allow(Socket).to receive(:gethostname).and_return 'my-host.com'

    options = ContextResolver.resolve(rootpath: rails_3_path,
                                      preset:   'rails')

    expect(options[:namespaces]).to eql %w{development myhostcom}
  end

  it 'sets the basepath if inside a Rails 2 project' do
    allow(Socket).to receive(:gethostname).and_return 'my_host'

    options = ContextResolver.resolve(rootpath: rails_2_path)

    expect(options[:basepath].to_s).to  include 'rails-2-test/config'
    expect(options[:namespaces]).to     eql     %w{development my_host}
  end

  it 'sets the basepath if inside a Rails 3 project' do
    allow(Socket).to receive(:gethostname).and_return 'my_host'

    options = ContextResolver.resolve(rootpath: rails_3_path)

    expect(options[:basepath].to_s).to  include 'rails-3-test/config'
    expect(options[:namespaces]).to     eql     %w{development my_host}
  end

  it 'sets the basepath if inside a Rails 4 project' do
    allow(Socket).to receive(:gethostname).and_return 'my_host'

    options = ContextResolver.resolve(rootpath: rails_4_path)

    expect(options[:basepath].to_s).to  include 'rails-4-test/config'
    expect(options[:namespaces]).to     eql     %w{development my_host}
  end

  it 'sets the basepath if inside a Rails engine' do
    allow(Socket).to receive(:gethostname).and_return 'my_host'

    options = ContextResolver.resolve(rootpath: rails_engine_path)

    expect(options[:rootpath].to_s).to  include 'rails-engine-test/spec/dummy'
    expect(options[:basepath].to_s).to  include 'rails-engine-test/spec/dummy/config'
    expect(options[:namespaces]).to     eql     %w{development my_host}
  end
end
end
end
