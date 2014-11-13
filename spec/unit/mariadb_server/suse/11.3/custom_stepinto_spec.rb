require 'spec_helper'

describe 'mariadb_test_custom::server on suse-11.3' do
  let(:suse_11_3_custom_stepinto_run) do
    ChefSpec::Runner.new(
      :step_into => 'mariadb_service',
      :platform => 'suse',
      :version => '11.3'
      ) do |node|
      node.set['mariadb']['service_name'] = 'suse_11_3_custom_stepinto'
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

  let(:my_cnf_5_5_content_custom_suse_11_3) do
    '# This my template. There are many like it but this one is mine'
  end

  let(:grants_sql_content_custom_suse_11_3) do
    "GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%' identified by 'syncmebabyonemoretime';
GRANT ALL ON *.* TO 'root'@'%' IDENTIFIED BY 'YUNOSETPASSWORD' WITH GRANT OPTION;
SET PASSWORD FOR 'root'@'localhost' = PASSWORD('YUNOSETPASSWORD');
SET PASSWORD FOR 'root'@'127.0.0.1' = PASSWORD('YUNOSETPASSWORD');
GRANT ALL PRIVILEGES ON *.* TO 'root'@'10.9.8.7/6' IDENTIFIED BY 'YUNOSETPASSWORD' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'root'@'1.2.3.4/5' IDENTIFIED BY 'YUNOSETPASSWORD' WITH GRANT OPTION;
"
  end

  before do
    stub_command("/usr/bin/mariadb -u root -e 'show databases;'").and_return(true)
  end

  context 'when using default parameters' do
    it 'creates mariadb_service[suse_11_3_custom_stepinto]' do
      expect(suse_11_3_custom_stepinto_run).to create_mariadb_service('suse_11_3_custom_stepinto')
    end

    it 'steps into mariadb_service and installs the package' do
      expect(suse_11_3_custom_stepinto_run).to install_package('mariadb')
    end

    it 'steps into mariadb_service and deletes /etc/mariadbaccess.conf' do
      expect(suse_11_3_custom_stepinto_run).to delete_file('/etc/mariadbaccess.conf')
    end

    it 'steps into mariadb_service and deletes /etc/mariadb/default_plugins.cnf' do
      expect(suse_11_3_custom_stepinto_run).to delete_file('/etc/mariadb/default_plugins.cnf')
    end

    it 'steps into mariadb_service and deletes /etc/mariadb/secure_file_priv.conf' do
      expect(suse_11_3_custom_stepinto_run).to delete_file('/etc/mariadb/secure_file_priv.conf')
    end

    it 'steps into mariadb_service and creates the include directory' do
      expect(suse_11_3_custom_stepinto_run).to create_directory('/etc/mariadb/conf.d').with(
        :owner => 'mariadb',
        :group => 'mariadb',
        :mode => '0750',
        :recursive => true
        )
    end

    it 'steps into mariadb_service and creates the run directory' do
      expect(suse_11_3_custom_stepinto_run).to create_directory('/var/run/mariadb').with(
        :owner => 'mariadb',
        :group => 'mariadb',
        :mode => '0755',
        :recursive => true
        )
    end

    it 'steps into mariadb_service and creates the data directory' do
      expect(suse_11_3_custom_stepinto_run).to create_directory('/data').with(
        :owner => 'mariadb',
        :group => 'mariadb',
        :mode => '0755',
        :recursive => true
        )
    end

    it 'steps into mariadb_service and creates my.conf' do
      expect(suse_11_3_custom_stepinto_run).to create_template('/etc/my.cnf').with(
        :owner => 'mariadb',
        :group => 'mariadb',
        :mode => '0600'
      )
    end

    it 'steps into mariadb_service and creates my.conf' do
      expect(suse_11_3_custom_stepinto_run).to render_file('/etc/my.cnf').with_content(my_cnf_5_5_content_custom_suse_11_3)
    end

    it 'steps into mariadb_service and initializes the mariadb database' do
      expect(suse_11_3_custom_stepinto_run).to run_execute('initialize mariadb database').with(
        :command => '/usr/bin/mariadb_install_db --user=mariadb'
        )
    end

    it 'steps into mariadb_service and manages the mariadb service' do
      expect(suse_11_3_custom_stepinto_run).to start_service('mariadb')
      expect(suse_11_3_custom_stepinto_run).to enable_service('mariadb')
    end

    it 'steps into mariadb_service and waits for mariadb to start' do
      expect(suse_11_3_custom_stepinto_run).to_not run_execute('wait for mariadb').with(
        :command => 'until [ -S /var/lib/mysql/mysql.sock ] ; do sleep 1 ; done',
        :timeout => 10
        )
    end

    it 'steps into mariadb_service and assigns root password' do
      expect(suse_11_3_custom_stepinto_run).to run_execute('assign-root-password').with(
        :command => '/usr/bin/mariadbadmin -u root password YUNOSETPASSWORD'
        )
    end

    it 'steps into mariadb_service and creates /etc/mariadb_grants.sql' do
      expect(suse_11_3_custom_stepinto_run).to create_template('/etc/mariadb_grants.sql').with(
        :cookbook => 'mariadb',
        :owner => 'root',
        :group => 'root',
        :mode => '0600'
        )
    end

    it 'steps into mariadb_service and renders file[/etc/mariadb_grants.sql]' do
      expect(suse_11_3_custom_stepinto_run).to render_file('/etc/mariadb_grants.sql').with_content(
        grants_sql_content_custom_suse_11_3
        )
    end

    it 'steps into mariadb_service and installs grants' do
      expect(suse_11_3_custom_stepinto_run).to_not run_execute('install-grants').with(
        :command => '/usr/bin/mariadb -u root -pilikerandompasswords < /etc/mariadb_grants.sql'
        )
    end
  end
end
