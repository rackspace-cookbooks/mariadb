require 'chef/provider/lwrp_base'

class Chef
  class Provider
    class MariadbClient
      class Ubuntu < Chef::Provider::MariadbClient
        def packages
          %w(mariadb-client libmariadbclient-dev)
        end
      end
    end
  end
end
