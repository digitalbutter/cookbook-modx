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

define :modx_site_install, :base_dir => '/var/www/', :name => nil, :db_name => nil, :db_user => nil do
  modx_directory = params[:base_dir] + params[:name] + "/"
  template_variables = {
      :site_dir => modx_directory,
      :db_name => params[:db_name]
  }

  variables = {
      :timezone => "Asia/Hong_Kong",
      :base_path => modx_directory,
      :base_url => "/",
      :dbase => params[:db_name],
      :database_user => params[:db_name],
      :database_password => node[:modx][:db_password],
      :database_connection_charset => "utf8",
      :database_charset => "utf8",
      :table_prefix => "modx_",
      :http_host => params[:name] + ".stg.tikiflow.com",
      :language => "en",
      :database_collation => "utf8_general_ci",
      :cmsadmin => "admin",
      :cmsadminemail => "email@address.com",
      :cmspassword => "password",
      :package_list => [
          { :name => "WayFinder-2.3.0-pl", :url => "http://modx.com/extras/download/?id=4d7e7d24f24554493c00009b" },
          { :name => "phpThumbOf-1.1.0-pl" , :url => "http://modx.com/extras/download/?id=4d6fafa2f245542dfe000097" },
          { :name => "getResources-1.3.0-pl", :url => "http://modx.com/extras/download/?id=4d9151f9f245547b00000021"  },
          { :name => "fileelementsmirror-0.3-alpha1", :url => "http://churn.butter.com.hk/assets/files/fileelementsmirror-0.3-alpha1.transport.zip"}
      ]
  }

  template modx_directory + "/install.php" do
    source "install.php.erb"
    cookbook "modx"
    variables variables
    owner "root"
    group "root"
    mode 0777
  end

  bash "install_modx" do
    user "root"
    cwd modx_directory
    code <<-EOH
  ./install.php
    EOH
  end

  directory "#{modx_directory}/core/cache" do
    mode "0777"
  end
end