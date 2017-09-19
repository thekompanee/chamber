# frozen_string_literal: true
require 'chamber/hashie_mash'

module  Chamber
module  Filters
class   NamespaceFilter
  def initialize(options = {})
    self.data       = HashieMash.new(options.fetch(:data))
    self.namespaces = options.fetch(:namespaces)
  end

  def self.execute(options = {})
    new(options).__send__(:execute)
  end

  protected

  attr_accessor :data,
                :namespaces

  def execute
    if data_is_namespaced?
      namespaces.each_with_object(HashieMash.new) do |namespace, filtered_data|
        filtered_data.merge!(data[namespace]) if data[namespace]
      end
    else
      HashieMash.new(data)
    end
  end

  private

  def data_is_namespaced?
    @data_is_namespaced ||= data.keys.any? { |key| namespaces.include? key.to_s }
  end
end
end
end
