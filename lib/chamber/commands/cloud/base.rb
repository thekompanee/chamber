# frozen_string_literal: true

require 'chamber/commands/base'

module  Chamber
module  Commands
module  Cloud
class   Base < Chamber::Commands::Base
  attr_accessor :adapter

  def initialize(options = {})
    super

    self.adapter = adapter_class(options[:adapter]).new(options)
  end

  private

  def adapter_class(adapter_name)
    require "chamber/adapters/cloud/#{adapter_name}"

    @adapter_class ||= case adapter_name
                       when 'circle_ci'
                         Chamber::Adapters::Cloud::CircleCi
                       when 'heroku'
                         Chamber::Adapters::Cloud::Heroku
                       else
                         fail ArgumentError,
                              "Invalid Chamber cloud adapter name: #{adapter_name}"
                       end
  end
end
end
end
end
