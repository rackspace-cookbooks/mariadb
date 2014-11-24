require 'spec_helper'

describe 'mariadb_test_default::server on ubuntu-12.04' do
  let(:ubuntu_12_04_default_run) do
    ChefSpec::SoloRunner.new(
      platform: 'ubuntu',
      version: '12.04'
      ) do |node|
      node.set['mariadb']['service_name'] = 'ubuntu_12_04_default'
    end.converge('mariadb_test_default::server')
  end

  context 'when using default parameters' do
    it 'creates mariadb_service[ubuntu_12_04_default]' do
      expect(ubuntu_12_04_default_run).to create_mariadb_service('ubuntu_12_04_default').with(
        parsed_version: '5.5',
        parsed_port: '3306',
        parsed_data_dir: '/var/lib/mysql'
        )
    end
  end
end
