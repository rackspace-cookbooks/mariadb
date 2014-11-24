# provider mappings

# client
Chef::Platform.set platform: :debian, resource: :mariadb_client, provider: Chef::Provider::MariadbClient::Debian
Chef::Platform.set platform: :fedora, resource: :mariadb_client, provider: Chef::Provider::MariadbClient::Fedora
Chef::Platform.set platform: :rhel, resource: :mariadb_client, provider: Chef::Provider::MariadbClient::Rhel
Chef::Platform.set platform: :amazon, resource: :mariadb_client, provider: Chef::Provider::MariadbClient::Rhel
Chef::Platform.set platform: :redhat, resource: :mariadb_client, provider: Chef::Provider::MariadbClient::Rhel
Chef::Platform.set platform: :centos, resource: :mariadb_client, provider: Chef::Provider::MariadbClient::Rhel
Chef::Platform.set platform: :oracle, resource: :mariadb_client, provider: Chef::Provider::MariadbClient::Rhel
Chef::Platform.set platform: :scientific, resource: :mariadb_client, provider: Chef::Provider::MariadbClient::Rhel
Chef::Platform.set platform: :ubuntu, resource: :mariadb_client, provider: Chef::Provider::MariadbClient::Ubuntu

# service
Chef::Platform.set platform: :debian, resource: :mariadb_service, provider: Chef::Provider::MariadbService::Debian
Chef::Platform.set platform: :fedora, resource: :mariadb_service, provider: Chef::Provider::MariadbService::Fedora
Chef::Platform.set platform: :amazon, resource: :mariadb_service, provider: Chef::Provider::MariadbService::Rhel
Chef::Platform.set platform: :redhat, resource: :mariadb_service, provider: Chef::Provider::MariadbService::Rhel
Chef::Platform.set platform: :centos, resource: :mariadb_service, provider: Chef::Provider::MariadbService::Rhel
Chef::Platform.set platform: :oracle, resource: :mariadb_service, provider: Chef::Provider::MariadbService::Rhel
Chef::Platform.set platform: :scientific, resource: :mariadb_service, provider: Chef::Provider::MariadbService::Rhel
Chef::Platform.set platform: :ubuntu, resource: :mariadb_service, provider: Chef::Provider::MariadbService::Ubuntu
