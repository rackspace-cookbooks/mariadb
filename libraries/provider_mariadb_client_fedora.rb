require 'chef/provider/lwrp_base'

class Chef
  class Provider
    class MariadbClient
      class Fedora < Chef::Provider::MariadbClient
        def packages
          %w(MariaDB-client MariaDB-devel)
        end
      end
    end
  end
end
