# frozen_string_literal: true

module Chamber
module Errors
class  MissingIndex < ::IndexError
  def initialize(missing_index, all_keys)
    super(<<~HEREDOC.chomp)
      You attempted to access setting '#{all_keys.join(':')}' but the index '#{missing_index}' in the array did not exist.
    HEREDOC
  end
end
end
end
