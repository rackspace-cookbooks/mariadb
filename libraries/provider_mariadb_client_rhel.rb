require 'chef/provider/lwrp_base'

class Chef
  class Provider
    class MariadbClient
      class Rhel < Chef::Provider::MariadbClient
        def packages
          %w(MariaDB-client MariaDB-devel)
        end
      end
    end
  end
end
