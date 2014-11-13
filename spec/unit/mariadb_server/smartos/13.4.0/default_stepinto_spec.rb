require 'spec_helper'

describe 'stepped into mariadb_test_default::server on smartos-5.11' do
  let(:smartos_13_4_0_default_stepinto_run) do
    ChefSpec::Runner.new(
      :step_into => 'mariadb_service',
      :platform => 'smartos',
      :version => '5.11' # Do this for now until Ohai can identify SmartMachines
      ) do |node|
      node.set['mariadb']['service_name'] = 'smartos_13_4_0_default_stepinto'
    end.converge('mariadb_test_default::server')
  end

  let(:my_cnf_5_5_content_smartos_13_4_0) do
    '[client]
port                           = 3306
socket                         = /tmp/mariadb.sock

[mariadbd_safe]
socket                         = /tmp/mariadb.sock

[mariadbd]
user                           = mariadb
pid-file                       = /var/mariadb/mariadb.pid
socket                         = /tmp/mariadb.sock
port                           = 3306
datadir                        = /opt/local/lib/mariadb

[mariadb]
!includedir /opt/local/etc/mariadb/conf.d
'
  end

  let(:grants_sql_content_default_smartos_13_4_0) do
    "DELETE FROM mariadb.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
UPDATE mariadb.user SET Password=PASSWORD('ilikerandompasswords') WHERE User='root';
DELETE FROM mariadb.user WHERE User='';
DROP DATABASE IF EXISTS test;
DELETE FROM mariadb.db WHERE Db='test' OR Db='test\\_%';
SET PASSWORD FOR 'root'@'localhost' = PASSWORD('ilikerandompasswords');
SET PASSWORD FOR 'root'@'127.0.0.1' = PASSWORD('ilikerandompasswords');"
  end

  before do
    stub_command("/opt/local/bin/mariadb -u root -e 'show databases;'").and_return(true)
  end

  context 'when using default parameters' do
    it 'creates mariadb_service[smartos_13_4_0_default_stepinto]' do
      expect(smartos_13_4_0_default_stepinto_run).to create_mariadb_service('smartos_13_4_0_default_stepinto')
    end

    it 'steps into mariadb_service and installs the package' do
      expect(smartos_13_4_0_default_stepinto_run).to install_package('mariadb-server').with(
        :version => '5.5'
        )
    end

    it 'steps into mariadb_service and creates the include directory' do
      expect(smartos_13_4_0_default_stepinto_run).to create_directory('/opt/local/etc/mariadb/conf.d').with(
        :owner => 'mariadb',
        :group => 'mariadb',
        :mode => '0750',
        :recursive => true
        )
    end

    it 'steps into mariadb_service and creates the run directory' do
      expect(smartos_13_4_0_default_stepinto_run).to create_directory('/var/run/mariadb').with(
        :owner => 'mariadb',
        :group => 'mariadb',
        :mode => '0755',
        :recursive => true
        )
    end

    it 'steps into mariadb_service and creates the data directory' do
      expect(smartos_13_4_0_default_stepinto_run).to create_directory('/opt/local/lib/mariadb').with(
        :owner => 'mariadb',
        :group => 'mariadb',
        :mode => '0750',
        :recursive => true
        )
    end

    it 'steps into mariadb_service and creates the data directory data subdirectory' do
      expect(smartos_13_4_0_default_stepinto_run).to create_directory('/opt/local/lib/mariadb/data').with(
        :owner => 'mariadb',
        :group => 'mariadb',
        :mode => '0750',
        :recursive => true
        )
    end

    it 'steps into mariadb_service and creates the data directory data/mariadb' do
      expect(smartos_13_4_0_default_stepinto_run).to create_directory('/opt/local/lib/mariadb/data/mariadb').with(
        :owner => 'mariadb',
        :group => 'mariadb',
        :mode => '0750',
        :recursive => true
        )
    end

    it 'steps into mariadb_service and creates the data directory data/test' do
      expect(smartos_13_4_0_default_stepinto_run).to create_directory('/opt/local/lib/mariadb/data/test').with(
        :owner => 'mariadb',
        :group => 'mariadb',
        :mode => '0750',
        :recursive => true
        )
    end

    it 'steps into mariadb_service and creates my.conf' do
      expect(smartos_13_4_0_default_stepinto_run).to create_template('/opt/local/etc/my.cnf').with(
        :owner => 'mariadb',
        :group => 'mariadb',
        :mode => '0600'
      )
    end

    it 'steps into mariadb_service and creates my.conf' do
      expect(smartos_13_4_0_default_stepinto_run).to render_file('/opt/local/etc/my.cnf').with_content(
        my_cnf_5_5_content_smartos_13_4_0
        )
    end

    it 'steps into mariadb_service and creates a bash resource' do
      expect(smartos_13_4_0_default_stepinto_run).to_not run_bash('move mariadb data to datadir')
    end

    it 'steps into mariadb_service and initializes the mariadb database' do
      expect(smartos_13_4_0_default_stepinto_run).to run_execute('initialize mariadb database').with(
        :command => '/opt/local/bin/mariadb_install_db --datadir=/opt/local/lib/mariadb --user=mariadb'
        )
    end

    it 'steps into mariadb_service and creates the service method' do
      expect(smartos_13_4_0_default_stepinto_run).to create_template('/opt/local/lib/svc/method/mariadbd').with(
        :owner => 'root',
        :group => 'root',
        :mode => '0555'
        )
    end

    it 'steps into mariadb_service and creates /tmp/mariadb.xml' do
      expect(smartos_13_4_0_default_stepinto_run).to create_template('/tmp/mariadb.xml').with(
        :owner => 'root',
        :mode => '0644'
        )
    end

    it 'steps into mariadb_service and imports the mariadb service manifest' do
      expect(smartos_13_4_0_default_stepinto_run).to_not run_execute('import mariadb manifest').with(
        :command => 'svccfg import /tmp/mariadb.xml'
        )
    end

    it 'steps into mariadb_service and manages the mariadb service' do
      expect(smartos_13_4_0_default_stepinto_run).to start_service('mariadb')
      expect(smartos_13_4_0_default_stepinto_run).to enable_service('mariadb')
    end

    it 'steps into mariadb_service and waits for mariadb to start' do
      expect(smartos_13_4_0_default_stepinto_run).to run_execute('wait for mariadb').with(
        :command => 'until [ -S /tmp/mariadb.sock ] ; do sleep 1 ; done',
        :timeout => 10
        )
    end

    it 'steps into mariadb_service and assigns root password' do
      expect(smartos_13_4_0_default_stepinto_run).to run_execute('assign-root-password').with(
        :command => '/opt/local/bin/mariadbadmin -u root password ilikerandompasswords'
        )
    end

    it 'steps into mariadb_service and creates /etc/mariadb_grants.sql' do
      expect(smartos_13_4_0_default_stepinto_run).to create_template('/opt/local/etc/mariadb_grants.sql').with(
        :owner => 'root',
        :group => 'root',
        :mode => '0600'
        )
    end

    it 'steps into mariadb_service and renders file[/etc/mariadb_grants.sql]' do
      expect(smartos_13_4_0_default_stepinto_run).to render_file('/opt/local/etc/mariadb_grants.sql').with_content(
        grants_sql_content_default_smartos_13_4_0
        )
    end

    it 'steps into mariadb_service and installs grants' do
      expect(smartos_13_4_0_default_stepinto_run).to_not run_execute('install-grants').with(
        :command => '/opt/mariadb55/bin/mariadb -u root -pilikerandompasswords < /etc/mariadb_grants.sql'
        )
    end
  end
end
