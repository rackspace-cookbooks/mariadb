require 'spec_helper'

describe 'mariadb_test_default::server on omnios-151006' do
  let(:omnios_151006_default_run) do
    ChefSpec::Runner.new(
      :platform => 'omnios',
      :version => '151006'
      ) do |node|
      node.set['mariadb']['service_name'] = 'omnios_151006_default'
    end.converge('mariadb_test_default::server')
  end

  context 'when using default parameters' do
    it 'creates mariadb_service[omnios_151006_default]' do
      expect(omnios_151006_default_run).to create_mariadb_service('omnios_151006_default').with(
        :parsed_version => '5.5',
        :parsed_port => '3306',
        :parsed_data_dir => '/var/lib/mariadb'
        )
    end
  end
end
