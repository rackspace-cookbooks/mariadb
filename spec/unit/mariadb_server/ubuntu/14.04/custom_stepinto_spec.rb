require 'spec_helper'

describe 'stepped into mariadb_test_custom::server on ubuntu-14.04' do
  let(:ubuntu_14_04_custom_run) do
    ChefSpec::SoloRunner.new(
      :step_into => 'mariadb_service',
      :platform => 'ubuntu',
      :version => '14.04'
      ) do |node|
      node.set['mariadb']['service_name'] = 'ubuntu_14_04_default'
      node.set['mariadb']['version'] = '10.1'
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

  let(:my_cnf_5_5_content_custom_ubuntu_14_04) do
    'This my template. There are many like it but this one is mine.'
  end

  let(:grants_sql_content_custom_ubuntu_14_04) do
    "GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%' identified by 'syncmebabyonemoretime';
GRANT ALL ON *.* TO 'root'@'%' IDENTIFIED BY 'YUNOSETPASSWORD' WITH GRANT OPTION;
SET PASSWORD FOR 'root'@'localhost' = PASSWORD('YUNOSETPASSWORD');
SET PASSWORD FOR 'root'@'127.0.0.1' = PASSWORD('YUNOSETPASSWORD');
GRANT ALL PRIVILEGES ON *.* TO 'root'@'10.9.8.7/6' IDENTIFIED BY 'YUNOSETPASSWORD' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'root'@'1.2.3.4/5' IDENTIFIED BY 'YUNOSETPASSWORD' WITH GRANT OPTION;"
  end

  before do
    stub_command("/usr/bin/mysql -u root -e 'show databases;'").and_return(true)
  end

  context 'when using default parameters' do
    it 'creates mariadb_service[ubuntu_14_04_default]' do
      expect(ubuntu_14_04_custom_run).to create_mariadb_service('ubuntu_14_04_default').with(
        :version => '10.1',
        :port => '3308',
        :data_dir => '/data'
        )
    end

    it 'steps into mariadb_service and installs package[debconf-utils]' do
      expect(ubuntu_14_04_custom_run).to install_package('debconf-utils')
    end

    it 'steps into mariadb_service and creates directory[/var/cache/local/preseeding]' do
      expect(ubuntu_14_04_custom_run).to create_directory('/var/cache/local/preseeding').with(
        :owner => 'root',
        :group => 'root',
        :mode => '0755',
        :recursive => true
        )
    end

    it 'steps into mariadb_service and creates template[/var/cache/local/preseeding/mariadb-server.seed]' do
      expect(ubuntu_14_04_custom_run).to create_template('/var/cache/local/preseeding/mariadb-server.seed').with(
        :cookbook => 'mariadb',
        :owner => 'root',
        :group => 'root',
        :mode => '0600'
        )
    end

    it 'steps into mariadb_service and creates execute[preseed mariadb-server]' do
      expect(ubuntu_14_04_custom_run).to_not run_execute('preseed mariadb-server').with(
        :command => '/usr/bin/debconf-set-selections /var/cache/local/preseeding/mariadb-server.seed'
        )
    end

    it 'steps into mariadb_service and installs package[mariadb-server-10.1]' do
      expect(ubuntu_14_04_custom_run).to install_package('mariadb-server-10.1')
    end

    # apparmor
    it 'steps into mariadb_service and creates directory[/etc/apparmor.d]' do
      expect(ubuntu_14_04_custom_run).to create_directory('/etc/apparmor.d').with(
        :owner => 'root',
        :group => 'root',
        :mode => '0755'
        )
    end

    it 'steps into mariadb_service and creates template[/etc/mysql/debian.cnf]' do
      expect(ubuntu_14_04_custom_run).to create_template('/etc/mysql/debian.cnf').with(
        :cookbook => 'mariadb',
        :source => 'debian/debian.cnf.erb',
        :owner => 'root',
        :group => 'root',
        :mode => '0600'
        )
    end

    it 'steps into mariadb_service and creates template[/etc/apparmor.d/usr.sbin.mysqld]' do
      expect(ubuntu_14_04_custom_run).to create_template('/etc/apparmor.d/usr.sbin.mysqld').with(
        :cookbook => 'mariadb',
        :owner => 'root',
        :group => 'root',
        :mode => '0644'
        )
    end

    it 'steps into mariadb_service and creates service[apparmor-mysqld]' do
      expect(ubuntu_14_04_custom_run).to_not start_service('apparmor-mysqld')
    end

    it 'steps into mariadb_service and creates service[mysql]' do
      expect(ubuntu_14_04_custom_run).to start_service('mysql')
      expect(ubuntu_14_04_custom_run).to enable_service('mysql')
    end

    it 'steps into mariadb_service and creates directory[/etc/mysql/conf.d]' do
      expect(ubuntu_14_04_custom_run).to create_directory('/etc/mysql/conf.d').with(
        :owner => 'mysql',
        :group => 'mysql',
        :mode => '0750',
        :recursive => true
        )
    end

    it 'steps into mariadb_service and creates directory[/var/run/mysqld]' do
      expect(ubuntu_14_04_custom_run).to create_directory('/var/run/mysqld').with(
        :owner => 'mysql',
        :group => 'mysql',
        :mode => '0755',
        :recursive => true
        )
    end

    it 'steps into mariadb_service and creates directory[/data]' do
      expect(ubuntu_14_04_custom_run).to create_directory('/data').with(
        :owner => 'mysql',
        :group => 'mysql',
        :mode => '0750',
        :recursive => true
        )
    end

    # mariadb data
    it 'steps into mariadb_service and creates execute[assign-root-password]' do
      expect(ubuntu_14_04_custom_run).to run_execute('assign-root-password').with(
        :command => '/usr/bin/mysqladmin -u root password YUNOSETPASSWORD'
        )
    end

    it 'steps into mariadb_service and creates template[/etc/mysql_grants.sql]' do
      expect(ubuntu_14_04_custom_run).to create_template('/etc/mysql_grants.sql').with(
        :cookbook => 'mariadb',
        :owner => 'root',
        :group => 'root',
        :mode => '0600'
        )
    end

    it 'steps into mariadb_service and creates execute[install-grants]' do
      expect(ubuntu_14_04_custom_run).to_not run_execute('install-grants').with(
        :command => '/usr/bin/mysql -u root -pYUNOSETPASSWORD < /etc/mysql_grants.sql'
        )
    end

    it 'steps into mariadb_service and renders file[/etc/mysql_grants.sql]' do
      expect(ubuntu_14_04_custom_run).to render_file('/etc/mysql_grants.sql').with_content(
        grants_sql_content_custom_ubuntu_14_04
        )
    end

    it 'steps into mariadb_service and creates template[/etc/mysql/my.cnf]' do
      expect(ubuntu_14_04_custom_run).to create_template('/etc/mysql/my.cnf').with(
        :owner => 'mysql',
        :group => 'mysql',
        :mode => '0600'
        )
    end

    it 'steps into mariadb_service and renders file[/etc/mysql/my.cnf]' do
      expect(ubuntu_14_04_custom_run).to render_file('/etc/mysql/my.cnf').with_content(
        my_cnf_5_5_content_custom_ubuntu_14_04
        )
    end

    it 'steps into mariadb_service and creates bash[move mariadb data to datadir]' do
      expect(ubuntu_14_04_custom_run).to_not run_bash('move mariadb data to datadir')
    end

    it 'steps into mariadb_service and writes log[notify restart]' do
      expect(ubuntu_14_04_custom_run).to write_log('notify restart')
    end

    it 'steps into mariadb_service and writes log[notify reload]' do
      expect(ubuntu_14_04_custom_run).to write_log('notify reload')
    end
  end
end
