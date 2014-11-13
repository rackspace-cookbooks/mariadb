require 'spec_helper'

describe 'mariadb_test_default::server on suse-11.3' do
  let(:suse_11_3_default_stepinto_run) do
    ChefSpec::Runner.new(
      :step_into => 'mariadb_service',
      :platform => 'suse',
      :version => '11.3'
      ) do |node|
      node.set['mariadb']['service_name'] = 'suse_11_3_default_stepinto'
    end.converge('mariadb_test_default::server')
  end

  let(:my_cnf_5_5_content_suse_11_3) do
    '[client]
port                           = 3306
socket                         = /var/lib/mysql/mysql.sock

[mariadbd_safe]
socket                         = /var/lib/mysql/mysql.sock

[mariadbd]
user                           = mariadb
pid-file                       = /var/run/mariadb/mariadb.pid
socket                         = /var/lib/mysql/mysql.sock
port                           = 3306
datadir                        = /var/lib/mariadb

[mariadb]
!includedir /etc/mariadb/conf.d
'
  end

  let(:grants_sql_content_default_suse_11_3) do
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
    it 'creates mariadb_service[suse_11_3_default_stepinto]' do
      expect(suse_11_3_default_stepinto_run).to create_mariadb_service('suse_11_3_default_stepinto')
    end

    it 'steps into mariadb_service and installs the package' do
      expect(suse_11_3_default_stepinto_run).to install_package('mariadb')
    end

    it 'steps into mariadb_service and deletes /etc/mariadbaccess.conf' do
      expect(suse_11_3_default_stepinto_run).to delete_file('/etc/mariadbaccess.conf')
    end

    it 'steps into mariadb_service and deletes /etc/mariadb/default_plugins.cnf' do
      expect(suse_11_3_default_stepinto_run).to delete_file('/etc/mariadb/default_plugins.cnf')
    end

    it 'steps into mariadb_service and deletes /etc/mariadb/secure_file_priv.conf' do
      expect(suse_11_3_default_stepinto_run).to delete_file('/etc/mariadb/secure_file_priv.conf')
    end

    it 'steps into mariadb_service and creates the include directory' do
      expect(suse_11_3_default_stepinto_run).to create_directory('/etc/mariadb/conf.d').with(
        :owner => 'mariadb',
        :group => 'mariadb',
        :mode => '0750',
        :recursive => true
        )
    end

    it 'steps into mariadb_service and creates the run directory' do
      expect(suse_11_3_default_stepinto_run).to create_directory('/var/run/mariadb').with(
        :owner => 'mariadb',
        :group => 'mariadb',
        :mode => '0755',
        :recursive => true
        )
    end

    it 'steps into mariadb_service and creates the data directory' do
      expect(suse_11_3_default_stepinto_run).to create_directory('/var/lib/mariadb').with(
        :owner => 'mariadb',
        :group => 'mariadb',
        :mode => '0755',
        :recursive => true
        )
    end

    it 'steps into mariadb_service and creates my.conf' do
      expect(suse_11_3_default_stepinto_run).to create_template('/etc/my.cnf').with(
        :cookbook => 'mariadb',
        :owner => 'mariadb',
        :group => 'mariadb',
        :mode => '0600'
      )
    end

    it 'steps into mariadb_service and creates my.conf' do
      expect(suse_11_3_default_stepinto_run).to render_file('/etc/my.cnf').with_content(my_cnf_5_5_content_suse_11_3)
    end

    it 'steps into mariadb_service and initializes the mariadb database' do
      expect(suse_11_3_default_stepinto_run).to run_execute('initialize mariadb database').with(
        :command => '/usr/bin/mariadb_install_db --user=mariadb'
        )
    end

    it 'steps into mariadb_service and manages the mariadb service' do
      expect(suse_11_3_default_stepinto_run).to start_service('mariadb')
      expect(suse_11_3_default_stepinto_run).to enable_service('mariadb')
    end

    it 'steps into mariadb_service and waits for mariadb to start' do
      expect(suse_11_3_default_stepinto_run).to_not run_execute('wait for mariadb').with(
        :command => 'until [ -S /var/lib/mysql/mysql.sock ] ; do sleep 1 ; done',
        :timeout => 10
        )
    end

    it 'steps into mariadb_service and assigns root password' do
      expect(suse_11_3_default_stepinto_run).to run_execute('assign-root-password').with(
        :command => '/usr/bin/mariadbadmin -u root password ilikerandompasswords'
        )
    end

    it 'steps into mariadb_service and creates /etc/mariadb_grants.sql' do
      expect(suse_11_3_default_stepinto_run).to create_template('/etc/mariadb_grants.sql').with(
        :cookbook => 'mariadb',
        :owner => 'root',
        :group => 'root',
        :mode => '0600'
        )
    end

    it 'steps into mariadb_service and renders file[/etc/mariadb_grants.sql]' do
      expect(suse_11_3_default_stepinto_run).to render_file('/etc/mariadb_grants.sql').with_content(
        grants_sql_content_default_suse_11_3
        )
    end

    it 'steps into mariadb_service and installs grants' do
      expect(suse_11_3_default_stepinto_run).to_not run_execute('install-grants').with(
        :command => '/usr/bin/mariadb -u root -pilikerandompasswords < /etc/mariadb_grants.sql'
        )
    end
  end
end
