require 'spec_helper'

describe 'mariadb_test_default::server on smartos-5.11' do
  let(:smartos_13_4_0_default_run) do
    ChefSpec::Runner.new(
      :platform => 'smartos',
      :version => '5.11' # Do this for now until Ohai can identify SmartMachines
      ) do |node|
      node.set['mariadb']['service_name'] = 'smartos_13_4_0_default'
    end.converge('mariadb_test_default::server')
  end

  context 'when using default parameters' do
    it 'creates mariadb_service[smartos_13_4_0_default]' do
      expect(smartos_13_4_0_default_run).to create_mariadb_service('smartos_13_4_0_default').with(
        :parsed_version => '5.5',
        :parsed_port => '3306',
        :parsed_package_name => 'mariadb-server',
        :parsed_data_dir => '/opt/local/lib/mariadb'
        )
    end
  end
end
