require 'chef/provider/lwrp_base'
require 'shellwords'
require_relative 'helpers'
require_relative 'helpers_debian'

class Chef
  class Provider
    class MariadbService
      class Debian < Chef::Provider::MariadbService
        use_inline_resources if defined?(use_inline_resources)

        def whyrun_supported?
          true
        end

        include MariadbCookbook::Helpers::Debian
        include Opscode::Mariadb::Helpers

        action :create do

          unless sensitive_supported?
            Chef::Log.debug("Sensitive attribute disabled, chef-client version #{Chef::VERSION} is lower than 11.14.0")
          end

          include_recpie 'mariadb::repo'

          package 'debconf-utils' do
            action :install
          end

          directory '/var/cache/local/preseeding' do
            owner 'root'
            group 'root'
            mode '0755'
            action :create
            recursive true
          end

          template '/var/cache/local/preseeding/mariadb-server.seed' do
            cookbook 'mariadb'
            source 'debian/mariadb-server.seed.erb'
            owner 'root'
            group 'root'
            mode '0600'
            variables(:config => new_resource)
            action :create
            notifies :run, 'execute[preseed mariadb-server]', :immediately
          end

          execute 'preseed mariadb-server' do
            command '/usr/bin/debconf-set-selections /var/cache/local/preseeding/mariadb-server.seed'
            action :nothing
          end

          # package automatically initializes database and starts service.
          # ... because that's totally super convenient.
          package new_resource.parsed_package_name do
            action :install
          end

          # service
          service 'mariadb' do
            provider Chef::Provider::Service::Init::Debian
            supports :restart => true
            action [:start, :enable]
          end

          execute 'assign-root-password' do
            sensitive true if sensitive_supported?
            cmd = "#{prefix_dir}/bin/mariadbadmin"
            cmd << ' -u root password '
            cmd << Shellwords.escape(new_resource.parsed_server_root_password)
            command cmd
            action :run
            only_if "#{prefix_dir}/bin/mariadb -u root -e 'show databases;'"
          end

          template '/etc/mariadb_grants.sql' do
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
            cmd = "#{prefix_dir}/bin/mariadb"
            cmd << ' -u root '
            cmd << "#{pass_string} < /etc/mariadb_grants.sql"
            command cmd
            action :nothing
            notifies :run, 'execute[create root marker]'
          end

          template '/etc/mariadb/debian.cnf' do
            cookbook 'mariadb'
            source 'debian/debian.cnf.erb'
            owner 'root'
            group 'root'
            mode '0600'
            variables(:config => new_resource)
            action :create
          end

          #
          directory include_dir do
            owner 'mariadb'
            group 'mariadb'
            mode '0750'
            recursive true
            action :create
          end

          directory run_dir do
            owner 'mariadb'
            group 'mariadb'
            mode '0755'
            action :create
            recursive true
          end

          directory new_resource.parsed_data_dir do
            owner 'mariadb'
            group 'mariadb'
            mode '0750'
            recursive true
            action :create
          end

          template '/etc/mariadb/my.cnf' do
            if new_resource.parsed_template_source.nil?
              source "#{new_resource.parsed_version}/my.cnf.erb"
              cookbook 'mariadb'
            else
              source new_resource.parsed_template_source
            end
            owner 'mariadb'
            group 'mariadb'
            mode '0600'
            variables(
              :data_dir => new_resource.parsed_data_dir,
              :pid_file => pid_file,
              :socket_file => socket_file,
              :port => new_resource.parsed_port,
              :include_dir => include_dir,
              :enable_utf8 => new_resource.parsed_enable_utf8
              )
            action :create
            notifies :run, 'bash[move mariadb data to datadir]'
            notifies :restart, 'service[mariadb]'
          end

          bash 'move mariadb data to datadir' do
            user 'root'
            code <<-EOH
              service mariadb stop \
              && mv /var/lib/mariadb/* #{new_resource.parsed_data_dir}
              EOH
            creates "#{new_resource.parsed_data_dir}/ibdata1"
            creates "#{new_resource.parsed_data_dir}/ib_logfile0"
            creates "#{new_resource.parsed_data_dir}/ib_logfile1"
            action :nothing
          end

          execute 'create root marker' do
            sensitive true if sensitive_supported?
            cmd = '/bin/echo'
            cmd << " '#{Shellwords.escape(new_resource.parsed_server_root_password)}'"
            cmd << ' > /etc/.mariadb_root'
            cmd << ' ;/bin/chmod 0600 /etc/.mariadb_root'
            command cmd
            action :nothing
          end
        end
      end

      action :restart do
        service 'mariadb' do
          provider Chef::Provider::Service::Init::Debian
          supports :restart => true
          action :restart
        end
      end

      action :reload do
        service 'mariadb' do
          provider Chef::Provider::Service::Init::Debian
          action :reload
        end
      end
    end
  end
end
