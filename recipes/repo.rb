#
# Cookbook Name:: mariadb
# Recipe:: repo
#
# Copyright 2014, Rackspace US, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# this is a picker based on https://downloads.mariadb.org/mariadb/repositories/

apt_repository 'mariadb-apt-repo' do
  uri "http://ftp.osuosl.org/pub/mariadb/repo/#{node['mariadb']['server_package_version']}/#{node['platform']}"
  distribution node['lsb']['codename']
  components ['main']
  keyserver 'keyserver.ubuntu.com'
  key '0xcbcb082a1bb943db'
  deb_src true
  action 'add'
  only_if { platform_family?('debain') }
end

if platform_family?('rhel') || platform_family?('fedora')
  if node['kernel']['machine'] == 'x86_64'
    repourl = "http://yum.mariadb.org/#{node['mariadb']['server_package_version']}/#{node['platform']}#{node['platform_version'].to_i}-amd64"
  else
    repourl = "http://yum.mariadb.org/#{node['mariadb']['server_package_version']}/#{node['platform']}#{node['platform_version'].to_i}-x86"
  end

  yum_repository 'mariadb-yum-repo' do
    description 'MariaDB repository'
    baseurl repourl
    gpgkey 'https://yum.mariadb.org/RPM-GPG-KEY-MariaDB'
    action 'create'
  end
end
