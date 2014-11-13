require 'spec_helper'

describe 'stepped into mariadb_test_custom::server on centos-6.4' do
  let(:centos_6_4_5_5_stepinto_run) do
    ChefSpec::Runner.new(
      :step_into => 'mariadb_service',
      :platform => 'centos',
      :version => '6.4'
      ) do |node|
      node.set['mariadb']['service_name'] = 'centos_6_4_5_5'
      node.set['mariadb']['version'] = '5.6'
      node.set['mariadb']['port'] = '3308'
      node.set['mariadb']['data_dir'] = '/data'
      node.set['mariadb']['template_source'] = 'custom.erb'
    end.converge('mariadb_test_custom::server')
  end

  let(:my_cnf_5_5_content_centos_6_4) do
    'This my template. There are many like it but this one is mine.'
  end

  before do
    stub_command("/usr/bin/mariadb -u root -e 'show databases;'").and_return(true)
  end

  context 'when using default parameters' do
    it 'creates mariadb_service[centos_6_4_5_5]' do
      expect(centos_6_4_5_5_stepinto_run).to create_mariadb_service('centos_6_4_5_5').with(
        :version => '5.6',
        :port => '3308',
        :data_dir => '/data'
        )
    end

    it 'steps into mariadb_service and installs package[mariadb-server]' do
      expect(centos_6_4_5_5_stepinto_run).to install_package('mariadb-community-server')
    end

    it 'steps into mariadb_service and creates directory[/etc/mariadb/conf.d]' do
      expect(centos_6_4_5_5_stepinto_run).to create_directory('/etc/mariadb/conf.d').with(
        :owner => 'mariadb',
        :group => 'mariadb',
        :mode => '0750',
        :recursive => true
        )
    end

    it 'steps into mariadb_service and creates directory[/var/run/mariadbd]' do
      expect(centos_6_4_5_5_stepinto_run).to create_directory('/var/run/mariadbd').with(
        :owner => 'mariadb',
        :group => 'mariadb',
        :mode => '0755',
        :recursive => true
        )
    end

    it 'steps into mariadb_service and creates directory[/data]' do
      expect(centos_6_4_5_5_stepinto_run).to create_directory('/data').with(
        :owner => 'mariadb',
        :group => 'mariadb',
        :mode => '0755',
        :recursive => true
        )
    end

    it 'steps into mariadb_service and creates template[/etc/my.cnf]' do
      expect(centos_6_4_5_5_stepinto_run).to create_template('/etc/my.cnf').with(
        :owner => 'mariadb',
        :group => 'mariadb',
        :mode => '0600'
        )
    end

    it 'steps into mariadb_service and creates service[mariadbd]' do
      expect(centos_6_4_5_5_stepinto_run).to start_service('mariadbd')
      expect(centos_6_4_5_5_stepinto_run).to enable_service('mariadbd')
    end

    it 'steps into mariadb_service and creates execute[assign-root-password]' do
      expect(centos_6_4_5_5_stepinto_run).to run_execute('assign-root-password').with(
        :command => '/usr/bin/mariadbadmin -u root password ilikerandompasswords'
        )
    end

    it 'steps into mariadb_service and creates template[/etc/mariadb_grants.sql]' do
      expect(centos_6_4_5_5_stepinto_run).to create_template('/etc/mariadb_grants.sql').with(
        :cookbook => 'mariadb',
        :owner => 'root',
        :group => 'root',
        :mode => '0600'
        )
    end

    it 'steps into mariadb_service and creates execute[install-grants]' do
      expect(centos_6_4_5_5_stepinto_run).to_not run_execute('install-grants').with(
        :command => '/usr/bin/mariadb -u root -pilikerandompasswords < /etc/mariadb_grants.sql'
        )
    end

    it 'steps into mariadb_service and renders file[/etc/my.cnf]' do
      expect(centos_6_4_5_5_stepinto_run).to render_file('/etc/my.cnf').with_content(my_cnf_5_5_content_centos_6_4)
    end

    it 'steps into mariadb_service and creates bash[move mariadb data to datadir]' do
      expect(centos_6_4_5_5_stepinto_run).to_not run_bash('move mariadb data to datadir')
    end
  end
end
