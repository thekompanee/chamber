# frozen_string_literal: true

require 'pathname'
require 'chamber/keys/base'

module  Chamber
module  Keys
class   Decryption < Chamber::Keys::Base
  NAMESPACE_PATTERN = /
                        \A          # Beginning of Filename
                        \.chamber   # Initial Chamber Prefix
                        \.          # Pre-Namespace Dot
                        ([\w\-\.]+) # Namespace
                        \.pem       # Extension
                        \z          # End of Filename
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

  def default_key_file_path
    Pathname.new(rootpath + '.chamber.pem')
  end
end
end
end
