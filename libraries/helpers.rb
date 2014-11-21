module Opscode
  module Mariadb
    module Helpers
      def package_name_for(platform, platform_family, platform_version, version)
        keyname = keyname_for(platform, platform_family, platform_version)
        PlatformInfo.mariadb_info[platform_family][keyname][version]['package_name']
      rescue NoMethodError
        nil
      end

      def sensitive_supported?
        Gem::Version.new(Chef::VERSION) >= Gem::Version.new('11.14.0')
      end

      def keyname_for(platform, platform_family, platform_version)
        case
        when platform_family == 'rhel'
          platform == 'amazon' ? platform_version : platform_version.to_i.to_s
        when platform_family == 'suse'
          platform_version
        when platform_family == 'fedora'
          platform_version
        when platform_family == 'debian'
          if platform == 'ubuntu'
            platform_version
          elsif platform_version =~ /sid$/
            platform_version
          else
            platform_version.to_i.to_s
          end
        end
      rescue NoMethodError
        nil
      end
    end

    class PlatformInfo
      def self.mariadb_info
        @mariadb_info ||= {
          'rhel' => {
            '2013.09' => {
              '5.5' => {
                'package_name' => 'MariaDB-server'
              },
              '10.0' => {
                'package_name' => 'MariaDB-server'
              },
              '10.1' => {
                'package_name' => 'MariaDB-server'
              }
            },
            '2014.03' => {
              '5.5' => {
                'package_name' => 'MariaDB-server'
              },
              '10.0' => {
                'package_name' => 'MariaDB-server'
              },
              '10.1' => {
                'package_name' => 'MariaDB-server'
              }
            },
            '6' => {
              '5.5' => {
                'package_name' => 'MariaDB-server'
              },
              '10.0' => {
                'package_name' => 'MariaDB-server'
              },
              '10.1' => {
                'package_name' => 'MariaDB-server'
              }
            },
            '7' => {
              '5.5' => {
                'package_name' => 'MariaDB-server'
              },
              '10.0' => {
                'package_name' => 'MariaDB-server'
              },
              '10.1' => {
                'package_name' => 'MariaDB-server'
              }
            }
          },
          'fedora' => {
            '19' => {
              '5.5' => {
                'package_name' => 'MariaDB'
              },
              '10.0' => {
                'package_name' => 'MariaDB'
              },
              '10.1' => {
                'package_name' => 'MariaDB'
              }
            },
            '20' => {
              '5.5' => {
                'package_name' => 'MariaDB'
              },
              '10.0' => {
                'package_name' => 'MariaDB'
              },
              '10.1' => {
                'package_name' => 'MariaDB'
              }
            }
          },
          'debian' => {
            '7' => {
              '5.5' => {
                'package_name' => 'mariadb-server-5.5'
              },
              '10.0' => {
                'package_name' => 'mariadb-server-10.0'
              },
              '10.1' => {
                'package_name' => 'mariadb-server-10.1'
              }
            },
            'jessie/sid' => {
              '5.5' => {
                'package_name' => 'mariadb-server-5.5'
              },
              '10.0' => {
                'package_name' => 'mariadb-server-10.0'
              },
              '10.1' => {
                'package_name' => 'mariadb-server-10.1'
              }
            },
            '12.04' => {
              '5.5' => {
                'package_name' => 'mariadb-server-5.5'
              },
              '10.0' => {
                'package_name' => 'mariadb-server-10.0'
              },
              '10.1' => {
                'package_name' => 'mariadb-server-10.1'
              }
            },
            '14.04' => {
              '5.5' => {
                'package_name' => 'mariadb-server-5.5'
              },
              '10.0' => {
                'package_name' => 'mariadb-server-10.0'
              },
              '10.1' => {
                'package_name' => 'mariadb-server-10.1'
              }
            }
          }
        }
      end
    end
  end
end
