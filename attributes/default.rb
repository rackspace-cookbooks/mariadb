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

default['mariadb']['data_dir'] = '/var/lib/mysql'

# port
default['mariadb']['port'] = '3306'

# server package version and action
default['mariadb']['version'] = '10.1'
default['mariadb']['server_package_version'] = '10.1'
default['mariadb']['server_package_action'] = 'install'
