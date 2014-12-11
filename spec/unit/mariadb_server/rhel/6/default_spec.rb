require 'spec_helper'

describe 'mariadb_test_default::server on centos-6.4' do
  let(:centos_6_4_default_run) do
    ChefSpec::SoloRunner.new(
      platform: 'centos',
      version: '6.4'
      ) do |node|
      node.set['mariadb']['service_name'] = 'centos_6_4_default'
    end.converge('mariadb_test_default::server')
  end

  context 'when using default parameters' do
    it 'creates mariadb_service[centos_6_4_default]' do
      expect(centos_6_4_default_run).to create_mariadb_service('centos_6_4_default').with(
        parsed_version: '10.0',
        parsed_port: '3306',
        parsed_data_dir: '/var/lib/mysql'
        )
    end
  end
end
