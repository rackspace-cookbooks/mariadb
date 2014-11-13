# Set the mariadb_service name from a node attribtue so resources can
# have different names in ChefSpec.

mariadb_service node['mariadb']['service_name']
