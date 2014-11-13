require 'spec_helper'

describe 'stepped into mariadb_test_default::server on amazon-2013.09' do
  let(:amazon_2013_09_default_run) do
    ChefSpec::Runner.new(
      :step_into => 'mariadb_service',
      :platform => 'amazon',
      :version => '2013.09'
      ) do |node|
      node.set['mariadb']['service_name'] = 'amazon_2013_09_default'
    end.converge('mariadb_test_default::server')
  end

  let(:my_cnf_5_5_content_default_amazon_2013_09) do
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

  let(:grants_sql_content_default_amazon_2013_09) do
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
    it 'creates mariadb_service[amazon_2013_09_default]' do
      expect(amazon_2013_09_default_run).to create_mariadb_service('amazon_2013_09_default').with(
        :parsed_version => '5.1',
        :parsed_port => '3306',
        :parsed_data_dir => '/var/lib/mariadb'
        )
    end

    it 'steps into mariadb_service and installs package[community-mariadb-server]' do
      expect(amazon_2013_09_default_run).to install_package('mariadb-server')
    end

    it 'steps into mariadb_service and creates directory[/etc/mariadb/conf.d]' do
      expect(amazon_2013_09_default_run).to create_directory('/etc/mariadb/conf.d').with(
        :owner => 'mariadb',
        :group => 'mariadb',
        :mode => '0750',
        :recursive => true
        )
    end

    it 'steps into mariadb_service and creates directory[/var/run/mariadbd]' do
      expect(amazon_2013_09_default_run).to create_directory('/var/run/mariadbd').with(
        :owner => 'mariadb',
        :group => 'mariadb',
        :mode => '0755',
        :recursive => true
        )
    end

    it 'steps into mariadb_service and creates directory[/var/lib/mariadb]' do
      expect(amazon_2013_09_default_run).to create_directory('/var/lib/mariadb').with(
        :owner => 'mariadb',
        :group => 'mariadb',
        :mode => '0755',
        :recursive => true
        )
    end

    it 'steps into mariadb_service and creates template[/etc/my.cnf]' do
      expect(amazon_2013_09_default_run).to create_template('/etc/my.cnf').with(
        :cookbook => 'mariadb',
        :owner => 'mariadb',
        :group => 'mariadb',
        :mode => '0600'
        )
    end

    it 'steps into mariadb_service and renders file[/etc/my.cnf]' do
      expect(amazon_2013_09_default_run).to render_file('/etc/my.cnf').with_content(
        my_cnf_5_5_content_default_amazon_2013_09
        )
    end

    it 'steps into mariadb_service and creates bash[move mariadb data to datadir]' do
      expect(amazon_2013_09_default_run).to_not run_bash('move mariadb data to datadir')
    end

    it 'steps into mariadb_service and creates service[mariadbd]' do
      expect(amazon_2013_09_default_run).to start_service('mariadbd')
      expect(amazon_2013_09_default_run).to enable_service('mariadbd')
    end

    it 'steps into mariadb_service and runs execute[wait for mariadb]' do
      expect(amazon_2013_09_default_run).to run_execute('wait for mariadb')
    end

    it 'steps into mariadb_service and creates execute[assign-root-password]' do
      expect(amazon_2013_09_default_run).to run_execute('assign-root-password').with(
        :command => '/usr/bin/mariadbadmin -u root password ilikerandompasswords'
        )
    end

    it 'steps into mariadb_service and creates template[/etc/mariadb_grants.sql]' do
      expect(amazon_2013_09_default_run).to create_template('/etc/mariadb_grants.sql').with(
        :cookbook => 'mariadb',
        :owner => 'root',
        :group => 'root',
        :mode => '0600'
        )
    end

    it 'steps into mariadb_service and renders file[/etc/mariadb_grants.sql]' do
      expect(amazon_2013_09_default_run).to render_file('/etc/mariadb_grants.sql').with_content(
        grants_sql_content_default_amazon_2013_09
        )
    end

    it 'steps into mariadb_service and creates execute[install-grants]' do
      expect(amazon_2013_09_default_run).to_not run_execute('install-grants').with(
        :command => '/usr/bin/mariadb -u root -pilikerandompasswords < /etc/mariadb_grants.sql'
        )
    end
  end
end
