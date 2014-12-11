# encoding: UTF-8
require 'spec_helper'
describe 'mariadb::replication_master' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '12.04') do |node|
      node.set['mariadb']['replication']['slaves'] = ['1.2.3.4']
      node.set['mariadb']['server_repl_password'] = 'foobar'
      node.set['lsb']['codename'] = 'foo'
    end.converge(described_recipe)
  end

  let(:grant_content) do
    "GRANT REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'replicant'@'1.2.3.4' IDENTIFIED BY 'foobar';\nFLUSH PRIVILEGES;"
  end

  context 'when creating mariadb master' do
    it 'creates a master config' do
      expect(chef_run).to create_template('/etc/mysql/conf.d/master.cnf')
    end
    %w(1.2.3.4).each do |slave|
      it 'create grants template' do
        expect(chef_run).to create_template("/root/grant-slaves.sql #{slave}").with(
        owner: 'root',
        group: 'root',
        mode: '0600',
        path: '/root/grant-slaves.sql'
        )
        expect(chef_run).to render_file('/root/grant-slaves.sql').with_content(grant_content)
      end
    end

    it 'executes grant-slave' do
      expect(chef_run).to_not run_execute('grant-slave')
    end
  end
end
