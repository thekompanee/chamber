# frozen_string_literal: true

require 'pathname'
require 'stringio'
require 'chamber/keys/base'

module  Chamber
class   EncryptionKey < Chamber::Keys::Base
  NAMESPACE_PATTERN = /
                        \A          # Beginning of Filename
                        \.          # Initial Period
                        [^\.]+?     # Initial Key Filename Base
                        \.          # Dot Separator
                        (\w+)       # Namespace
                        \.pub\.pem  # Post Namespace Extension
                      /x

  private

  def environment_variable_from_filename(filename)
    [
      'CHAMBER',
      namespace_from_filename(filename),
      'PUBLIC_KEY',
    ].
      compact.
      join('_')
  end

  def generate_key_filenames
    namespaces.map do |namespace|
      rootpath + ".chamber.#{namespace}.pub.pem"
    end
  end

  def default_encryption_key_file_path
    Pathname.new(rootpath + '.chamber.pub.pem')
  end
end
end
