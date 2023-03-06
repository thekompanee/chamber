# frozen_string_literal: true

require 'rspectacular'
require 'chamber/filters/namespace_filter'
require 'chamber/namespace_set'

module    Chamber
module    Filters
describe  NamespaceFilter do
  it 'can filter settings data based on the settings namespaces' do
    filtered_settings = NamespaceFilter.execute(
                          data:       {
                            'namespace_value'       => {
                              'namespace_setting' => 'value 1',
                            },
                            'other_namespace_value' => {
                              'other_namespace_setting' => 'value 2',
                            },
                          },
                          namespaces: %w{namespace_value other_namespace_value},
                        )

    expect(filtered_settings['namespace_setting']).to eql 'value 1'
    expect(filtered_settings['other_namespace_setting']).to eql 'value 2'
  end

  it 'ignores data which is not part of a namespace' do
    filtered_settings = NamespaceFilter.execute(
                          data:       {
                            'namespace_value'      => {
                              'namespace_setting' => 'value 1',
                            },
                            'non_namespaced_value' => {
                              'non_namespaced_setting' => 'value 2',
                            },
                          },
                          namespaces: %w{
                                        namespace_value
                                      },
                        )

    expect(filtered_settings['namespace_setting']).to eql 'value 1'
    expect(filtered_settings['non_namespaced_setting']).to be(nil)
  end

  it 'ignores namespaces which do not exist in the data' do
    filtered_settings = NamespaceFilter.execute(
                          data:       {
                            'namespace_value' => {
                              'namespace_setting' => 'value 1',
                            },
                          },
                          namespaces: %w{namespace_value other_namespace_value},
                        )

    expect(filtered_settings['namespace_setting']).to eql 'value 1'
  end

  it 'does not filter data if it does not include any namespaces' do
    filtered_settings = NamespaceFilter.execute(
                          data:       {
                            'non_namespaced_setting' => 'value 1',
                          },
                          namespaces: [],
                        )

    expect(filtered_settings['non_namespaced_setting']).to eql 'value 1'
  end

  it 'can filter if it is given NamespaceSets' do
    filtered_settings = NamespaceFilter.execute(
                          data:       {
                            'namespace_value'       => {
                              'namespace_setting'         => 'value 1',
                              'another_namespace_setting' => 'value 2',
                            },
                            'other_namespace_value' => {
                              'namespace_setting_1'         => 'value 1',
                              'another_namespace_setting_2' => 'value 2',
                            },
                            'non_namespaced_value'  => 'value 3',
                          },
                          namespaces: NamespaceSet.new(
                                        %w{
                                          namespace_value
                                          other_namespace_value
                                        },
                                      ),
                        )

    expect(filtered_settings.to_hash).to eql('namespace_setting'           => 'value 1',
                                             'another_namespace_setting'   => 'value 2',
                                             'namespace_setting_1'         => 'value 1',
                                             'another_namespace_setting_2' => 'value 2')
  end
end
end
end
