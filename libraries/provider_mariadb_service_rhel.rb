require 'chef/provider/lwrp_base'
require 'shellwords'
require_relative 'helpers'
require_relative 'helpers_rhel'

class Chef
  class Provider
    class MariadbService
      class Rhel < Chef::Provider::MariadbService
        use_inline_resources if defined?(use_inline_resources)

        def whyrun_supported?
          true
        end

        include MariadbCookbook::Helpers::Rhel
        include Opscode::Mariadb::Helpers

        action :create do

          unless sensitive_supported?
            Chef::Log.debug("Sensitive attribute disabled, chef-client version #{Chef::VERSION} is lower than 11.14.0")
          end

          package new_resource.parsed_package_name do
            action new_resource.parsed_package_action
            # version new_resource.parsed_package_version
          end

          directory '/etc/mysql/conf.d' do
            owner 'mysql'
            group 'mysql'
            mode '0750'
            recursive true
            action :create
          end

          directory '/var/run/mysqld' do
            owner 'mysql'
            group 'mysql'
            mode '0755'
            recursive true
            action :create
          end

          directory new_resource.parsed_data_dir do
            owner 'mysql'
            group 'mysql'
            mode '0755'
            recursive true
            action :create
          end

          service 'mysqld' do
            supports :restart => true
            action [:start, :enable]
          end

          execute 'wait for mariadb' do
            command "until [ -S #{socket_file} ] ; do sleep 1 ; done"
            timeout 10
            action :run
          end

          template '/etc/mysql_grants.sql' do
            sensitive true if sensitive_supported?
            cookbook 'mariadb'
            source 'grants/grants.sql.erb'
            owner 'root'
            group 'root'
            mode '0600'
            variables(:config => new_resource)
            action :create
            notifies :run, 'execute[install-grants]'
          end

          execute 'install-grants' do
            sensitive true if sensitive_supported?
            cmd = '/usr/bin/mysql'
            cmd << ' -u root '
            cmd << "#{pass_string} < /etc/mysql_grants.sql"
            command cmd
            action :nothing
            notifies :run, 'execute[create root marker]'
          end

          template '/etc/my.cnf' do
            if new_resource.parsed_template_source.nil?
              source "#{new_resource.parsed_version}/my.cnf.erb"
              cookbook 'mariadb'
            else
              source new_resource.parsed_template_source
            end
            owner 'mysql'
            group 'mysql'
            mode '0600'
            variables(
              :data_dir => new_resource.parsed_data_dir,
              :lc_messages_dir => lc_messages_dir,
              :pid_file => pid_file,
              :port => new_resource.parsed_port,
              :socket_file => socket_file,
              :enable_utf8 => new_resource.parsed_enable_utf8
              )
            action :create
            notifies :run, 'bash[move mariadb data to datadir]'
            notifies :restart, 'service[mysqld]'
          end

          bash 'move mariadb data to datadir' do
            user 'root'
            code <<-EOH
              service mysqld stop \
              && for i in `ls /var/lib/mysql | grep -v mysql.sock` ; do mv /var/lib/mysql/$i #{new_resource.parsed_data_dir} ; done
              EOH
            action :nothing
            creates "#{new_resource.parsed_data_dir}/ibdata1"
            creates "#{new_resource.parsed_data_dir}/ib_logfile0"
            creates "#{new_resource.parsed_data_dir}/ib_logfile1"
          end

          execute 'assign-root-password' do
            sensitive true if sensitive_supported?
            cmd = '/usr/bin/mysqladmin'
            cmd << ' -u root password '
            cmd << Shellwords.escape(new_resource.parsed_server_root_password)
            command cmd
            action :run
            only_if '/usr/bin/mysql -u root -e \'show databases;\''
          end

          execute 'create root marker' do
            sensitive true if sensitive_supported?
            cmd = '/bin/echo'
            cmd << " '#{Shellwords.escape(new_resource.parsed_server_root_password)}'"
            cmd << ' > /etc/.mysql_root'
            cmd << ' ;/bin/chmod 0600 /etc/.mysql_root'
            command cmd
            action :nothing
          end
        end

        action :restart do
          service 'mysqld' do
            supports :restart => true
            action :restart
          end
        end

        action :reload do
          service 'mysqld' do
            action :reload
          end
        end
      end
    end
  end
end
