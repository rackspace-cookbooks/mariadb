module MariadbCookbook
  module Helpers
    module Debian
      def include_dir
        include_dir = '/etc/mariadb/conf.d'
        include_dir
      end

      def pid_file
        pid_file = '/var/run/mariadbd/mariadb.pid'
        pid_file
      end

      def prefix_dir
        prefix_dir = '/usr'
        prefix_dir
      end

      def run_dir
        run_dir = '/var/run/mariadbd'
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

      def socket_file
        socket_file = '/var/run/mysqld/mysqld.sock'
        socket_file
      end
    end
  end
end
