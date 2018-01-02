# frozen_string_literal: true

require 'hashie/mash'

module  Chamber
module  Filters
class   NamespaceFilter
  def self.execute(options = {})
    new(options).__send__(:execute)
  end

  attr_accessor :data,
                :namespaces

  def initialize(options = {})
    self.data       = Hashie::Mash.new(options.fetch(:data))
    self.namespaces = options.fetch(:namespaces)
  end

  protected

  def execute
    if data_is_namespaced?
      namespaces.each_with_object(Hashie::Mash.new) do |namespace, filtered_data|
        filtered_data.merge!(data[namespace]) if data[namespace]
      end
    else
      Hashie::Mash.new(data)
    end
  end

  private

  def data_is_namespaced?
    @data_is_namespaced ||= data.keys.any? { |key| namespaces.include? key.to_s }
  end
end
end
end
