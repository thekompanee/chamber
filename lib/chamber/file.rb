# frozen_string_literal: true

require 'pathname'
require 'yaml'
require 'erb'
require 'chamber/files/signature'

###
# Internal: Represents a single file containing settings information in a given
# file set.
#
module  Chamber
class   File < Pathname
  attr_accessor :namespaces,
                :decryption_keys,
                :encryption_keys

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
    self.namespaces      = options[:namespaces]      || {}
    self.decryption_keys = options[:decryption_keys] || {}
    self.encryption_keys = options[:encryption_keys] || {}

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
    @to_settings ||= Settings.new(settings:        file_contents_hash,
                                  namespaces:      namespaces,
                                  decryption_keys: decryption_keys,
                                  encryption_keys: encryption_keys)
  end

  # rubocop:disable Layout/LineLength
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
          /^(\s*)#{secure_prefix_pattern}#{escaped_name}(\s*):(\s*)['"]?#{escaped_value}['"]?$/,
          "\\1#{secure_prefix}#{name_pieces.last}\\2:\\3#{secure_value}",
        )

      file_contents.
        sub!(
          /^(\s*)#{secure_prefix_pattern}#{escaped_name}(\s*):(\s*)\|((?:\n\1\s{2}.*)+)/,
          "\\1#{secure_prefix}#{name_pieces.last}\\2:\\3#{secure_value}",
        )
    end

    write(file_contents)
  end
  # rubocop:enable Layout/LineLength

  def sign
    signature_key_contents = decryption_keys[:signature]

    fail ArgumentError, 'You asked to sign your settings files but no signature key was found.  Run `chamber init --signature` to generate one.' \
      unless signature_key_contents

    signature = Files::Signature.new(to_s, read, signature_key_contents)

    signature.write
  end

  def verify
    signature_key_contents = encryption_keys[:signature]

    fail ArgumentError, 'You asked to verify your settings files but no signature key was found.  Run `chamber init --signature` to generate one.' \
      unless signature_key_contents

    signature = Files::Signature.new(to_s, read, signature_key_contents)

    signature.verify
  end

  private

  def secure_prefix
    '_secure_'
  end

  def secure_prefix_pattern
    @secure_prefix_pattern ||= Regexp.escape(secure_prefix)
  end

  def file_contents_hash
    file_contents = read
    erb_result    = ERB.new(file_contents).result

    YAML.load(erb_result) || {}
  rescue Errno::ENOENT
    {}
  end
end
end
