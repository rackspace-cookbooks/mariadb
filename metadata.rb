name 'mariadb'
maintainer 'Rackspace Hosting, Inc.'
maintainer_email 'rackspace-cookbooks@rackspace.com'
license 'Apache 2.0'
description 'Provides mariadb_service and mariadb_client resources'

version '0.0.1'

supports 'amazon'
supports 'redhat'
supports 'centos'
supports 'scientific'
supports 'fedora'
supports 'debian'
supports 'ubuntu'

depends 'apt'
depends 'yum'
depends 'chef-sugar'
depends 'build-essential'
