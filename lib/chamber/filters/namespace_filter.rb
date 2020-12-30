# frozen_string_literal: true

require 'hashie/mash'
require 'chamber/refinements/hash'

module  Chamber
module  Filters
class   NamespaceFilter
  using ::Chamber::Refinements::Hash

  def self.execute(**args)
    new(**args).__send__(:execute)
  end

  attr_accessor :data,
                :namespaces

  def initialize(data:, namespaces:, **_args)
    self.data       = Hashie::Mash.new(data)
    self.namespaces = namespaces
  end

  protected

  def execute
    if data_is_namespaced?
      namespaces.each_with_object(Hashie::Mash.new) do |namespace, filtered_data|
        filtered_data.deep_merge!(data[namespace]) if data[namespace]
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
