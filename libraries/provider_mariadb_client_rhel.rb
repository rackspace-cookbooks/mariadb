require 'chef/provider/lwrp_base'

class Chef
  class Provider
    class MariadbClient
      class Rhel < Chef::Provider::MariadbClient
        def packages
          %w(mariadb mariadb-devel)
        end
      end
    end
  end
end
