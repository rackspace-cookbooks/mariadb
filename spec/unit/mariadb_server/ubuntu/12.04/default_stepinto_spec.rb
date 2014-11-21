require 'spec_helper'

describe 'stepped into mariadb_test_default::server on ubuntu-12.04' do
  let(:ubuntu_12_04_default_run) do
    ChefSpec::SoloRunner.new(
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
user                           = mysql
pid-file                       = /var/run/mmysqld/mysqld.pid
socket                         = /var/run/mysqld/mysqld.sock
port                           = 3306
datadir                        = /var/lib/mysql

[mariadb]
!includedir /etc/mysql/conf.d
'
  end

  before do
    stub_command("/usr/bin/mysql -u root -e 'show databases;'").and_return(true)
  end

  context 'when using default parameters' do
    it 'creates mariadb_service[ubuntu_12_04_default]' do
      expect(ubuntu_12_04_default_run).to create_mariadb_service('ubuntu_12_04_default').with(
        :parsed_version => '5.5',
        :parsed_port => '3306',
        :parsed_data_dir => '/var/lib/mysql'
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

    it 'steps into mariadb_service and creates template[/etc/apparmor.d/usr.sbin.mysqld]' do
      expect(ubuntu_12_04_default_run).to create_template('/etc/apparmor.d/usr.sbin.mysqld').with(
        :cookbook => 'mariadb',
        :owner => 'root',
        :group => 'root',
        :mode => '0644'
        )
    end

    it 'steps into mariadb_service and creates service[apparmor-mariadb]' do
      expect(ubuntu_12_04_default_run).to_not start_service('apparmor-mysqld')
    end

    it 'steps into mariadb_service and creates template[/etc/mysql/debian.cnf]' do
      expect(ubuntu_12_04_default_run).to create_template('/etc/mysql/debian.cnf').with(
        :cookbook => 'mariadb',
        :source => 'debian/debian.cnf.erb',
        :owner => 'root',
        :group => 'root',
        :mode => '0600'
        )
    end

    it 'steps into mariadb_service and creates service[mariadb]' do
      expect(ubuntu_12_04_default_run).to start_service('mysql')
      expect(ubuntu_12_04_default_run).to enable_service('mysql')
    end

    it 'steps into mariadb_service and creates directory[/etc/mysql/conf.d]' do
      expect(ubuntu_12_04_default_run).to create_directory('/etc/mysql/conf.d').with(
        :owner => 'mysql',
        :group => 'mysql',
        :mode => '0750',
        :recursive => true
        )
    end

    it 'steps into mariadb_service and creates directory[/var/run/mysql]' do
      expect(ubuntu_12_04_default_run).to create_directory('/var/run/mysql').with(
        :owner => 'mysql',
        :group => 'mysql',
        :mode => '0755',
        :recursive => true
        )
    end

    it 'steps into mariadb_service and creates directory[/var/lib/mysql]' do
      expect(ubuntu_12_04_default_run).to create_directory('/var/lib/mysql').with(
        :owner => 'mysql',
        :group => 'mysql',
        :mode => '0750',
        :recursive => true
        )
    end

    # mariadb data
    it 'steps into mariadb_service and creates execute[assign-root-password]' do
      expect(ubuntu_12_04_default_run).to run_execute('assign-root-password').with(
        :command => '/usr/bin/mysqladmin -u root password ilikerandompasswords'
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
        :command => '/usr/bin/mysql -u root -pilikerandompasswords < /etc/mariadb_grants.sql'
        )
    end

    it 'steps into mariadb_service and creates template[/etc/mysql/my.cnf]' do
      expect(ubuntu_12_04_default_run).to create_template('/etc/mysql/my.cnf').with(
        :cookbook => 'mariadb',
        :owner => 'mysql',
        :group => 'mysql',
        :mode => '0600'
        )
    end

    it 'steps into mariadb_service and renders file[/etc/mysql/my.cnf]' do
      expect(ubuntu_12_04_default_run).to render_file('/etc/mysql/my.cnf').with_content(
        my_cnf_5_5_content_default_ubuntu_12_04
        )
    end

    it 'steps into mariadb_service and creates bash[move mariadb data to datadir]' do
      expect(ubuntu_12_04_default_run).to_not run_bash('move mariadb data to datadir')
    end
  end
end