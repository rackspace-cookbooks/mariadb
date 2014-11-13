require 'spec_helper'

describe 'mariadb_test_default::mariadb_service_attribues on fedora-19' do
  let(:fedora_19_default_run) do
    ChefSpec::Runner.new(
      :platform => 'fedora',
      :version => '19'
      ) do |node|
      node.set['mariadb']['service_name'] = 'fedora_19_default'
    end.converge('mariadb_test_default::server')
  end

  context 'when using default parameters' do
    it 'creates mariadb_service[fedora_19_default]' do
      expect(fedora_19_default_run).to create_mariadb_service('fedora_19_default').with(
        :parsed_version => '5.5',
        :parsed_port => '3306',
        :parsed_data_dir => '/var/lib/mariadb'
        )
    end
  end
end
