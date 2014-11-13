require 'spec_helper'

describe 'stepped into mariadb_test_default::server on debian-jessie' do
  let(:debian_jessie_default_run) do
    ChefSpec::Runner.new(
      :step_into => 'mariadb_service',
      :platform => 'debian',
      :version => 'jessie/sid'
      ) do |node|
      node.set['mariadb']['service_name'] = 'debian_jessie_default'
    end.converge('mariadb_test_default::server')
  end

  let(:my_cnf_5_5_content_default_debian_jessie) do
    '[client]
port                           = 3306
socket                         = /var/run/mysqld/mysqld.sock

[mariadbd_safe]
socket                         = /var/run/mysqld/mysqld.sock

[mariadbd]
user                           = mariadb
pid-file                       = /var/run/mariadbd/mariadb.pid
socket                         = /var/run/mysqld/mysqld.sock
port                           = 3306
datadir                        = /var/lib/mariadb

[mariadb]
!includedir /etc/mariadb/conf.d
'
  end

  let(:grants_sql_content_default_debian_jessie) do
    "GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, RELOAD, SHUTDOWN, PROCESS, FILE, REFERENCES, INDEX, ALTER, SHOW DATABASES, SUPER, CREATE TEMPORARY TABLES, LOCK TABLES, EXECUTE, REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'debian-sys-maint'@'localhost' IDENTIFIED BY 'gnuslashlinux4ev4r' WITH GRANT OPTION;
DELETE FROM mariadb.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
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
    it 'creates mariadb_service[debian_jessie_default]' do
      expect(debian_jessie_default_run).to create_mariadb_service('debian_jessie_default').with(
        :parsed_version => '5.5',
        :parsed_port => '3306',
        :parsed_data_dir => '/var/lib/mariadb'
        )
    end

    it 'steps into mariadb_service and installs package[debconf-utils]' do
      expect(debian_jessie_default_run).to install_package('debconf-utils')
    end

    it 'steps into mariadb_service and creates directory[/var/cache/local/preseeding]' do
      expect(debian_jessie_default_run).to create_directory('/var/cache/local/preseeding').with(
        :owner => 'root',
        :group => 'root',
        :mode => '0755',
        :recursive => true
        )
    end

    it 'steps into mariadb_service and creates template[/var/cache/local/preseeding/mariadb-server.seed]' do
      expect(debian_jessie_default_run).to create_template('/var/cache/local/preseeding/mariadb-server.seed').with(
        :cookbook => 'mariadb',
        :owner => 'root',
        :group => 'root',
        :mode => '0600'
        )
    end

    it 'steps into mariadb_service and creates execute[preseed mariadb-server]' do
      expect(debian_jessie_default_run).to_not run_execute('preseed mariadb-server').with(
        :command => '/usr/bin/debconf-set-selections /var/cache/local/preseeding/mariadb-server.seed'
        )
    end

    it 'steps into mariadb_service and installs package[mariadb-server-5.5]' do
      expect(debian_jessie_default_run).to install_package('mariadb-server-5.5')
    end

    it 'steps into mariadb_service and creates service[mariadb]' do
      expect(debian_jessie_default_run).to start_service('mariadb')
      expect(debian_jessie_default_run).to enable_service('mariadb')
    end

    it 'steps into mariadb_service and creates directory[/etc/mariadb/conf.d]' do
      expect(debian_jessie_default_run).to create_directory('/etc/mariadb/conf.d').with(
        :owner => 'mariadb',
        :group => 'mariadb',
        :mode => '0750',
        :recursive => true
        )
    end

    it 'steps into mariadb_service and creates directory[/var/run/mariadbd]' do
      expect(debian_jessie_default_run).to create_directory('/var/run/mariadbd').with(
        :owner => 'mariadb',
        :group => 'mariadb',
        :mode => '0755',
        :recursive => true
        )
    end

    it 'steps into mariadb_service and creates directory[/var/lib/mariadb]' do
      expect(debian_jessie_default_run).to create_directory('/var/lib/mariadb').with(
        :owner => 'mariadb',
        :group => 'mariadb',
        :mode => '0750',
        :recursive => true
        )
    end

    it 'steps into mariadb_service and creates execute[assign-root-password]' do
      expect(debian_jessie_default_run).to run_execute('assign-root-password').with(
        :command => '/usr/bin/mariadbadmin -u root password ilikerandompasswords'
        )
    end

    it 'steps into mariadb_service and creates template[/etc/mariadb_grants.sql]' do
      expect(debian_jessie_default_run).to create_template('/etc/mariadb_grants.sql').with(
        :cookbook => 'mariadb',
        :owner => 'root',
        :group => 'root',
        :mode => '0600'
        )
    end

    it 'steps into mariadb_service and renders file[/etc/mariadb_grants.sql]' do
      expect(debian_jessie_default_run).to render_file('/etc/mariadb_grants.sql').with_content(
        grants_sql_content_default_debian_jessie
        )
    end

    it 'steps into mariadb_service and creates execute[install-grants]' do
      expect(debian_jessie_default_run).to_not run_execute('install-grants').with(
        :command => '/usr/bin/mariadb -u root -pilikerandompasswords < /etc/mariadb_grants.sql'
        )
    end

    it 'steps into mariadb_service and creates template[/etc/mariadb/debian.cnf]' do
      expect(debian_jessie_default_run).to create_template('/etc/mariadb/debian.cnf').with(
        :cookbook => 'mariadb',
        :source => 'debian/debian.cnf.erb',
        :owner => 'root',
        :group => 'root',
        :mode => '0600'
        )
    end

    it 'steps into mariadb_service and creates template[/etc/mariadb/my.cnf]' do
      expect(debian_jessie_default_run).to create_template('/etc/mariadb/my.cnf').with(
        :cookbook => 'mariadb',
        :owner => 'mariadb',
        :group => 'mariadb',
        :mode => '0600'
        )
    end

    it 'steps into mariadb_service and renders file[/etc/mariadb/my.cnf]' do
      expect(debian_jessie_default_run).to render_file('/etc/mariadb/my.cnf').with_content(
        my_cnf_5_5_content_default_debian_jessie
        )
    end

    it 'steps into mariadb_service and creates bash[move mariadb data to datadir]' do
      expect(debian_jessie_default_run).to_not run_bash('move mariadb data to datadir')
    end
  end
end
