require 'spec_helper'

describe 'mariadb_test_default::mariadb_service_attribues on fedora-20' do
  let(:fedora_20_default_run) do
    ChefSpec::SoloRunner.new(
      platform: 'fedora',
      version: '20'
      ) do |node|
      node.set['mariadb']['service_name'] = 'fedora_20_default'
    end.converge('mariadb_test_default::server')
  end

  context 'when using default parameters' do
    it 'creates mariadb_service[fedora_20_default]' do
      expect(fedora_20_default_run).to create_mariadb_service('fedora_20_default').with(
        parsed_version: '10.0',
        parsed_port: '3306',
        parsed_data_dir: '/var/lib/mysql'
        )
    end
  end
end
