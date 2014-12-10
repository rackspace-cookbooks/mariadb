MariaDB cookbook
=====================

The MariaDB cookbook exposes the `mariadb_service` and `mariadb_client`
resources. These resources are utilized by the `mariadb::client`
and `mariadb::server` recipes, or can be consumed in other recipes by
depending on the MySQL cookbook.

This cookbook also provides recipes to allow for setup of basic master/slave(s) replication on build.

This cookbook does its best to follow platform native idioms at all
times. This means things like logs, pid files, sockets, and service
managers work "as expected" by an administrator familiar with a given
platform.

Scope
-----
This cookbook is concerned with the "MariaDB Community Server" version,
packages are installed from the offical mariadb repositories and not specific OS versions.

This cookbook does not try to encompass every single configuration
option available for MariaDB. Instead, it provides a "just enough" to
get a the server running, then allows the user to specify additional
custom configuration.

Requirements
------------
* Chef 11 or higher
* Ruby 1.9 (preferably from the Chef full-stack installer)

Resources
---------------------
The resources that ship in this cookbook are examples of 'singleton
resources'. This means that there can only be one instance of them
configured on a machine. The providers that handle the implementation
of the `mariadb_service` and `mariadb_client` resources do so by following
platform native idioms. These usually only allow for one instance of a
service to be running at a given time.

### mariadb_service

The `mariadb_service` resource configures the basic plumbing
needed to run a simple mariadb_service with a minimal configuration.

Please note that when using `notifies` or `subscribes`, the resource
is `mariadb_service`. This means that this cookbook does _not_ setup
`service[mariadb]`.

### Example

    mariadb_service 'default' do
      version '5.1'
      port '3307'
      data_dir '/data'
      template_source 'custom.erb'
      allow_remote_root true
      root_network_acl ['10.9.8.7/6', '1.2.3.4/5']
      remove_anonymous_users false
      remove_test_database false
      server_root_password 'decrypt_me_from_a_databag_maybe'
      server_repl_password 'sync_me_baby_one_more_time'
      enable_utf8 true
      action :create
    end

The `version` parameter will allow the user to select from the
versions available for the platform, where applicable. When omitted,
it will install the default MariaDB version for the target platform.
Available version numbers are `5.5`, `10.0`, and `10.1`,
depending on platform.

The `port` parameter determines the listen port for the mariadb
service. When omitted, it will default to '3306'.

The `data_dir` parameter determines where the actual data files are
kept on the machine. This is useful when mounting external storage.
When omitted, it will default to the platform's native location.

The `template_source` parameter allows the user to override the
default minimal template used by the `mariadb_service` resource. When
omitted, it will select one shipped with the cookbook based on the
MySQL version.

The `allow_remote_root` parameter allows the user to specify whether
remote connections from the mariadb root user. When set to true, it is
recommended that it be used in combination with the `root_network_acl`
parameter. When omitted, it will default to false.

The `remove_anonymous_users` parameter allows the user to remove
anonymous users often installed by default with during the mariadb db
initialization. When omitted, it defaults to true.

The `remove_test_database` parameter allows the user to specify
whether or not the test database is removed. When omitted, it defaults
to true.

The `root_network_acl` parameter allows the user to specify a list of
subnets to accept connections for the root user from. When omitted, it
defaults to none.

The `server_root_password` parameter allows the user to specify the
root password for the mariadb database. This can be set explicitly in a
recipe, driven from a node attribute, or from data_bags. When omitted,
it defaults to `ilikerandompasswords`. Please be sure to change it.

The `server_debian_password` parameter allows the user to specify the
debian-sys-maint users password, used in log rotations and service
management on Debian and Debian derived platforms.

The `server_repl_password` parameter allows the user to specify the
password used by `'repl'@'%'`, used in clustering scenarios. When
omitted, it does not create the repl user or set a password.

The `enable_utf8` parameter allows the user to change default
charset to utf8.

The mariadb_service resource supports :create, :restart, and :reload actions.

### mariadb_client

The `mariadb_client` resource installs or removes the MariaDB client binaries and
development libraries

Recipes
-------
### mariadb::server

This recipe calls a `mariadb_service` resource, passing parameters
from node attributes.

### mariadb::client

This recipe calls a `mariadb_client` resource, with action :create

### mariadb::relication_master

This recipe is a wrapper around the `mariadb_service` which sets the server up as
a master server for replication.

### mariadb::replication_slave

This recipe is a wrapper around the `mariadb_service` which sets the server up as
a slave server for replication.

Usage
-----
The `mariadb::server` recipe and `mariadb_service` resources are designed to
provide a minimal configuration. The default `my.cnf` dropped off has
an `!includedir` directive. Site-specific configuration should be
placed in the platform's native location.

### run_list

Include `'recipe[mariadb::server]'` or `'recipe[mariadb::client]'` in your run_list.

### Wrapper cookbook

    node.set['mariadb']['server_root_password'] = 'yolo'
    node.set['mariadb']['port'] = '3308'
    node.set['mariadb']['data_dir'] = '/data'

    include_recipe 'mariadb::server'

    template '/etc/mariadb/conf.d/mysite.cnf' do
      owner 'mariadb'
      owner 'mariadb'
      source 'mysite.cnf.erb'
      notifies :restart, 'mariadb_service[default]'
    end

### Used directly in a recipe

    template '/etc/mariadb/conf.d/mysite.cnf' do
      owner 'mariadb'
      owner 'mariadb'
      source 'mysite.cnf.erb'
      notifies :restart, 'mariadb_service[default]'
    end

    mariadb_service 'default' do
      version '5.5'
      port '3307'
      data_dir '/data'
      template_source 'custom.erb'
      action :create
    end

### Setup of master/slave(s) replication

TWO CRITICAL STEPS TO REMEMBER:

First the IP addresses of master and slaves servers must be set as environment attributes prior to convergence of servers.

Second the master server must complete a converge before slaves can be converged, otherwise they will not be able to connect to the master server and will fail the converge.

You may also want to modify attributes such as slave_user and server_repl_password
to met your specific needs.

So as long as IP addresses are set in environment or roles, the only thing that is
required to get replication working is to include the recipes in your run list.

Master Server -  include mariadb::replication_master
Slave(s) Servers - inclide mariadb::replication_slave

Attributes
----------

    default['mariadb']['service_name'] = 'default'
    default['mariadb']['server_root_password'] = 'ilikerandompasswords'
    default['mariadb']['server_debian_password'] = 'postinstallscriptsarestupid'
    default['mariadb']['server_repl_password'] = 'needabettapasswd'
    default['mariadb']['replication']['slave_user'] = 'replicant'

    default['mariadb']['config_dir'] = '/etc/mysql'
    default['mariadb']['data_dir'] = '/var/lib/mariadb'
    default['mariadb']['port'] = '3306'
    default['mariadb']['bind_ip'] = nil


    ### used in grants.sql
    default['mariadb']['allow_remote_root'] = false
    default['mariadb']['remove_anonymous_users'] = true
    default['mariadb']['root_network_acl'] = nil

    ### server packag version and action
    default['mariadb']['version'] = '10.1'
    default['mariadb']['server_package_version'] = '10.1'
    default['mariadb']['server_package_action'] = 'install'
    default['mariadb']['templates']['user.my.cnf']['cookbook'] = 'mariadb'
    default['mariadb']['templates']['user.my.cnf']['source'] = 'user.my.cnf.erb'

    ### replication specific attributes
    default['mariadb']['replication']['master'] = nil
    default['mariadb']['replication']['slaves'] = %w()


License & Authors
-----------------
- Author:: Matthew Thode(<matt.thode@rackspace.com>)
- Author:: Christopher Coffey(<christopher.coffey@rackspace.com>)

```text
Copyright:: 2014 Rackspace Hosting, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

=)
