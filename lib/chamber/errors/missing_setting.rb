module Chamber
module Errors
class  MissingSetting < ::KeyError
  def initialize(missing_key, all_keys)
    super(<<~HEREDOC)
      You attempted to access setting '#{all_keys.join(':')}' but '#{missing_key}' did not exist.
    HEREDOC
  end
end
end
end
