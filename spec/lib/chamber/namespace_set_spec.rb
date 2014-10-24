require 'rspectacular'
require 'chamber/namespace_set'

module    Chamber
describe  NamespaceSet do
  it 'can create a set from from a hash' do
    namespace_set = NamespaceSet.new(environment: :development,
                                     hostname:    'my host')

    expect(namespace_set).to eq ['development', 'my host']
  end

  it 'can create a set from an array' do
    namespace_set = NamespaceSet.new([:development,
                                      'my host'])

    expect(namespace_set).to eq ['development', 'my host']
  end

  it 'can create a set from a set' do
    original_set  = Set[:development, 'my host']
    namespace_set = NamespaceSet.new(original_set)

    expect(namespace_set).to eq ['development', 'my host']
  end

  it 'can create itself using square-bracket notation' do
    namespace_set = NamespaceSet[:development, 'my host']

    expect(namespace_set).to eq ['development', 'my host']
  end

  it 'can create itself from another NamespaceSet' do
    original_set  = NamespaceSet[:development, 'my host']
    namespace_set = NamespaceSet.new(original_set)

    expect(namespace_set).to eq ['development', 'my host']
  end

  it 'can create itself from a single value' do
    namespace_set = NamespaceSet.new(:development)

    expect(namespace_set).to eq ['development']
  end

  it 'when creating itself from another NamespaceSet, it creates a new NamespaceSet' do
    original_set  = NamespaceSet[:development, 'my host']
    namespace_set = NamespaceSet.new(original_set)

    expect(namespace_set.object_id).not_to eq original_set.object_id
  end

  it 'when creating itself from another NamespaceSet, it does not nest the ' \
     'NamespaceSets' do

    original_set  = NamespaceSet[:development, 'my host']
    namespace_set = NamespaceSet.new(original_set)

    expect(namespace_set.send(:raw_namespaces)).not_to be_a NamespaceSet
  end

  it 'can turn itself into an array' do
    namespace_set = NamespaceSet[:development, 'my host']

    expect(namespace_set.to_ary).to eq ['development', 'my host']
    expect(namespace_set.to_a).to   eq ['development', 'my host']
  end

  it 'can combine itself with an array' do
    namespace_set = NamespaceSet[:development, 'my host']
    other_set     = Set['other value', 3]

    combined_set  = namespace_set + other_set

    expect(combined_set).to eq ['development', 'my host', 'other value', '3']
  end

  it 'can combine itself with another NamespaceSet' do
    namespace_set = NamespaceSet[:development, 'my host']
    other_set     = NamespaceSet['other value', 3]

    combined_set  = namespace_set + other_set

    expect(combined_set).to eq ['development', 'my host', 'other value', '3']
  end

  it 'does not modify the set in place if combining with another array' do
    namespace_set = NamespaceSet[:development, 'my host']
    other_set     = Set['other value', 3]
    combined_set  = namespace_set + other_set

    expect(combined_set.object_id).not_to eq namespace_set.object_id
  end

  it 'can combine itself with something that can be converted to an array' do
    namespace_set = NamespaceSet[:development, 'my host']
    other_set     = (1..3)
    combined_set  = namespace_set + other_set

    expect(combined_set).to eq ['development', 'my host', '1', '2', '3']
  end

  it 'does not allow duplicate items' do
    namespace_set = NamespaceSet[:development, :development]

    expect(namespace_set).to eq ['development']
  end

  it 'will process a value by executing it if it is a callable' do
    namespace_set = NamespaceSet[-> { 'callable' }]

    expect(namespace_set).to eq ['callable']

    namespace_set = NamespaceSet.new(my_namespace: -> { 'callable' })

    expect(namespace_set).to eq ['callable']
  end

  it 'can compare itself to another NamespaceSet' do
    namespace_set       = NamespaceSet[:development, :development]
    other_namespace_set = NamespaceSet[:development, :development]

    expect(namespace_set).to eql other_namespace_set
  end
end
end
