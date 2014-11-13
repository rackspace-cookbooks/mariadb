require 'spec_helper'

describe 'stepped into mariadb_test_custom::server on omnios-151006' do
  let(:smartos_13_4_0_custom_run) do
    ChefSpec::Runner.new(
      :step_into => 'mariadb_service',
      :platform => 'smartos',
      :version => '5.11' # Do this for now until Ohai can identify SmartMachines
      ) do |node|
      node.set['mariadb']['service_name'] = 'smartos_13_4_0_custom_stepinto'
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

  let(:my_cnf_5_5_content_smartos_13_4_0) do
    'This my template. There are many like it but this one is mine.'
  end

  let(:grants_sql_content_custom_smartos_13_4_0) do
    "GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%' identified by 'syncmebabyonemoretime';
GRANT ALL ON *.* TO 'root'@'%' IDENTIFIED BY 'YUNOSETPASSWORD' WITH GRANT OPTION;
SET PASSWORD FOR 'root'@'localhost' = PASSWORD('YUNOSETPASSWORD');
SET PASSWORD FOR 'root'@'127.0.0.1' = PASSWORD('YUNOSETPASSWORD');
GRANT ALL PRIVILEGES ON *.* TO 'root'@'10.9.8.7/6' IDENTIFIED BY 'YUNOSETPASSWORD' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'root'@'1.2.3.4/5' IDENTIFIED BY 'YUNOSETPASSWORD' WITH GRANT OPTION;"
  end

  before do
    stub_command("/opt/local/bin/mariadb -u root -e 'show databases;'").and_return(true)
  end

  context 'when using default parameters' do
    it 'creates mariadb_service[smartos_13_4_0_custom_stepinto]' do
      expect(smartos_13_4_0_custom_run).to create_mariadb_service('smartos_13_4_0_custom_stepinto')
    end

    it 'steps into mariadb_service and installs the package' do
      expect(smartos_13_4_0_custom_run).to install_package('mariadb-server').with(
        :version => '5.6'
        )
    end

    it 'steps into mariadb_service and creates the include directory' do
      expect(smartos_13_4_0_custom_run).to create_directory('/opt/local/etc/mariadb/conf.d').with(
        :owner => 'mariadb',
        :group => 'mariadb',
        :mode => '0750',
        :recursive => true
        )
    end

    it 'steps into mariadb_service and creates the run directory' do
      expect(smartos_13_4_0_custom_run).to create_directory('/var/run/mariadb').with(
        :owner => 'mariadb',
        :group => 'mariadb',
        :mode => '0755',
        :recursive => true
        )
    end

    it 'steps into mariadb_service and creates the data directory' do
      expect(smartos_13_4_0_custom_run).to create_directory('/data').with(
        :owner => 'mariadb',
        :group => 'mariadb',
        :mode => '0750',
        :recursive => true
        )
    end

    it 'steps into mariadb_service and creates the data directory data subdirectory' do
      expect(smartos_13_4_0_custom_run).to create_directory('/data/data').with(
        :owner => 'mariadb',
        :group => 'mariadb',
        :mode => '0750',
        :recursive => true
        )
    end

    it 'steps into mariadb_service and creates the data directory data/mariadb' do
      expect(smartos_13_4_0_custom_run).to create_directory('/data/data/mariadb').with(
        :owner => 'mariadb',
        :group => 'mariadb',
        :mode => '0750',
        :recursive => true
        )
    end

    it 'steps into mariadb_service and creates the data directory data/test' do
      expect(smartos_13_4_0_custom_run).to create_directory('/data/data/test').with(
        :owner => 'mariadb',
        :group => 'mariadb',
        :mode => '0750',
        :recursive => true
        )
    end

    it 'steps into mariadb_service and creates my.conf' do
      expect(smartos_13_4_0_custom_run).to create_template('/opt/local/etc/my.cnf').with(
        :owner => 'mariadb',
        :group => 'mariadb',
        :mode => '0600'
      )
    end

    it 'steps into mariadb_service and creates my.conf' do
      expect(smartos_13_4_0_custom_run).to render_file('/opt/local/etc/my.cnf').with_content(my_cnf_5_5_content_smartos_13_4_0)
    end

    it 'steps into mariadb_service and creates a bash resource' do
      expect(smartos_13_4_0_custom_run).to_not run_bash('move mariadb data to datadir')
    end

    it 'steps into mariadb_service and initializes the mariadb database' do
      expect(smartos_13_4_0_custom_run).to run_execute('initialize mariadb database').with(
        :command => '/opt/local/bin/mariadb_install_db --datadir=/data --user=mariadb'
        )
    end

    it 'steps into mariadb_service and creates the service method' do
      expect(smartos_13_4_0_custom_run).to create_template('/opt/local/lib/svc/method/mariadbd').with(
        :cookbook => 'mariadb',
        :owner => 'root',
        :group => 'root',
        :mode => '0555'
        )
    end

    it 'steps into mariadb_service and creates /tmp/mariadb.xml' do
      expect(smartos_13_4_0_custom_run).to create_template('/tmp/mariadb.xml').with(
        :cookbook => 'mariadb',
        :owner => 'root',
        :group => 'root',
        :mode => '0644'
        )
    end

    it 'steps into mariadb_service and imports the mariadb service manifest' do
      expect(smartos_13_4_0_custom_run).to_not run_execute('import mariadb manifest').with(
        :command => 'svccfg import /tmp/mariadb.xml'
        )
    end

    it 'steps into mariadb_service and manages the mariadb service' do
      expect(smartos_13_4_0_custom_run).to start_service('mariadb')
      expect(smartos_13_4_0_custom_run).to enable_service('mariadb')
    end

    it 'steps into mariadb_service and waits for mariadb to start' do
      expect(smartos_13_4_0_custom_run).to run_execute('wait for mariadb').with(
        :command => 'until [ -S /tmp/mariadb.sock ] ; do sleep 1 ; done',
        :timeout => 10
        )
    end

    it 'steps into mariadb_service and assigns root password' do
      expect(smartos_13_4_0_custom_run).to run_execute('assign-root-password').with(
        :command => '/opt/local/bin/mariadbadmin -u root password YUNOSETPASSWORD'
        )
    end

    it 'steps into mariadb_service and creates /opt/local/etc/mariadb_grants.sql' do
      expect(smartos_13_4_0_custom_run).to create_template('/opt/local/etc/mariadb_grants.sql').with(
        :cookbook => 'mariadb',
        :owner => 'root',
        :group => 'root',
        :mode => '0600'
        )
    end

    it 'steps into mariadb_service and renders file[/opt/local/etc/mariadb_grants.sql]' do
      expect(smartos_13_4_0_custom_run).to render_file('/opt/local/etc/mariadb_grants.sql').with_content(
        grants_sql_content_custom_smartos_13_4_0
        )
    end

    it 'steps into mariadb_service and installs grants' do
      expect(smartos_13_4_0_custom_run).to_not run_execute('install-grants').with(
        :command => '/opt/mariadb55/bin/mariadb -u root -pYUNOSETPASSWORD < /etc/mariadb_grants.sql'
        )
    end

    it 'steps into mariadb_service and writes log[notify restart]' do
      expect(smartos_13_4_0_custom_run).to write_log('notify restart')
    end

    it 'steps into mariadb_service and writes log[notify reload]' do
      expect(smartos_13_4_0_custom_run).to write_log('notify reload')
    end
  end
end
