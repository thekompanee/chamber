class   Chamber
module  Filters
class   BooleanConversionFilter

  def initialize(options = {})
    self.data = options.fetch(:data).dup
  end

  def self.execute(options = {})
    self.new(options).send(:execute)
  end

  protected

  attr_accessor :data

  def execute(settings = data)
    settings.each_pair do |key, value|
      if value.respond_to? :each_pair
        execute(value)
      else
        break if value.nil?

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
end
end
end
