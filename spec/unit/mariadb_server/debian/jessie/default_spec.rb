require 'spec_helper'

describe 'mariadb_test_default::server on debian-jessie' do
  let(:debian_jessie_default_run) do
    ChefSpec::Runner.new(
      :platform => 'debian',
      :version => 'jessie/sid'
      ) do |node|
      node.set['mariadb']['service_name'] = 'debian_jessie_default'
    end.converge('mariadb_test_default::server')
  end

  context 'when using default parameters' do
    it 'creates mariadb_service[debian_jessie_default]' do
      expect(debian_jessie_default_run).to create_mariadb_service('debian_jessie_default').with(
        :parsed_version => '5.5',
        :parsed_port => '3306',
        :parsed_data_dir => '/var/lib/mariadb'
        )
    end
  end
end
