require 'rspectacular'
require 'chamber/context_resolver'

module    Chamber
module    Commands
describe  ContextResolver do
  let(:rails_2_path) { ::File.expand_path('../../../rails-2-test', __FILE__) }
  let(:rails_3_path) { ::File.expand_path('../../../rails-3-test', __FILE__) }
  let(:rails_4_path) { ::File.expand_path('../../../rails-4-test', __FILE__) }

  it 'does not attempt to do any resolution if all valid options are passed in' do
    options = ContextResolver.resolve(basepath:   'my_path',
                                      namespaces: 'ns')

    expect(options[:basepath].to_s).to  eql 'my_path'
    expect(options[:namespaces]).to     eql 'ns'
  end

  it 'does not attempt to do any resolution if files are passed in in place of a ' \
     'basepath' do

    options = ContextResolver.resolve(files:      'my_files',
                                      namespaces: 'ns')

    expect(options[:files]).to          eql 'my_files'
    expect(options[:namespaces]).to     eql 'ns'
  end

  it 'defaults the basepath to the rootpath if none is explicitly set' do
    options = ContextResolver.resolve(rootpath:   './app',
                                      namespaces: 'ns')

    expect(options[:basepath].to_s).to  eql './app'
  end

  it 'always sets the basepath to a Pathname even if it is passed in as a String' do
    options = ContextResolver.resolve(basepath: './app')

    expect(options[:basepath]).to be_a Pathname
  end

  it 'sets the default files if none are passed in' do
    options = ContextResolver.resolve(basepath: './app')

    expect(options[:files].map(&:to_s)).to eql ['./app/settings*.yml',
                                                './app/settings']
  end

  it 'can handle if keys are passed as strings' do
    options = ContextResolver.resolve('files'      => 'my_files',
                                      'namespaces' => 'ns')

    expect(options[:files]).to          eql 'my_files'
    expect(options[:namespaces]).to     eql 'ns'
  end

  it 'sets the rootpath to the current working directory if none is passed in' do
    allow(Pathname).to  receive(:pwd).
                        and_return('my_dir')

    options = ContextResolver.resolve

    expect(options[:rootpath].to_s).to  eql 'my_dir'
  end

  it 'sets the encryption key to the default if not passed in' do
    options = ContextResolver.resolve(rootpath: rails_3_path)

    expect(options[:encryption_key].to_s).to  include 'rails-3-test/.chamber.pub.pem'
  end

  it 'sets the decryption key to the default if not passed in' do
    options = ContextResolver.resolve(rootpath: rails_3_path)

    expect(options[:decryption_key].to_s).to  include 'rails-3-test/.chamber.pem'
  end

  it 'does not set the encryption key if the keyfile does not exist' do
    options = ContextResolver.resolve(rootpath: './app')

    expect(options[:encryption_key]).to be_nil
  end

  it 'does not set the decryption key if the keyfile does not exist' do
    options = ContextResolver.resolve(rootpath: './app')

    expect(options[:decryption_key]).to be_nil
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
end
end
end
