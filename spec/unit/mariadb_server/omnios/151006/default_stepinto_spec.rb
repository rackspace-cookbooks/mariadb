require 'spec_helper'

describe 'mariadb_test_default::server on omnios-151006' do
  let(:omnios_151006_default_stepinto_run) do
    ChefSpec::Runner.new(
      :step_into => 'mariadb_service',
      :platform => 'omnios',
      :version => '151006'
      ) do |node|
      node.set['mariadb']['service_name'] = 'omnios_151006_default_stepinto'
    end.converge('mariadb_test_default::server')
  end

  let(:my_cnf_5_5_content_omnios_151006) do
    '[client]
port                           = 3306
socket                         = /tmp/mariadb.sock

[mariadbd_safe]
socket                         = /tmp/mariadb.sock

[mariadbd]
user                           = mariadb
pid-file                       = /var/run/mariadb/mariadb.pid
socket                         = /tmp/mariadb.sock
port                           = 3306
datadir                        = /var/lib/mariadb
lc-messages-dir                = /opt/mariadb55/share

[mariadb]
!includedir /opt/mariadb55/etc/mariadb/conf.d
'
  end

  let(:grants_sql_content_default_omnios_151006) do
    "DELETE FROM mariadb.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
UPDATE mariadb.user SET Password=PASSWORD('ilikerandompasswords') WHERE User='root';
DELETE FROM mariadb.user WHERE User='';
DROP DATABASE IF EXISTS test;
DELETE FROM mariadb.db WHERE Db='test' OR Db='test\\_%';
SET PASSWORD FOR 'root'@'localhost' = PASSWORD('ilikerandompasswords');
SET PASSWORD FOR 'root'@'127.0.0.1' = PASSWORD('ilikerandompasswords');"
  end

  before do
    stub_command("/opt/mariadb55/bin/mariadb -u root -e 'show databases;'").and_return(true)
  end

  context 'when using default parameters' do
    it 'creates mariadb_service[omnios_151006_default_stepinto]' do
      expect(omnios_151006_default_stepinto_run).to create_mariadb_service('omnios_151006_default_stepinto')
    end

    it 'steps into mariadb_service and installs the package' do
      expect(omnios_151006_default_stepinto_run).to install_package('database/mariadb-55')
    end

    it 'steps into mariadb_service and creates the include directory' do
      expect(omnios_151006_default_stepinto_run).to create_directory('/opt/mariadb55/etc/mariadb/conf.d').with(
        :owner => 'mariadb',
        :group => 'mariadb',
        :mode => '0750',
        :recursive => true
        )
    end

    it 'steps into mariadb_service and creates the run directory' do
      expect(omnios_151006_default_stepinto_run).to create_directory('/var/run/mariadb').with(
        :owner => 'mariadb',
        :group => 'mariadb',
        :mode => '0755',
        :recursive => true
        )
    end

    it 'steps into mariadb_service and creates the data directory' do
      expect(omnios_151006_default_stepinto_run).to create_directory('/var/lib/mariadb').with(
        :owner => 'mariadb',
        :group => 'mariadb',
        :mode => '0750',
        :recursive => true
        )
    end

    it 'steps into mariadb_service and creates the data directory data subdirectory' do
      expect(omnios_151006_default_stepinto_run).to create_directory('/var/lib/mariadb/data').with(
        :owner => 'mariadb',
        :group => 'mariadb',
        :mode => '0750',
        :recursive => true
        )
    end

    it 'steps into mariadb_service and creates the data directory data/mariadb' do
      expect(omnios_151006_default_stepinto_run).to create_directory('/var/lib/mariadb/data/mariadb').with(
        :owner => 'mariadb',
        :group => 'mariadb',
        :mode => '0750',
        :recursive => true
        )
    end

    it 'steps into mariadb_service and creates the data directory data/test' do
      expect(omnios_151006_default_stepinto_run).to create_directory('/var/lib/mariadb/data/test').with(
        :owner => 'mariadb',
        :group => 'mariadb',
        :mode => '0750',
        :recursive => true
        )
    end

    it 'steps into mariadb_service and creates my.conf' do
      expect(omnios_151006_default_stepinto_run).to create_template('/opt/mariadb55/etc/my.cnf').with(
        :cookbook => 'mariadb',
        :owner => 'mariadb',
        :group => 'mariadb',
        :mode => '0600'
      )
    end

    it 'steps into mariadb_service and creates my.conf' do
      expect(omnios_151006_default_stepinto_run).to render_file('/opt/mariadb55/etc/my.cnf').with_content(my_cnf_5_5_content_omnios_151006)
    end

    it 'steps into mariadb_service and creates a bash resource' do
      expect(omnios_151006_default_stepinto_run).to_not run_bash('move mariadb data to datadir')
    end

    it 'steps into mariadb_service and initializes the mariadb database' do
      expect(omnios_151006_default_stepinto_run).to run_execute('initialize mariadb database').with(
        :command => '/opt/mariadb55/scripts/mariadb_install_db --basedir=/opt/mariadb55 --user=mariadb'
        )
    end

    it 'steps into mariadb_service and creates my.conf' do
      expect(omnios_151006_default_stepinto_run).to create_template('/lib/svc/method/mariadbd').with(
        :cookbook => 'mariadb',
        :owner => 'root',
        :mode => '0555'
        )
    end

    it 'steps into mariadb_service and creates /tmp/mariadb.xml' do
      expect(omnios_151006_default_stepinto_run).to create_template('/tmp/mariadb.xml').with(
        :cookbook => 'mariadb',
        :owner => 'root',
        :mode => '0644'
        )
    end

    it 'steps into mariadb_service and imports the mariadb service manifest' do
      expect(omnios_151006_default_stepinto_run).to_not run_execute('import mariadb manifest').with(
        :command => 'svccfg import /tmp/mariadb.xml'
        )
    end

    it 'steps into mariadb_service and manages the mariadb service' do
      expect(omnios_151006_default_stepinto_run).to start_service('mariadb')
      expect(omnios_151006_default_stepinto_run).to enable_service('mariadb')
    end

    it 'steps into mariadb_service and waits for mariadb to start' do
      expect(omnios_151006_default_stepinto_run).to run_execute('wait for mariadb').with(
        :command => 'until [ -S /tmp/mariadb.sock ] ; do sleep 1 ; done',
        :timeout => 10
        )
    end

    it 'steps into mariadb_service and assigns root password' do
      expect(omnios_151006_default_stepinto_run).to run_execute('assign-root-password').with(
        :command => '/opt/mariadb55/bin/mariadbadmin -u root password ilikerandompasswords'
        )
    end

    it 'steps into mariadb_service and creates /etc/mariadb_grants.sql' do
      expect(omnios_151006_default_stepinto_run).to create_template('/etc/mariadb_grants.sql').with(
        :cookbook => 'mariadb',
        :owner => 'root',
        :group => 'root',
        :mode => '0600'
        )
    end

    it 'steps into mariadb_service and renders file[/etc/mariadb_grants.sql]' do
      expect(omnios_151006_default_stepinto_run).to render_file('/etc/mariadb_grants.sql').with_content(
        grants_sql_content_default_omnios_151006
        )
    end

    it 'steps into mariadb_service and installs grants' do
      expect(omnios_151006_default_stepinto_run).to_not run_execute('install-grants').with(
        :command => '/opt/mariadb55/bin/mariadb -u root -pilikerandompasswords < /etc/mariadb_grants.sql'
        )
    end
  end
end
