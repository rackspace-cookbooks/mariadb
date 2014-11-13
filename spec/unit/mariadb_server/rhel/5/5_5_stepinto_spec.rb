require 'spec_helper'

describe 'stepped into mariadb_test_custom::server 5.5 on centos-5.8' do
  let(:centos_5_8_custom3_run) do
    ChefSpec::Runner.new(
      :step_into => 'mariadb_service',
      :platform => 'centos',
      :version => '5.8'
      ) do |node|
      node.set['mariadb']['service_name'] = 'centos_5_8_custom3'
      node.set['mariadb']['version'] = '5.5'
      node.set['mariadb']['port'] = '3308'
      node.set['mariadb']['data_dir'] = '/data'
      node.set['mariadb']['template_source'] = 'custom.erb'
      node.set['mariadb']['allow_remote_root'] = true
      node.set['mariadb']['remove_anonymous_users'] = false
      node.set['mariadb']['remove_test_database'] = false
      node.set['mariadb']['root_network_acl'] = ['10.9.8.7/6', '1.2.3.4/5']
      node.set['mariadb']['server_root_password'] = 'YUNOSETPASSWORD'
      node.set['mariadb']['server_debian_password'] = 'postinstallscriptsarestupid'
      node.set['mariadb']['server_repl_password'] = 'syncmebabyonemoretime'
    end.converge('mariadb_test_custom::server')
  end

  let(:my_cnf_5_5_content_custom3_centos_5_8) do
    'This my template. There are many like it but this one is mine.'
  end

  let(:grants_sql_content_custom3_centos_5_8) do
    "GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%' identified by 'syncmebabyonemoretime';
GRANT ALL ON *.* TO 'root'@'%' IDENTIFIED BY 'YUNOSETPASSWORD' WITH GRANT OPTION;
SET PASSWORD FOR 'root'@'localhost' = PASSWORD('YUNOSETPASSWORD');
SET PASSWORD FOR 'root'@'127.0.0.1' = PASSWORD('YUNOSETPASSWORD');
GRANT ALL PRIVILEGES ON *.* TO 'root'@'10.9.8.7/6' IDENTIFIED BY 'YUNOSETPASSWORD' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'root'@'1.2.3.4/5' IDENTIFIED BY 'YUNOSETPASSWORD' WITH GRANT OPTION;"
  end

  before do
    stub_command("/opt/rh/mariadb55/root/usr/bin/mariadb -u root -e 'show databases;'").and_return(true)
  end

  context 'when using default parameters' do
    it 'creates mariadb_service[centos_5_8_custom3]' do
      expect(centos_5_8_custom3_run).to create_mariadb_service('centos_5_8_custom3').with(
        :version => '5.5',
        :port => '3308',
        :data_dir => '/data'
        )
    end

    it 'steps into mariadb_service and installs package[mariadb55-mariadb-server]' do
      expect(centos_5_8_custom3_run).to install_package('mariadb55-mariadb-server')
    end

    it 'steps into mariadb_service and creates directory[/opt/rh/mariadb55/root/etc/mariadb/conf.d]' do
      expect(centos_5_8_custom3_run).to create_directory('/opt/rh/mariadb55/root/etc/mariadb/conf.d').with(
        :owner => 'mariadb',
        :group => 'mariadb',
        :mode => '0750',
        :recursive => true
        )
    end

    it 'steps into mariadb_service and creates directory[/opt/rh/mariadb55/root/var/run/mariadbd/]' do
      expect(centos_5_8_custom3_run).to create_directory('/opt/rh/mariadb55/root/var/run/mariadbd/').with(
        :owner => 'mariadb',
        :group => 'mariadb',
        :mode => '0755',
        :recursive => true
        )
    end

    it 'steps into mariadb_service and creates directory[/data]' do
      expect(centos_5_8_custom3_run).to create_directory('/data').with(
        :owner => 'mariadb',
        :group => 'mariadb',
        :mode => '0755',
        :recursive => true
        )
    end

    it 'steps into mariadb_service and creates template[/opt/rh/mariadb55/root/etc/my.cnf]' do
      expect(centos_5_8_custom3_run).to create_template('/opt/rh/mariadb55/root/etc/my.cnf').with(
        :owner => 'mariadb',
        :group => 'mariadb',
        :mode => '0600'
        )
    end

    it 'steps into mariadb_service and renders file[/opt/rh/mariadb55/root/etc/my.cnf]' do
      expect(centos_5_8_custom3_run).to render_file('/opt/rh/mariadb55/root/etc/my.cnf').with_content(
        my_cnf_5_5_content_custom3_centos_5_8
        )
    end

    it 'steps into mariadb_service and creates service[mariadb55-mariadbd]' do
      expect(centos_5_8_custom3_run).to start_service('mariadb55-mariadbd')
      expect(centos_5_8_custom3_run).to enable_service('mariadb55-mariadbd')
    end

    it 'steps into mariadb_service and waits for mariadb to start' do
      expect(centos_5_8_custom3_run).to run_execute('wait for mariadb').with(
        :command => 'until [ -S /var/lib/mysql/mysql.sock ] ; do sleep 1 ; done',
        :timeout => 10
        )
    end

    it 'steps into mariadb_service and creates execute[assign-root-password]' do
      expect(centos_5_8_custom3_run).to run_execute('assign-root-password').with(
        :command => '/opt/rh/mariadb55/root/usr/bin/mariadbadmin -u root password YUNOSETPASSWORD'
        )
    end

    it 'steps into mariadb_service and creates template[/etc/mariadb_grants.sql]' do
      expect(centos_5_8_custom3_run).to create_template('/etc/mariadb_grants.sql').with(
        :cookbook => 'mariadb',
        :owner => 'root',
        :group => 'root',
        :mode => '0600'
        )
    end

    it 'steps into mariadb_service and creates execute[install-grants]' do
      expect(centos_5_8_custom3_run).to_not run_execute('install-grants').with(
        :command => '/usr/bin/mariadb -u root -pYUNOSETPASSWORD < /etc/mariadb_grants.sql'
        )
    end

    it 'steps into mariadb_service and renders file[/opt/rh/mariadb55/root/etc/my.cnf]' do
      expect(centos_5_8_custom3_run).to render_file('/opt/rh/mariadb55/root/etc/my.cnf').with_content(
        my_cnf_5_5_content_custom3_centos_5_8
        )
    end

    it 'steps into mariadb_service and creates bash[move mariadb data to datadir]' do
      expect(centos_5_8_custom3_run).to_not run_bash('move mariadb data to datadir')
    end

    it 'steps into mariadb_service and writes log[notify restart]' do
      expect(centos_5_8_custom3_run).to write_log('notify restart')
    end

    it 'steps into mariadb_service and writes log[notify reload]' do
      expect(centos_5_8_custom3_run).to write_log('notify reload')
    end
  end

  context 'when using non-default package_version parameter' do
    let(:package_version) { '5.5.35-1.el6' }
    let(:centos_5_8_custom3_run) do
      ChefSpec::Runner.new(
        :step_into => 'mariadb_service',
        :platform => 'centos',
        :version => '5.8'
        ) do |node|
        node.set['mariadb']['service_name'] = 'centos_5_8_custom3'
        node.set['mariadb']['version'] = '5.5'
        node.set['mariadb']['port'] = '3308'
        node.set['mariadb']['data_dir'] = '/data'
        node.set['mariadb']['template_source'] = 'custom.erb'
        node.set['mariadb']['allow_remote_root'] = true
        node.set['mariadb']['remove_anonymous_users'] = false
        node.set['mariadb']['remove_test_database'] = false
        node.set['mariadb']['root_network_acl'] = ['10.9.8.7/6', '1.2.3.4/5']
        node.set['mariadb']['server_root_password'] = 'YUNOSETPASSWORD'
        node.set['mariadb']['server_debian_password'] = 'postinstallscriptsarestupid'
        node.set['mariadb']['server_repl_password'] = 'syncmebabyonemoretime'
        node.set['mariadb']['server_package_version'] = package_version
      end.converge('mariadb_test_custom::server')
    end

    it 'creates mariadb_service[centos_5_8_custom3] with correct package_version' do
      expect(centos_5_8_custom3_run).to create_mariadb_service('centos_5_8_custom3').with(
        :version => '5.5',
        :port => '3308',
        :data_dir => '/data',
        :package_version => package_version
        )
    end

    it 'steps into mariadb_service and installs package[mariadb55-mariadb-server]' do
      expect(centos_5_8_custom3_run).to install_package('mariadb55-mariadb-server').with(:version => package_version)
    end
  end

  context 'when using non-default package_action parameter' do
    let(:package_action) { 'upgrade' }
    let(:centos_5_8_custom3_run) do
      ChefSpec::Runner.new(
        :step_into => 'mariadb_service',
        :platform => 'centos',
        :version => '5.8'
        ) do |node|
        node.set['mariadb']['service_name'] = 'centos_5_8_custom3'
        node.set['mariadb']['version'] = '5.5'
        node.set['mariadb']['port'] = '3308'
        node.set['mariadb']['data_dir'] = '/data'
        node.set['mariadb']['template_source'] = 'custom.erb'
        node.set['mariadb']['allow_remote_root'] = true
        node.set['mariadb']['remove_anonymous_users'] = false
        node.set['mariadb']['remove_test_database'] = false
        node.set['mariadb']['root_network_acl'] = ['10.9.8.7/6', '1.2.3.4/5']
        node.set['mariadb']['server_root_password'] = 'YUNOSETPASSWORD'
        node.set['mariadb']['server_debian_password'] = 'postinstallscriptsarestupid'
        node.set['mariadb']['server_repl_password'] = 'syncmebabyonemoretime'
        node.set['mariadb']['server_package_action'] = package_action
      end.converge('mariadb_test_custom::server')
    end

    it 'creates mariadb_service[centos_5_8_custom3] with correct package_action' do
      expect(centos_5_8_custom3_run).to create_mariadb_service('centos_5_8_custom3').with(
        :version => '5.5',
        :port => '3308',
        :data_dir => '/data',
        :package_action => package_action
        )
    end

    it 'steps into mariadb_service and upgrades package[mariadb55-mariadb-server]' do
      expect(centos_5_8_custom3_run).to upgrade_package('mariadb55-mariadb-server')
    end
  end
end
