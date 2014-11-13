require 'spec_helper'

describe 'mariadb_client_test::default' do
  let(:mariadb_client_run) do
    ChefSpec::Runner.new.converge('mariadb_client_test::default')
  end

  context 'when using default parameters' do
    it 'creates mariadb_client[default]' do
      expect(mariadb_client_run).to create_mariadb_client('default')
    end
  end
end
