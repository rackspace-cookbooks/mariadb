require 'spec_helper'

describe 'mariadb_test_default::server on debian-7.2' do
  let(:debian_7_2_default_run) do
    ChefSpec::Runner.new(
      :platform => 'debian',
      :version => '7.2'
      ) do |node|
      node.set['mariadb']['service_name'] = 'debian_7_2_default'
    end.converge('mariadb_test_default::server')
  end

  context 'when using default parameters' do
    it 'creates mariadb_service[debian_7_2_default]' do
      expect(debian_7_2_default_run).to create_mariadb_service('debian_7_2_default').with(
        :parsed_version => '5.5',
        :parsed_port => '3306',
        :parsed_data_dir => '/var/lib/mariadb'
        )
    end
  end
end
