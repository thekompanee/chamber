# frozen_string_literal: true

module  Chamber
module  Filters
class   BooleanConversionFilter
  attr_accessor :data

  def initialize(options = {})
    self.data = options.fetch(:data).dup
  end

  def self.execute(options = {})
    new(options).__send__(:execute)
  end

  protected

  # rubocop:disable Metrics/BlockNesting
  def execute(settings = data)
    settings.each_pair do |key, value|
      if value.respond_to? :each_pair
        execute(value)
      else
        settings[key] = if value.is_a? String
                          case value
                          when 'false', 'f', 'no'
                            false
                          when 'true', 't', 'yes'
                            true
                          else
                            value
                          end
                        else
                          value
                        end
      end
    end
  end
  # rubocop:enable Metrics/BlockNesting
end
end
end
