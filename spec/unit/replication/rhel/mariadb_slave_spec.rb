# encoding: UTF-8
require 'spec_helper'
describe 'mariadb::replication_slave' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(platform: 'centos', version: '6.4') do |node|
      node.set['mariadb']['replication']['master'] = '1.2.3.4'
      node.set['mariadb']['server_repl_password'] = 'souliekr@nd0m?'
      node.set['lsb']['codename'] = 'foo'
      @log = 'mariabin-0001'
      @pos = 1492
    end.converge(described_recipe)
  end

  let(:change_master_content) do
    "CHANGE MASTER TO MASTER_HOST='1.2.3.4',MASTER_USER='replicant', MASTER_PASSWORD='souliekr@nd0m?', MASTER_LOG_FILE='', MASTER_LOG_POS=, MASTER_CONNECT_RETRY=10;\nSTART SLAVE;"
  end

  context 'when creating a slave node' do
    it 'creates a slave config' do
      expect(chef_run).to create_template('/etc/mysql/conf.d/slave.cnf')
    end

    it 'creates change master template' do
      expect(chef_run).to create_template('/root/change.master.sql').with(
      owner: 'root',
      group: 'root',
      mode: '0600',
      path: '/root/change.master.sql'
      )
      expect(chef_run).to render_file('/root/change.master.sql').with_content(change_master_content)
    end

    it 'executes change master' do
      expect(chef_run).to_not run_execute('change master')
    end

    it 'set guard template file' do
      expect(chef_run).to create_template_if_missing('/var/lib/mysql/.replication')
    end
  end
end
