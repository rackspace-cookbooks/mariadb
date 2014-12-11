#
default['mariadb']['service_name'] = 'default'

# passwords
default['mariadb']['server_root_password'] = 'ilikerandompasswords'
default['mariadb']['server_debian_password'] = nil
default['mariadb']['server_repl_password'] = nil

# used in grants.sql
default['mariadb']['allow_remote_root'] = false
default['mariadb']['remove_anonymous_users'] = true
default['mariadb']['root_network_acl'] = nil

default['mariadb']['config_dir'] = '/etc/mysql'
default['mariadb']['data_dir'] = '/var/lib/mysql'

# ports and bind address
default['mariadb']['port'] = '3306'
# if you want server to be a stand-alone set bind_ip to 127.0.0.1 not nil
default['mariadb']['bind_ip'] = nil

# server package version and action
default['mariadb']['version'] = '10.1'
default['mariadb']['server_package_version'] = '10.1'
default['mariadb']['server_package_action'] = 'install'
