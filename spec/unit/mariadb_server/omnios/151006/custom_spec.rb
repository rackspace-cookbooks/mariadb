require 'spec_helper'

describe 'mariadb_test_custom::server on omnios-151006' do
  let(:omnios_151006_supported_run) do
    ChefSpec::Runner.new(
      :platform => 'omnios',
      :version => '151006'
      ) do |node|
      node.set['mariadb']['service_name'] = 'omnios_151006_supported'
      node.set['mariadb']['version'] = '5.6'
      node.set['mariadb']['port'] = '3308'
      node.set['mariadb']['data_dir'] = '/data'
    end.converge('mariadb_test_custom::server')
  end

  context 'when using an supported version' do
    it 'creates the resource with the correct parameters' do
      expect(omnios_151006_supported_run).to create_mariadb_service('omnios_151006_supported').with(
        :parsed_version => '5.6',
        :parsed_package_name => 'database/mariadb-56',
        :parsed_port => '3308',
        :parsed_data_dir => '/data'
        )
    end
  end
end
