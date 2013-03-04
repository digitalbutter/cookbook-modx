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

define :modx_site, :base_dir => '/var/www/', :name => nil, :src_dir => nil, :db_name => nil, :db_host => nil, :db_user => nil, :db_password => nil, :db_prefix => nil, :site_owner => "root", :site_group => "root", :base_url => '', :clear_cache => false do
  modx_directory = params[:src_dir] || params[:base_dir] + params[:name]

  log "Install #{params[:name]} into #{modx_directory}'"

  #Alphanumeric definition
  alphanumerics = [('0'..'9'),('A'..'Z'),('a'..'z')].map {|range| range.to_a}.flatten

  template_variables = {
      :site_dir => params[:src_dir] || modx_directory,
      :base_dir => modx_directory,
      :base_url => params[:base_url],
      :db_name => params[:db_name],
      :db_host => params[:db_host],
      :db_user => params[:db_user],
      :base_url => params[:base_url],
      :db_prefix => params[:db_prefix] || 'modx_',
      :db_password => params[:db_password],
      :app_name => params[:name],
      :sessionname => params[:name] + (0...13).map { alphanumerics[Kernel.rand(alphanumerics.size)] }.join,
      :uuid => `uuidgen`.strip,
      :current_time => Time.now.to_i
  }

  template "#{modx_directory}/core/config/config.inc.php" do
    cookbook "modx"
    source "core-config-config.inc.php.erb"
    mode "0464"
    owner params[:site_owner] 
    group params[:site_group] 
    variables template_variables
  end

  writable_paths = [
    'assets/components/phpthumbof/cache',
    'assets/images',
    'core/cache'
  ]

  writable_paths.each do |writable_path| 
    execute "chmod -R 774 #{modx_directory}/#{writable_path}" do
      command "chmod -R 774 #{modx_directory}/#{writable_path}"
      only_if do
        File.directory?("#{modx_directory}/#{writable_path}")
      end
    end

    variables { 
      "path" => "#{modx_directory}/#{}{writable_path}"
    }

    template "#{modx_directory}/#{writable_path}.htaccess" do
      source "blockFiles.erb"
      owner app['owner']
      group app['group']
      mode "574"
      variables variables 
      only_if do
        File.directory?("#{modx_directory}/#{writable_path}")
      end
    end
  end

  if params[:clear_cache]
    execute "rm #{modx_directory}/core/cache/*" do
        command "rm -rf #{modx_directory}/core/cache/*"
    end
  end
end
