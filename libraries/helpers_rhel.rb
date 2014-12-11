module MariadbCookbook
  module Helpers
    module Rhel
      def lc_messages_dir
        case node['platform_version'].to_i
        when 2014, 2013, 7, 6, 5
          lc_messages_dir = nil
        end
        lc_messages_dir
      end

      def pass_string
        if new_resource.parsed_server_root_password.empty?
          pass_string = ''
        else
          pass_string = '-p' + Shellwords.escape(new_resource.parsed_server_root_password)
        end

        pass_string = '-p' + ::File.open('/etc/.mysql_root').read.chomp if ::File.exist?('/etc/.mysql_root')
        pass_string
      end

      def pid_file
        case node['platform_version'].to_i
        when 2014, 2013, 7, 6, 5
          pid_file = "/var/lib/mysql/#{node['hostname']}.pid"
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
    end
  end
end
