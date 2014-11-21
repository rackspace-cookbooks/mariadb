require 'spec_helper'

describe 'mariadb_test_default::server on debian-7.5' do
  let(:debian_7_5_default_run) do
    ChefSpec::SoloRunner.new(
      :platform => 'debian',
      :version => '7.5'
      ) do |node|
      node.set['mariadb']['service_name'] = 'debian_7_5_default'
    end.converge('mariadb_test_default::server')
  end

  context 'when using default parameters' do
    it 'creates mariadb_service[debian_7_5_default]' do
      expect(debian_7_5_default_run).to create_mariadb_service('debian_7_5_default').with(
        :parsed_version => '5.5',
        :parsed_port => '3306',
        :parsed_data_dir => '/var/lib/mysql'
        )
    end
  end
end
