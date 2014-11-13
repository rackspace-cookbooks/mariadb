#
mariadb_service node['mariadb']['service_name'] do
  version node['mariadb']['version']
  port node['mariadb']['port']
  data_dir node['mariadb']['data_dir']
  template_source node['mariadb']['template_source']
  allow_remote_root node['mariadb']['allow_remote_root']
  remove_anonymous_users node['mariadb']['remove_anonymous_users']
  remove_test_database node['mariadb']['remove_test_database']
  root_network_acl node['mariadb']['root_network_acl']
  server_root_password node['mariadb']['server_root_password']
  server_debian_password node['mariadb']['server_debian_password']
  server_repl_password node['mariadb']['server_repl_password']
  package_version node['mariadb']['server_package_version']
  package_action node['mariadb']['server_package_action']
  action :create
end

log 'notify restart' do
  level :info
  notifies :restart, "mariadb_service[#{node['mariadb']['service_name']}]"
end

log 'notify reload' do
  level :info
  notifies :reload, "mariadb_service[#{node['mariadb']['service_name']}]"
end
