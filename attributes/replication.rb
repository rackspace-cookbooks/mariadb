# attributes needed for use of the master/slave configuration recipes

default['mariadb']['replication']['master'] = nil
default['mariadb']['replication']['slaves'] = %w()

default['mariadb']['replication']['slave_user'] = 'replicant'

default['mariadb']['replication']['templates']['my.cnf']['cookbook'] = 'mariadb'
default['mariadb']['replication']['templates']['my.cnf']['source'] = 'replication/my.cnf.erb'

default['mariadb']['replication']['templates']['user.my.cnf']['cookbook'] = 'mariadb'
default['mariadb']['replication']['templates']['user.my.cnf']['source'] = 'replication/user.my.cnf.erb'

default['mariadb']['replication']['templates']['slave.cnf']['cookbook'] = 'mariadb'
default['mariadb']['replication']['templates']['slave.cnf']['source'] = 'replication/slave.cnf.erb'

default['mariadb']['replication']['templates']['master.cnf']['cookbook'] = 'mariadb'
default['mariadb']['replication']['templates']['master.cnf']['source'] = 'replication/master.cnf.erb'
