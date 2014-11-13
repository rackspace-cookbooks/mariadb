module MariadbCookbook
  module Helpers
    module Rhel
      def base_dir
        case node['platform_version'].to_i
        when 5
          case new_resource.parsed_version
          when '5.0'
            base_dir = ''
          when '5.1'
            base_dir = '/opt/rh/mariadb51/root'
          when '5.5'
            base_dir = '/opt/rh/mariadb55/root'
          end
        end
        base_dir
      end

      def include_dir
        case node['platform_version'].to_i
        when 2014, 2013, 7, 6
          include_dir = '/etc/mariadb/conf.d'
        when 5
          include_dir = "#{base_dir}/etc/mariadb/conf.d"
        end
        include_dir
      end

      def prefix_dir
        case node['platform_version'].to_i
        when 2014, 2013, 7, 6
          prefix_dir =  '/usr'
        when 5
          case new_resource.parsed_version
          when '5.0'
            prefix_dir = '/usr'
          when '5.1'
            prefix_dir = '/opt/rh/mariadb51/root/usr'
          when '5.5'
            prefix_dir = '/opt/rh/mariadb55/root/usr'
          end
        end
        prefix_dir
      end

      def lc_messages_dir
        case node['platform_version'].to_i
        when 2014, 2013, 7, 6, 5
          lc_messages_dir = nil
        end
        lc_messages_dir
      end

      def run_dir
        case node['platform_version'].to_i
        when 2014, 2013, 7, 6
          run_dir = '/var/run/mariadbd'
        when 5
          case new_resource.parsed_version
          when '5.0'
            run_dir = '/var/run/mariadbd'
          when '5.1'
            run_dir = '/opt/rh/mariadb51/root/var/run/mariadbd/'
          when '5.5'
            run_dir = '/opt/rh/mariadb55/root/var/run/mariadbd/'
          end
        end
        run_dir
      end

      def pass_string
        if new_resource.parsed_server_root_password.empty?
          pass_string = ''
        else
          pass_string = '-p' + Shellwords.escape(new_resource.parsed_server_root_password)
        end

        pass_string = '-p' + ::File.open('/etc/.mariadb_root').read.chomp if ::File.exist?('/etc/.mariadb_root')
        pass_string
      end

      def pid_file
        case node['platform_version'].to_i
        when 2014, 2013, 7, 6, 5
          pid_file = '/var/run/mariadbd/mariadb.pid'
        end
        pid_file
      end

      def socket_file
        case node['platform_version'].to_i
        when 2014, 2013, 7, 6, 5
          socket_file = '/var/lib/mysql/mysql.sock'
        end
        socket_file
      end

      def service_name
        case node['platform_version'].to_i
        when 2014, 2013, 7, 6
          service_name = 'mariadbd'
        when 5
          case new_resource.parsed_version
          when '5.0'
            service_name = 'mariadbd'
          when '5.1'
            service_name = 'mariadb51-mariadbd'
          when '5.5'
            service_name = 'mariadb55-mariadbd'
          end
        end
        service_name
      end
    end
  end
end
