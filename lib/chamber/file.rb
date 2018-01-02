# frozen_string_literal: true

require 'pathname'
require 'yaml'
require 'erb'

###
# Internal: Represents a single file containing settings information in a given
# file set.
#
module  Chamber
class   File < Pathname
  attr_accessor :namespaces,
                :decryption_key,
                :encryption_key

  ###
  # Internal: Creates a settings file representing a path to a file on the
  # filesystem.
  #
  # Optionally, namespaces may be passed in which will be passed to the Settings
  # object for consideration of which data will be parsed (see the Settings
  # object's documentation for details on how this works).
  #
  # Examples:
  #
  #   ###
  #   # It can be created by passing namespaces
  #   #
  #   settings_file = Chamber::File.new path:       '/tmp/settings.yml',
  #                                     namespaces: {
  #                                       environment: ENV['RAILS_ENV'] }
  #   # => <Chamber::File>
  #
  #   settings_file.to_settings
  #   # => <Chamber::Settings>
  #
  #   ###
  #   # It can also be created without passing any namespaces
  #   #
  #   Chamber::File.new path: '/tmp/settings.yml'
  #   # => <Chamber::File>
  #
  def initialize(options = {})
    self.namespaces     = options[:namespaces] || {}
    self.decryption_key = options[:decryption_key]
    self.encryption_key = options[:encryption_key]

    super options.fetch(:path)
  end

  ###
  # Internal: Extracts the data from the file on disk.  First passing it through
  # ERB to generate any dynamic properties and then passing the resulting data
  # through YAML.
  #
  # Therefore if a settings file contains something like:
  #
  # ```erb
  # test:
  #   my_dynamic_value: <%= 1 + 1 %>
  # ```
  #
  # then the resulting settings object would have:
  #
  # ```ruby
  # settings[:test][:my_dynamic_value]
  # # => 2
  # ```
  #
  def to_settings
    @data ||= Settings.new(settings:       file_contents_hash,
                           namespaces:     namespaces,
                           decryption_key: decryption_key,
                           encryption_key: encryption_key)
  end

  def secure
    insecure_settings = to_settings.insecure.to_flattened_name_hash
    secure_settings   = to_settings.insecure.secure.to_flattened_name_hash
    file_contents     = read

    insecure_settings.each_pair do |name_pieces, value|
      secure_value  = secure_settings[name_pieces]

      escaped_name  = Regexp.escape(name_pieces.last)
      escaped_value = Regexp.escape(value)

      file_contents.
        sub!(
          /^(\s*)_secure_#{escaped_name}(\s*):(\s*)['"]?#{escaped_value}['"]?$/,
          "\\1_secure_#{name_pieces.last}\\2:\\3#{secure_value}",
      )

      file_contents.
        sub!(
          /^(\s*)_secure_#{escaped_name}(\s*):(\s*)\|((?:\n\1\s{2}.*)+)/,
          "\\1_secure_#{name_pieces.last}\\2:\\3#{secure_value}",
      )
    end

    write(file_contents)
  end

  private

  def file_contents_hash
    file_contents = read
    erb_result    = ERB.new(file_contents).result

    YAML.load(erb_result) || {}
  rescue Errno::ENOENT
    {}
  end
end
end
