#
# Cookbook Name:: mariadb
# Recipe:: server
#
# Copyright 2008-2013, Chef Software, Inc.
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

include_recipe 'chef-sugar'
include_recipe 'mariadb::repo'

node.set_unless['mariadb']['bind_ip'] = best_ip_for(node)

mariadb_service node['mariadb']['service_name'] do
  version node['mariadb']['version']
  port node['mariadb']['port']
  data_dir node['mariadb']['data_dir']
  server_root_password node['mariadb']['server_root_password']
  server_debian_password node['mariadb']['server_debian_password']
  server_repl_password node['mariadb']['server_repl_password']
  allow_remote_root node['mariadb']['allow_remote_root']
  remove_anonymous_users node['mariadb']['remove_anonymous_users']
  remove_test_database node['mariadb']['remove_test_database']
  root_network_acl node['mariadb']['root_network_acl']
  package_version node['mariadb']['server_package_version']
  package_action node['mariadb']['server_package_action']
  enable_utf8 node['mariadb']['enable_utf8']
  action :create
end

# add /root/.my.cnf file to system for local MySQL management
template '/root/.my.cnf' do
  cookbook node['mariadb']['replication']['templates']['user.my.cnf']['cookbook']
  source node['mariadb']['replication']['templates']['user.my.cnf']['source']
  owner 'root'
  group 'root'
  mode '0600'
  variables(
  cookbook_name: cookbook_name,
  user: 'root',
  pass: node['mariadb']['server_root_password']
  )
end
