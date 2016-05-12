# frozen_string_literal: true
require 'bundler'

module  Chamber
module  Commands
module  Travis
  protected

  def travis_encrypt(command)
    Bundler.with_clean_env { `travis encrypt --add 'env.global' #{command}` }
  end
end
end
end
