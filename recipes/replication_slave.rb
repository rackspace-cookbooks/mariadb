#
# Cookbook Name:: mariadb
# Recipe:: replication_slave
#
# Copyright 2014, Rackspace US, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

node.default['build-essential']['compile_time'] = true
node.default['apt']['compile_time_update'] = true

include_recipe 'apt' if platform_family?('debian')
include_recipe 'build-essential'
include_recipe 'mariadb::client'
include_recipe 'mariadb::server'

chef_gem 'mysql' do
  action :install
end

# creates unique serverid via ipaddress to an int
require 'ipaddr'
serverid = IPAddr.new node['ipaddress']
serverid = serverid.to_i

# drop MySQL slave specific configuration file
template "#{node['mariadb']['config_dir']}/conf.d/slave.cnf" do
  cookbook node['mariadb']['replication']['templates']['slave.cnf']['cookbook']
  source node['mariadb']['replication']['templates']['slave.cnf']['source']
  variables(
  cookbook_name: cookbook_name,
  serverid: serverid
  )
  notifies :restart, "mariadb_service[#{node['mariadb']['service_name']}]", :immediately
end

# pull data from helper

host = node['mariadb']['replication']['master']
user = node['mariadb']['replication']['slave_user']
passwd = node['mariadb']['server_repl_password']

if Chef::Config[:solo]
  Chef::Log.warn('This only works on a chef server not chef solo.')
else
  log, pos = MariadbRep.bininfo(host, user, passwd)
  node.default['bin_log'] = log
  node.default['bin_pos'] = pos
  log "binlog- #{node['bin_log']} and binpos- #{node['bin_pos']}" do
    level :info
  end
end

# create and execute slave replication setup
execute 'set_master' do
  command <<-EOH
  /usr/bin/mysql -u root -p'#{node['mariadb']['server_root_password']}' < /root/change.master.sql
  rm -f /root/change.master.sql
  EOH
  action :nothing
end

template '/root/change.master.sql' do
  path '/root/change.master.sql'
  source 'replication/change.master.erb'
  owner 'root'
  group 'root'
  mode '0600'
  variables(
  host: node['mariadb']['replication']['master'],
  user: node['mariadb']['replication']['slave_user'],
  binlog: node['bin_log'],
  binpos: node['bin_pos'],
  password: node['mariadb']['server_repl_password']
  )
  notifies :run, 'execute[set_master]', :immediately
  not_if { File.exist?("#{node['mariadb']['data_dir']}/.replication") }
end

tag('mariadb_slave')

# drop guard file to keep replication from resetting on every chef run
template '.replication' do
  path "#{node['mariadb']['data_dir']}/.replication"
  source 'replication/replication_flag.erb'
  owner 'root'
  group 'root'
  mode '0600'
  action :create_if_missing
end
