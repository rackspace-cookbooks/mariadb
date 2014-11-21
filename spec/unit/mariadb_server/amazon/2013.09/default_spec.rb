require 'spec_helper'

describe 'mariadb_test_default::server on amazon-2013.09' do
  let(:amazon_2013_09_default_run) do
    ChefSpec::Runner.new(
      :platform => 'amazon',
      :version => '2013.09'
      ) do |node|
      node.set['mariadb']['service_name'] = 'amazon_2013_09_default'
    end.converge('mariadb_test_default::server')
  end

  context 'when using default parameters' do
    it 'creates mariadb_service[amazon_2013_09_default]' do
      expect(amazon_2013_09_default_run).to create_mariadb_service('amazon_2013_09_default').with(
        :parsed_version => '10.0',
        :parsed_port => '3306',
        :parsed_data_dir => '/var/lib/mysql'
        )
    end
  end
end
