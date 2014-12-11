#
# Cookbook Name:: mariadb
# Recipe:: replication_master
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

node.default['apt']['compile_time_update'] = true

include_recipe 'apt' if platform_family?('debian')
include_recipe 'chef-sugar'
include_recipe 'mariadb::server'

# creates unique serverid via ipaddress to an int
require 'ipaddr'
serverid = IPAddr.new node['ipaddress']
serverid = serverid.to_i

# drop master specific configuration file
template "#{node['mariadb']['config_dir']}/conf.d/master.cnf" do
  cookbook node['mariadb']['replication']['templates']['master.cnf']['cookbook']
  source node['mariadb']['replication']['templates']['master.cnf']['source']
  variables(
  cookbook_name: cookbook_name,
  serverid: serverid
  )
  notifies :restart, "mariadb_service[#{node['mariadb']['service_name']}]", :immediately
end

execute 'grant-slave' do
  command <<-EOH
  /usr/bin/mysql -u root -p'#{node['mariadb']['server_root_password']}' < /root/grant-slaves.sql
  rm -f /root/grant-slaves.sql
  EOH
  action :nothing
end

# Grant replication user and control to slave(s)
node['mariadb']['replication']['slaves'].each do |slave|
  template "/root/grant-slaves.sql #{slave}" do
    path '/root/grant-slaves.sql'
    source 'replication/grant.slave.erb'
    owner 'root'
    group 'root'
    mode '0600'
    variables(
    user: node['mariadb']['replication']['slave_user'],
    password: node['mariadb']['server_repl_password'],
    host: slave
    )
    action :create
    notifies :run, 'execute[grant-slave]', :immediately
  end
end

node.set_unless['mariadb']['replication']['master'] = best_ip_for(node)

tag('mariadb_master')
