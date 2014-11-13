require 'spec_helper'

describe 'mariadb_test_default::server on suse-11.3' do
  let(:suse_151006_default_run) do
    ChefSpec::Runner.new(
      :platform => 'suse',
      :version => '11.3'
      ) do |node|
      node.set['mariadb']['service_name'] = 'suse_11_3_default'
    end.converge('mariadb_test_default::server')
  end

  context 'when using default parameters' do
    it 'creates mariadb_service[suse_11_3_default]' do
      expect(suse_151006_default_run).to create_mariadb_service('suse_11_3_default').with(
        :parsed_version => '5.5',
        :parsed_port => '3306',
        :parsed_data_dir => '/var/lib/mariadb'
        )
    end
  end
end
