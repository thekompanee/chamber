require 'rspectacular'
require 'chamber/file_set'
require 'fileutils'


class     Chamber
describe  FileSet do
  before(:each) { FileUtils.mkdir '/tmp/settings' unless ::File.exist? '/tmp/settings' }
  after(:each)  { FileUtils.rm_rf '/tmp/settings' if     ::File.exist? '/tmp/settings' }

  it 'can consider directories containing YAML files' do
    ::File.new('/tmp/settings/some_settings_file.yml', 'w+')
    ::File.new('/tmp/settings/another_settings_file.yml', 'w+')

    file_set = FileSet.new files: '/tmp/settings'

    expect(file_set.send(:files)).to eql  Set[
                                            Pathname.new('/tmp/settings/some_settings_file.yml'),
                                            Pathname.new('/tmp/settings/another_settings_file.yml'),
                                          ]

    ::FileUtils.rm_rf('/tmp/settings')
  end

  it 'can consider globs of files' do
    ::File.new('/tmp/settings/some_settings_file.yml', 'w+')
    ::File.new('/tmp/settings/another_settings_file.yml', 'w+')

    file_set = FileSet.new files: '/tmp/settings/*.yml'

    expect(file_set.send(:files)).to eql  Set[
                                            Pathname.new('/tmp/settings/some_settings_file.yml'),
                                            Pathname.new('/tmp/settings/another_settings_file.yml'),
                                          ]

    ::FileUtils.rm_rf('/tmp/settings')
  end

  it 'can consider namespaced files' do
    ::File.new('/tmp/settings/settings-blue.yml', 'w+')

    file_set = FileSet.new files:      '/tmp/settings/settings-blue.yml',
                           namespaces: ['blue']

    expect(file_set.send(:files)).to eql Set[Pathname.new('/tmp/settings/settings-blue.yml')]

    ::FileUtils.rm_f('/tmp/settings/settings-blue.yml')
  end

  it 'does not consider namespaced files which are not relevant' do
    ::File.new('/tmp/settings/settings-blue.yml', 'w+')

    file_set = FileSet.new files:      '/tmp/settings/settings-blue.yml',
                           namespaces: ['green']

    expect(file_set.send(:files)).to be_empty

    ::FileUtils.rm_f('/tmp/settings/settings-blue.yml')
  end

  it 'removes any duplicate files' do
    ::File.new('/tmp/settings.yml', 'w+')

    file_set = FileSet.new files: [
                                    '/tmp/settings.yml',
                                    '/tmp/settings.yml',
                                  ]

    expect(file_set.send(:files)).to eql Set[Pathname.new('/tmp/settings.yml')]

    ::FileUtils.rm_f('/tmp/settings.yml')
  end

  it 'can consider multiple file paths' do
    ::File.new('/tmp/settings.yml', 'w+')
    ::File.new('/tmp/settings/new_file.yml', 'w+')

    file_set = FileSet.new files: [
                                    '/tmp/settings.yml',
                                    '/tmp/settings/*.yml',
                                  ]

    expect(file_set.send(:files)).to eql  Set[
                                            Pathname.new('/tmp/settings.yml'),
                                            Pathname.new('/tmp/settings/new_file.yml'),
                                          ]

    ::FileUtils.rm_rf('/tmp/settings*')
  end

  it 'can consider file paths as Pathnames' do
    ::File.new('/tmp/settings.yml', 'w+')

    file_set = FileSet.new files: Pathname.new('/tmp/settings.yml')

    expect(file_set.send(:files)).to eql  Set[
                                            Pathname.new('/tmp/settings.yml'),
                                          ]

    ::FileUtils.rm_rf('/tmp/settings*')
  end

  it 'can consider multiple namespaced files in the order the namespaces are specified' do
    ::File.new('/tmp/settings/settings-blue.yml', 'w+')
    ::File.new('/tmp/settings/settings-green.yml', 'w+')

    file_set = FileSet.new files:      '/tmp/settings/settings*.yml',
                           namespaces: ['blue', 'green']

    expect(file_set.send(:files)).to eql  Set[
                                            Pathname.new('/tmp/settings/settings-blue.yml'),
                                            Pathname.new('/tmp/settings/settings-green.yml'),
                                          ]

    file_set = FileSet.new files:      '/tmp/settings/settings*.yml',
                           namespaces: ['green', 'blue']

    expect(file_set.send(:files)).to eql  Set[
                                            Pathname.new('/tmp/settings/settings-green.yml'),
                                            Pathname.new('/tmp/settings/settings-blue.yml'),
                                          ]

    ::FileUtils.rm_f('/tmp/settings/settings*.yml')
  end

  it 'considers the generic file prior to any namespaced files' do
    ::File.new('/tmp/settings.yml', 'w+')
    ::File.new('/tmp/settings-blue.yml', 'w+')

    file_set = FileSet.new files:      '/tmp/settings*.yml',
                           namespaces: ['blue']

    expect(file_set.send(:files)).to eql  Set[
                                            Pathname.new('/tmp/settings.yml'),
                                            Pathname.new('/tmp/settings-blue.yml'),
                                          ]

    ::FileUtils.rm_f('/tmp/settings*.yml')
  end

  it 'considers the generic file prior to any namespaced files' do
    ::File.new('/tmp/settings.yml', 'w+')
    ::File.new('/tmp/settings-blue.yml', 'w+')

    file_set = FileSet.new files:      '/tmp/settings*.yml',
                           namespaces: ['blue']

    expect(file_set.send(:files)).to eql  Set[
                                            Pathname.new('/tmp/settings.yml'),
                                            Pathname.new('/tmp/settings-blue.yml'),
                                          ]

    ::FileUtils.rm_f('/tmp/settings*.yml')
  end

  it "can yield each file's settings when converting" do
    ::File.new('/tmp/settings.yml', 'w+')

    file_set = FileSet.new files: '/tmp/settings.yml'

    file_set.to_settings do |settings|
      expect(settings).to eql Settings.new
    end

    ::FileUtils.rm_f('/tmp/settings.yml')
  end

  it 'can convert settings without yielding to the block by using an intermediate settings object' do
    ::File.new('/tmp/settings.yml', 'w+')

    file_set = FileSet.new files: '/tmp/settings.yml'

    expect(file_set.to_settings).to eql Settings.new

    ::FileUtils.rm_f('/tmp/settings.yml')
  end
end
end
