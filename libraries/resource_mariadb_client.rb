require 'chef/resource/lwrp_base'

class Chef
  class Resource
    class MariadbClient < Chef::Resource::LWRPBase
      self.resource_name = :mariadb_client
      actions :create, :delete
      default_action :create
    end
  end
end
