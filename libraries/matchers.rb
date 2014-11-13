if defined?(ChefSpec)
  def create_mariadb_client(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:mariadb_client, :create, resource_name)
  end

  def delete_mariadb_client(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:mariadb_client, :delete, resource_name)
  end

  def create_mariadb_service(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:mariadb_service, :create, resource_name)
  end

  def enable_mariadb_service(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:mariadb_service, :enable, resource_name)
  end
end
