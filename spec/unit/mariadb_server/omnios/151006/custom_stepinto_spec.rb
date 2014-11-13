require 'spec_helper'

describe 'stepped into mariadb_test_custom::server on omnios-151006' do
  let(:omnios_151006_custom_stepinto_run) do
    ChefSpec::Runner.new(
      :step_into => 'mariadb_service',
      :platform => 'omnios',
      :version => '151006'
      ) do |node|
      node.set['mariadb']['service_name'] = 'omnios_151006_custom_stepinto'
      node.set['mariadb']['version'] = '5.6'
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

  let(:my_cnf_5_6_content_omnios_151006) do
    'This my template. There are many like it but this one is mine.'
  end

  let(:grants_sql_content_custom_omnios_151006) do
    "GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%' identified by 'syncmebabyonemoretime';
GRANT ALL ON *.* TO 'root'@'%' IDENTIFIED BY 'YUNOSETPASSWORD' WITH GRANT OPTION;
SET PASSWORD FOR 'root'@'localhost' = PASSWORD('YUNOSETPASSWORD');
SET PASSWORD FOR 'root'@'127.0.0.1' = PASSWORD('YUNOSETPASSWORD');
GRANT ALL PRIVILEGES ON *.* TO 'root'@'10.9.8.7/6' IDENTIFIED BY 'YUNOSETPASSWORD' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'root'@'1.2.3.4/5' IDENTIFIED BY 'YUNOSETPASSWORD' WITH GRANT OPTION;"
  end

  before do
    stub_command("/opt/mariadb56/bin/mariadb -u root -e 'show databases;'").and_return(true)
  end

  context 'when using default parameters' do
    it 'creates mariadb_service[omnios_151006_custom_stepinto]' do
      expect(omnios_151006_custom_stepinto_run).to create_mariadb_service('omnios_151006_custom_stepinto').with(
        :version => '5.6',
        :port => '3308',
        :data_dir => '/data'
        )
    end

    it 'steps into mariadb_service and installs the package' do
      expect(omnios_151006_custom_stepinto_run).to install_package('database/mariadb-56')
    end

    it 'steps into mariadb_service and creates the include directory' do
      expect(omnios_151006_custom_stepinto_run).to create_directory('/opt/mariadb56/etc/mariadb/conf.d').with(
        :owner => 'mariadb',
        :group => 'mariadb',
        :mode => '0750',
        :recursive => true
        )
    end

    it 'steps into mariadb_service and creates the run directory' do
      expect(omnios_151006_custom_stepinto_run).to create_directory('/var/run/mariadb').with(
        :owner => 'mariadb',
        :group => 'mariadb',
        :mode => '0755',
        :recursive => true
        )
    end

    it 'steps into mariadb_service and creates the data directory' do
      expect(omnios_151006_custom_stepinto_run).to create_directory('/data').with(
        :owner => 'mariadb',
        :group => 'mariadb',
        :mode => '0750',
        :recursive => true
        )
    end

    it 'steps into mariadb_service and creates the data directory data subdirectory' do
      expect(omnios_151006_custom_stepinto_run).to create_directory('/data/data').with(
        :owner => 'mariadb',
        :group => 'mariadb',
        :mode => '0750',
        :recursive => true
        )
    end

    it 'steps into mariadb_service and creates the data directory data/mariadb' do
      expect(omnios_151006_custom_stepinto_run).to create_directory('/data/data/mariadb').with(
        :owner => 'mariadb',
        :group => 'mariadb',
        :mode => '0750',
        :recursive => true
        )
    end

    it 'steps into mariadb_service and creates the data directory data/test' do
      expect(omnios_151006_custom_stepinto_run).to create_directory('/data/data/test').with(
        :owner => 'mariadb',
        :group => 'mariadb',
        :mode => '0750',
        :recursive => true
        )
    end

    it 'steps into mariadb_service and creates my.conf' do
      expect(omnios_151006_custom_stepinto_run).to create_template('/opt/mariadb56/my.cnf').with(
        :owner => 'mariadb',
        :group => 'mariadb',
        :mode => '0600'
      )
    end

    it 'steps into mariadb_service and creates my.conf' do
      expect(omnios_151006_custom_stepinto_run).to render_file('/opt/mariadb56/my.cnf').with_content(my_cnf_5_6_content_omnios_151006)
    end

    it 'steps into mariadb_service and creates a bash resource' do
      expect(omnios_151006_custom_stepinto_run).to_not run_bash('move mariadb data to datadir')
    end

    it 'steps into mariadb_service and initializes the mariadb database' do
      expect(omnios_151006_custom_stepinto_run).to run_execute('initialize mariadb database').with(
        :command => '/opt/mariadb56/scripts/mariadb_install_db --basedir=/opt/mariadb56 --user=mariadb'
        )
    end

    it 'steps into mariadb_service and creates my.conf' do
      expect(omnios_151006_custom_stepinto_run).to create_template('/lib/svc/method/mariadbd').with(
        :cookbook => 'mariadb',
        :owner => 'root',
        :mode => '0555'
        )
    end

    it 'steps into mariadb_service and creates /tmp/mariadb.xml' do
      expect(omnios_151006_custom_stepinto_run).to create_template('/tmp/mariadb.xml').with(
        :cookbook => 'mariadb',
        :owner => 'root',
        :mode => '0644'
        )
    end

    it 'steps into mariadb_service and imports the mariadb service manifest' do
      expect(omnios_151006_custom_stepinto_run).to_not run_execute('import mariadb manifest').with(
        :command => 'svccfg import /tmp/mariadb.xml'
        )
    end

    it 'steps into mariadb_service and manages the mariadb service' do
      expect(omnios_151006_custom_stepinto_run).to start_service('mariadb')
      expect(omnios_151006_custom_stepinto_run).to enable_service('mariadb')
    end

    it 'steps into mariadb_service and waits for mariadb to start' do
      expect(omnios_151006_custom_stepinto_run).to run_execute('wait for mariadb').with(
        :command => 'until [ -S /tmp/mariadb.sock ] ; do sleep 1 ; done',
        :timeout => 10
        )
    end

    it 'steps into mariadb_service and assigns root password' do
      expect(omnios_151006_custom_stepinto_run).to run_execute('assign-root-password').with(
        :command => '/opt/mariadb56/bin/mariadbadmin -u root password YUNOSETPASSWORD'
        )
    end

    it 'steps into mariadb_service and creates /etc/mariadb_grants.sql' do
      expect(omnios_151006_custom_stepinto_run).to create_template('/etc/mariadb_grants.sql').with(
        :cookbook => 'mariadb',
        :owner => 'root',
        :group => 'root',
        :mode => '0600'
        )
    end

    it 'steps into mariadb_service and renders file[/etc/mariadb_grants.sql]' do
      expect(omnios_151006_custom_stepinto_run).to render_file('/etc/mariadb_grants.sql').with_content(
        grants_sql_content_custom_omnios_151006
        )
    end

    it 'steps into mariadb_service and installs grants' do
      expect(omnios_151006_custom_stepinto_run).to_not run_execute('install-grants').with(
        :command => '/opt/mariadb56/bin/mariadb -u root -pYUNOSETPASSWORD < /etc/mariadb_grants.sql'
        )
    end

    it 'steps into mariadb_service and writes log[notify restart]' do
      expect(omnios_151006_custom_stepinto_run).to write_log('notify restart')
    end

    it 'steps into mariadb_service and writes log[notify reload]' do
      expect(omnios_151006_custom_stepinto_run).to write_log('notify reload')
    end
  end
end
