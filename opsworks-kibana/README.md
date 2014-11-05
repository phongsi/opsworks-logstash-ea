# opsworks-kibana cookbook

A wrapper around [lusis/chef-kibana](https://github.com/lusis/chef-kibana) to customize deployments to opsworks.

# Requirements

* yum
* apt
* nginx
* apache2
* git
* htpasswd

# Usage

Assumes you're using a (mostly default) nginx installation (no Apache support).

# Attributes

## opsworks-kibana::default

* `node['opsworks-kibana']['web_auth_enabled']` - Whether to enable http basic auth, defaults to `true`
* `node['opsworks-kibana']['web_user']` - Username for basic auth
* `node['opsworks-kibana']['web_password']` - Password for basic auth
