# frozen_string_literal: true

require 'pathname'
require 'chamber/instance'

module  Chamber
module  Commands
class   Base
  attr_accessor :chamber,
                :dry_run,
                :rootpath,
                :shell
  def self.call(**args)
    new(**args).call
  end


  def initialize(shell: nil, rootpath: nil, dry_run: nil, **args)
    self.chamber  = Chamber::Instance.new(rootpath: rootpath, **args)
    self.shell    = shell
    self.rootpath = chamber.configuration.rootpath
    self.dry_run  = dry_run
  end
end
end
end
