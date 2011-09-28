#
# Cookbook Name:: modx
# Definition:: modx_site
# Author:: Ed Bosher <ed@butter.com.hk>
#
# Copyright 2011, Digital Butter Ltd.
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

define :modx_site, :base_dir => '/var/www/', :name => nil, :src_dir => nil, :db_name => nil, :db_host => nil, :db_user => nil, :db_password => nil, :db_prefix => nil do
  modx_directory = params[:base_dir] + params[:name]

  #Alphanumeric definition
  alphanumerics = [('0'..'9'),('A'..'Z'),('a'..'z')].map {|range| range.to_a}.flatten

  template_variables = {
      :site_dir => params[:src_dir] || modx_directory,
      :base_dir => modx_directory,
      :db_name => params[:db_name],
      :db_host => params[:db_host],
      :db_user => params[:db_user],
      :db_prefix => params[:db_prefix] || 'modx_',
      :db_password => params[:db_password],
      :app_name => params[:name],
      :sessionname => params[:name] + (0...13).map { alphanumerics[Kernel.rand(alphanumerics.size)] }.join,
      :uuid => `uuidgen`.strip,
      :current_time => Time.now.to_i
  }

  template "#{modx_directory}/config.core.php" do
    source "config.core.php.erb"
    mode "0644"
    owner "root"
    group "root"
    variables template_variables
  end

  template "#{modx_directory}/manager/config.core.php" do
    source "manager-config.core.php.erb"
    mode "0644"
    owner "root"
    group "root"
    variables template_variables
  end

  template "#{modx_directory}/core/config/config.inc.php" do
    source "core-config-config.inc.php.erb"
    mode "0644"
    owner "root"
    group "root"
    variables template_variables
  end

  template "#{modx_directory}/connectors/config.core.php." do
    source "connectors-config.core.php.erb"
    mode "0644"
    owner "root"
    group "root"
    variables template_variables
  end

  directory "#{modx_directory}/core/cache" do
    mode "0777"
  end
end
