# frozen_string_literal: true
require 'pathname'
require 'chamber/instance'

module  Chamber
module  Commands
class   Base
  def initialize(options = {})
    self.chamber  = Chamber::Instance.new options
    self.shell    = options[:shell]
    self.rootpath = options[:rootpath]
    self.dry_run  = options[:dry_run]
  end

  def self.call(options = {})
    new(options).call
  end

  protected

  attr_accessor :chamber,
                :shell,
                :dry_run
  attr_reader   :rootpath

  def rootpath=(other)
    @rootpath ||= Pathname.new(other)
  end
end
end
end
