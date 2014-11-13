require 'spec_helper'

describe 'mariadb_test_default::server' do
  let(:centos_5_8_default_run) do
    ChefSpec::Runner.new(
      :step_into => 'mariadb_service',
      :platform => 'centos',
      :version => '5.8'
      ) do |node|
      node.set['mariadb']['service_name'] = 'centos_5_8_default'
    end.converge('mariadb_test_default::server')
  end

  let(:my_cnf_5_5_content_centos_5_8) do
    '[client]
port                           = 3306
socket                         = /var/lib/mysql/mysql.sock

[mariadbd_safe]
socket                         = /var/lib/mysql/mysql.sock

[mariadbd]
user                           = mariadb
pid-file                       = /var/run/mariadbd/mariadb.pid
socket                         = /var/lib/mysql/mysql.sock
port                           = 3306
datadir                        = /var/lib/mariadb

[mariadb]
!includedir /etc/mariadb/conf.d
'
  end

  let(:grants_sql_content_default_centos_5_8) do
    "DELETE FROM mariadb.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
UPDATE mariadb.user SET Password=PASSWORD('ilikerandompasswords') WHERE User='root';
DELETE FROM mariadb.user WHERE User='';
DROP DATABASE IF EXISTS test;
DELETE FROM mariadb.db WHERE Db='test' OR Db='test\\_%';
SET PASSWORD FOR 'root'@'localhost' = PASSWORD('ilikerandompasswords');
SET PASSWORD FOR 'root'@'127.0.0.1' = PASSWORD('ilikerandompasswords');"
  end

  before do
    stub_command("/usr/bin/mariadb -u root -e 'show databases;'").and_return(true)
  end

  context 'when using default parameters' do
    it 'creates mariadb_service[centos_5_8_default]' do
      expect(centos_5_8_default_run).to create_mariadb_service('centos_5_8_default').with(
        :parsed_version => '5.0',
        :parsed_port => '3306',
        :parsed_data_dir => '/var/lib/mariadb'
        )
    end

    it 'steps into mariadb_service and installs package[mariadb-server]' do
      expect(centos_5_8_default_run).to install_package('mariadb-server')
    end

    it 'steps into mariadb_service and creates directory[/etc/mariadb/conf.d]' do
      expect(centos_5_8_default_run).to create_directory('/etc/mariadb/conf.d').with(
        :owner => 'mariadb',
        :group => 'mariadb',
        :mode => '0750',
        :recursive => true
        )
    end

    it 'steps into mariadb_service and creates directory[/var/run/mariadbd]' do
      expect(centos_5_8_default_run).to create_directory('/var/run/mariadbd').with(
        :owner => 'mariadb',
        :group => 'mariadb',
        :mode => '0755',
        :recursive => true
        )
    end

    it 'steps into mariadb_service and creates directory[/var/lib/mariadb]' do
      expect(centos_5_8_default_run).to create_directory('/var/lib/mariadb').with(
        :owner => 'mariadb',
        :group => 'mariadb',
        :mode => '0755',
        :recursive => true
        )
    end

    it 'steps into mariadb_service and creates template[/etc/my.cnf]' do
      expect(centos_5_8_default_run).to create_template('/etc/my.cnf').with(
        :owner => 'mariadb',
        :group => 'mariadb',
        :mode => '0600'
        )
    end

    it 'steps into mariadb_service and renders file[/etc/my.cnf]' do
      expect(centos_5_8_default_run).to render_file('/etc/my.cnf').with_content(my_cnf_5_5_content_centos_5_8)
    end

    it 'steps into mariadb_service and creates bash[move mariadb data to datadir]' do
      expect(centos_5_8_default_run).to_not run_bash('move mariadb data to datadir')
    end

    it 'steps into mariadb_service and creates service[mariadbd]' do
      expect(centos_5_8_default_run).to start_service('mariadbd')
      expect(centos_5_8_default_run).to enable_service('mariadbd')
    end

    it 'steps into mariadb_service and waits for mariadb to start' do
      expect(centos_5_8_default_run).to run_execute('wait for mariadb').with(
        :command => 'until [ -S /var/lib/mysql/mysql.sock ] ; do sleep 1 ; done',
        :timeout => 10
        )
    end

    it 'steps into mariadb_service and creates execute[assign-root-password]' do
      expect(centos_5_8_default_run).to run_execute('assign-root-password').with(
        :command => '/usr/bin/mariadbadmin -u root password ilikerandompasswords'
        )
    end

    it 'steps into mariadb_service and creates template[/etc/mariadb_grants.sql]' do
      expect(centos_5_8_default_run).to create_template('/etc/mariadb_grants.sql').with(
        :cookbook => 'mariadb',
        :owner => 'root',
        :group => 'root',
        :mode => '0600'
        )
    end

    it 'steps into mariadb_service and renders file[/etc/mariadb_grants.sql]' do
      expect(centos_5_8_default_run).to render_file('/etc/mariadb_grants.sql').with_content(
        grants_sql_content_default_centos_5_8
        )
    end

    it 'steps into mariadb_service and creates execute[install-grants]' do
      expect(centos_5_8_default_run).to_not run_execute('install-grants').with(
        :command => '/usr/bin/mariadb -u root -pilikerandompasswords < /etc/mariadb_grants.sql'
        )
    end
  end
end
