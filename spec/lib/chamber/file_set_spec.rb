# frozen_string_literal: true

require 'rspectacular'
require 'chamber/file_set'
require 'fileutils'

module    Chamber
describe  FileSet do
  before(:each) do
    ::FileUtils.mkdir('/tmp/settings') unless ::File.exist?('/tmp/settings')
    ::FileUtils.mkdir('/tmp/dash-set') unless ::File.exist?('/tmp/dash-set')
  end

  after(:each) { ::FileUtils.rm_rf('/tmp/settings') if ::File.exist?('/tmp/settings') }

  it 'can consider directories containing YAML files' do
    ::File.new('/tmp/settings/some_settings_file.yml', 'w+')
    ::File.new('/tmp/settings/another_settings_file.yml', 'w+')

    file_set = FileSet.new(files: '/tmp/settings')

    expect(file_set.filenames).to eql [
                                        '/tmp/settings/another_settings_file.yml',
                                        '/tmp/settings/some_settings_file.yml',
                                      ]

    ::FileUtils.rm_rf('/tmp/settings')
  end

  it 'can consider globs of files' do
    ::File.new('/tmp/settings/some_settings_file.yml', 'w+')
    ::File.new('/tmp/settings/another_settings_file.yml', 'w+')

    file_set = FileSet.new(files: '/tmp/settings/*.yml')

    expect(file_set.filenames).to eql [
                                        '/tmp/settings/another_settings_file.yml',
                                        '/tmp/settings/some_settings_file.yml',
                                      ]

    ::FileUtils.rm_rf('/tmp/settings')
  end

  it 'will process both *.yml and *.yml.erb files by default' do
    ::File.new('/tmp/settings/some_settings_file.yml', 'w+')
    ::File.new('/tmp/settings/another_settings_file.yml.erb', 'w+')

    file_set = FileSet.new(files: '/tmp/settings')

    expect(file_set.filenames).to eql [
                                        '/tmp/settings/another_settings_file.yml.erb',
                                        '/tmp/settings/some_settings_file.yml',
                                      ]

    ::FileUtils.rm_rf('/tmp/settings')
  end

  it 'can consider namespaced files' do
    ::File.new('/tmp/settings/settings-blue.yml', 'w+')

    file_set = FileSet.new(files:      '/tmp/settings/settings-blue.yml',
                           namespaces: %w{blue})

    expect(file_set.filenames).to eql [
                                        '/tmp/settings/settings-blue.yml',
                                      ]

    ::FileUtils.rm_f('/tmp/settings/settings-blue.yml')
  end

  it 'does not consider namespaced files which are not relevant' do
    ::File.new('/tmp/settings/settings-blue.yml', 'w+')

    file_set = FileSet.new(files:      '/tmp/settings/settings-blue.yml',
                           namespaces: %w{green})

    expect(file_set.filenames).to be_empty

    ::FileUtils.rm_f('/tmp/settings/settings-blue.yml')
  end

  it 'does not consider non-namespaced files which have dashes in their paths as ' \
     'namespaced' do
    ::File.new('/tmp/dash-set/settings.yml', 'w+')

    file_set = FileSet.new(files:      '/tmp/dash-set/settings*.yml',
                           namespaces: %w{blue})

    expect(file_set.filenames).to eql [
                                        '/tmp/dash-set/settings.yml',
                                      ]

    ::FileUtils.rm_r('/tmp/dash-set/settings.yml')
  end

  it 'removes any duplicate files' do
    ::File.new('/tmp/settings.yml', 'w+')

    file_set = FileSet.new(files: [
                                    '/tmp/settings.yml',
                                    '/tmp/settings.yml',
                                  ])

    expect(file_set.filenames).to eql [
                                        '/tmp/settings.yml',
                                      ]

    ::FileUtils.rm_f('/tmp/settings.yml')
  end

  it 'can consider multiple file paths' do
    ::File.new('/tmp/settings.yml', 'w+')
    ::File.new('/tmp/settings/new_file.yml', 'w+')

    file_set = FileSet.new(files: [
                                    '/tmp/settings.yml',
                                    '/tmp/settings/*.yml',
                                  ])

    expect(file_set.filenames).to eql [
                                        '/tmp/settings.yml',
                                        '/tmp/settings/new_file.yml',
                                      ]

    ::FileUtils.rm_rf('/tmp/settings*')
  end

  it 'can consider file paths as Pathnames' do
    ::File.new('/tmp/settings.yml', 'w+')

    file_set = FileSet.new(files: '/tmp/settings.yml')

    expect(file_set.filenames).to eql [
                                        '/tmp/settings.yml',
                                      ]

    ::FileUtils.rm_rf('/tmp/settings*')
  end

  it 'can consider multiple namespaced files in the order the namespaces are specified' do
    ::File.new('/tmp/settings/settings-blue.yml', 'w+')
    ::File.new('/tmp/settings/settings-green.yml', 'w+')

    file_set = FileSet.new(files:      '/tmp/settings/settings*.yml',
                           namespaces: %w{blue green})

    expect(file_set.filenames).to eql  [
                                         '/tmp/settings/settings-blue.yml',
                                         '/tmp/settings/settings-green.yml',
                                       ]

    file_set = FileSet.new(files:      '/tmp/settings/settings*.yml',
                           namespaces: %w{green blue})

    expect(file_set.filenames).to eql  [
                                         '/tmp/settings/settings-green.yml',
                                         '/tmp/settings/settings-blue.yml',
                                       ]

    ::FileUtils.rm_f('/tmp/settings/settings*.yml')
  end

  it 'considers the generic file prior to any namespaced files' do
    ::File.new('/tmp/settings.yml', 'w+')
    ::File.new('/tmp/settings-blue.yml', 'w+')

    file_set = FileSet.new(files:      '/tmp/settings*.yml',
                           namespaces: %w{blue})

    expect(file_set.filenames).to eql  [
                                         '/tmp/settings.yml',
                                         '/tmp/settings-blue.yml',
                                       ]

    ::FileUtils.rm_f('/tmp/settings*.yml')
  end

  it 'considers each glob independently, placing non-namespaced and namespaced ' \
     'versions of the globs files above those in subsequent globs' do
    ::File.new('/tmp/settings/credentials-development.yml', 'w+')
    ::File.new('/tmp/settings/settings.yml', 'w+')

    file_set = FileSet.new(files:      [
                                         '/tmp/settings/credentials*.yml',
                                         '/tmp/settings/settings*.yml',
                                       ],
                           namespaces: %w{development})

    expect(file_set.filenames).to eql [
                                        '/tmp/settings/credentials-development.yml',
                                        '/tmp/settings/settings.yml',
                                      ]

    ::FileUtils.rm_rf('/tmp/settings')
  end

  it "can yield each file's settings when converting" do
    ::File.new('/tmp/settings.yml', 'w+')

    file_set = FileSet.new(files: '/tmp/settings.yml')

    file_set.to_settings do |settings|
      expect(settings).to eql Settings.new
    end

    ::FileUtils.rm_f('/tmp/settings.yml')
  end

  it 'can convert settings without yielding to the block by using an intermediate ' \
     'settings object' do
    ::File.new('/tmp/settings.yml', 'w+')

    file_set = FileSet.new(files: '/tmp/settings.yml')

    expect(file_set.to_settings).to eql Settings.new

    ::FileUtils.rm_f('/tmp/settings.yml')
  end
end
end
