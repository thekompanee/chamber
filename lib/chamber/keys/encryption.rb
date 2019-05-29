# frozen_string_literal: true

require 'pathname'
require 'chamber/keys/base'

module  Chamber
module  Keys
class   Encryption < Chamber::Keys::Base
  NAMESPACE_PATTERN = /
                        \A          # Beginning of Filename
                        \.chamber   # Initial Chamber Prefix
                        \.          # Pre-Namespace Dot
                        (\w+)       # Namespace
                        \.pub\.pem  # Extension
                        \z          # End of Filename
                      /x.freeze

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

  def key_filename_extension
    '.pub.pem'
  end
end
end
end
