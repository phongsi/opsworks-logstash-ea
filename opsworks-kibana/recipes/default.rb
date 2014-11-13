#
# Cookbook Name:: opsworks-kibana
# Recipe:: default
#
# Copyright (C) 2014 YOUR_NAME
# 
# All rights reserved - Do Not Redistribute
#

include_recipe "kibana::default"

if node['opsworks-kibana']['web_auth_enabled']
  include_recipe 'htpasswd'
  include_recipe 'nginx'

  htpasswd "/etc/nginx/htpasswd" do
    user node['opsworks-kibana']['web_user']
    password node['opsworks-kibana']['web_password']
    notifies :reload, "service[nginx]"
  end
end