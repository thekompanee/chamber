# frozen_string_literal: true

require 'pathname'
require 'stringio'
require 'chamber/keys/base'

module  Chamber
class   DecryptionKey < Chamber::Keys::Base
  NAMESPACE_PATTERN = /
                        \A      # Beginning of Filename
                        \.      # Initial Period
                        [^\.]+? # Initial Key Filename Base
                        \.      # Dot Separator
                        (\w+)   # Namespace
                        \.      # Post Namespace Period
                      /x

  private

  def environment_variable_from_filename(filename)
    [
      'CHAMBER',
      namespace_from_filename(filename),
      'KEY',
    ].
      compact.
      join('_')
  end

  def generate_key_filenames
    namespaces.map do |namespace|
      rootpath + ".chamber.#{namespace}.pem"
    end
  end

  def default_decryption_key_file_path
    Pathname.new(rootpath + '.chamber.pem')
  end
end
end
