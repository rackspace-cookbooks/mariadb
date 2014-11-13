require 'spec_helper'

describe 'stepped into mariadb_test_default::server on ubuntu-12.04' do
  let(:ubuntu_12_04_default_run) do
    ChefSpec::Runner.new(
      :step_into => 'mariadb_service',
      :platform => 'ubuntu',
      :version => '12.04'
      ) do |node|
      node.set['mariadb']['service_name'] = 'ubuntu_12_04_default'
    end.converge('mariadb_test_default::server')
  end

  let(:my_cnf_5_5_content_default_ubuntu_12_04) do
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

  before do
    stub_command("/usr/bin/mariadb -u root -e 'show databases;'").and_return(true)
  end

  context 'when using default parameters' do
    it 'creates mariadb_service[ubuntu_12_04_default]' do
      expect(ubuntu_12_04_default_run).to create_mariadb_service('ubuntu_12_04_default').with(
        :parsed_version => '5.5',
        :parsed_port => '3306',
        :parsed_data_dir => '/var/lib/mariadb'
        )
    end

    it 'steps into mariadb_service and installs package[debconf-utils]' do
      expect(ubuntu_12_04_default_run).to install_package('debconf-utils')
    end

    it 'steps into mariadb_service and creates directory[/var/cache/local/preseeding]' do
      expect(ubuntu_12_04_default_run).to create_directory('/var/cache/local/preseeding').with(
        :owner => 'root',
        :group => 'root',
        :mode => '0755',
        :recursive => true
        )
    end

    it 'steps into mariadb_service and creates template[/var/cache/local/preseeding/mariadb-server.seed]' do
      expect(ubuntu_12_04_default_run).to create_template('/var/cache/local/preseeding/mariadb-server.seed').with(
        :cookbook => 'mariadb',
        :owner => 'root',
        :group => 'root',
        :mode => '0600'
        )
    end

    it 'steps into mariadb_service and creates execute[preseed mariadb-server]' do
      expect(ubuntu_12_04_default_run).to_not run_execute('preseed mariadb-server').with(
        :command => '/usr/bin/debconf-set-selections /var/cache/local/preseeding/mariadb-server.seed'
        )
    end

    it 'steps into mariadb_service and installs package[mariadb-server-5.5]' do
      expect(ubuntu_12_04_default_run).to install_package('mariadb-server-5.5')
    end

    # apparmor
    it 'steps into mariadb_service and creates directory[/etc/apparmor.d]' do
      expect(ubuntu_12_04_default_run).to create_directory('/etc/apparmor.d').with(
        :owner => 'root',
        :group => 'root',
        :mode => '0755'
        )
    end

    it 'steps into mariadb_service and creates template[/etc/apparmor.d/usr.sbin.mariadbd]' do
      expect(ubuntu_12_04_default_run).to create_template('/etc/apparmor.d/usr.sbin.mariadbd').with(
        :cookbook => 'mariadb',
        :owner => 'root',
        :group => 'root',
        :mode => '0644'
        )
    end

    it 'steps into mariadb_service and creates service[apparmor-mariadb]' do
      expect(ubuntu_12_04_default_run).to_not start_service('apparmor-mariadb')
    end

    it 'steps into mariadb_service and creates template[/etc/mariadb/debian.cnf]' do
      expect(ubuntu_12_04_default_run).to create_template('/etc/mariadb/debian.cnf').with(
        :cookbook => 'mariadb',
        :source => 'debian/debian.cnf.erb',
        :owner => 'root',
        :group => 'root',
        :mode => '0600'
        )
    end

    it 'steps into mariadb_service and creates service[mariadb]' do
      expect(ubuntu_12_04_default_run).to start_service('mariadb')
      expect(ubuntu_12_04_default_run).to enable_service('mariadb')
    end

    it 'steps into mariadb_service and creates directory[/etc/mariadb/conf.d]' do
      expect(ubuntu_12_04_default_run).to create_directory('/etc/mariadb/conf.d').with(
        :owner => 'mariadb',
        :group => 'mariadb',
        :mode => '0750',
        :recursive => true
        )
    end

    it 'steps into mariadb_service and creates directory[/var/run/mariadbd]' do
      expect(ubuntu_12_04_default_run).to create_directory('/var/run/mariadbd').with(
        :owner => 'mariadb',
        :group => 'mariadb',
        :mode => '0755',
        :recursive => true
        )
    end

    it 'steps into mariadb_service and creates directory[/var/lib/mariadb]' do
      expect(ubuntu_12_04_default_run).to create_directory('/var/lib/mariadb').with(
        :owner => 'mariadb',
        :group => 'mariadb',
        :mode => '0750',
        :recursive => true
        )
    end

    # mariadb data
    it 'steps into mariadb_service and creates execute[assign-root-password]' do
      expect(ubuntu_12_04_default_run).to run_execute('assign-root-password').with(
        :command => '/usr/bin/mariadbadmin -u root password ilikerandompasswords'
        )
    end

    it 'steps into mariadb_service and creates template[/etc/mariadb_grants.sql]' do
      expect(ubuntu_12_04_default_run).to create_template('/etc/mariadb_grants.sql').with(
        :cookbook => 'mariadb',
        :owner => 'root',
        :group => 'root',
        :mode => '0600'
        )
    end

    it 'steps into mariadb_service and creates execute[install-grants]' do
      expect(ubuntu_12_04_default_run).to_not run_execute('install-grants').with(
        :command => '/usr/bin/mariadb -u root -pilikerandompasswords < /etc/mariadb_grants.sql'
        )
    end

    it 'steps into mariadb_service and creates template[/etc/mariadb/my.cnf]' do
      expect(ubuntu_12_04_default_run).to create_template('/etc/mariadb/my.cnf').with(
        :cookbook => 'mariadb',
        :owner => 'mariadb',
        :group => 'mariadb',
        :mode => '0600'
        )
    end

    it 'steps into mariadb_service and renders file[/etc/mariadb/my.cnf]' do
      expect(ubuntu_12_04_default_run).to render_file('/etc/mariadb/my.cnf').with_content(
        my_cnf_5_5_content_default_ubuntu_12_04
        )
    end

    it 'steps into mariadb_service and creates bash[move mariadb data to datadir]' do
      expect(ubuntu_12_04_default_run).to_not run_bash('move mariadb data to datadir')
    end
  end
end
