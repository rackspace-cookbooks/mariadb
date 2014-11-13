#

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
