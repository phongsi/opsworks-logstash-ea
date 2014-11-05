# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.hostname = "kibana-wrapper-berkshelf"
  config.omnibus.chef_version = "11.4.0"

  # Every Vagrant virtual environment requires a box to build off of.
  #config.vm.box = "precise64"
  #config.vm.network :private_network, ip: "33.33.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.

  # config.vm.network :public_network

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  # config.vm.provider :virtualbox do |vb|
  #   # Don't boot with headless mode
  #   vb.gui = true
  #
  #   # Use VBoxManage to customize the VM. For example to change memory:
  #   vb.customize ["modifyvm", :id, "--memory", "1024"]
  # end

  # The path to the Berksfile to use with Vagrant Berkshelf
  # config.berkshelf.berksfile_path = "./Berksfile"

  # Enabling the Berkshelf plugin. To enable this globally, add this configuration
  # option to your ~/.vagrant.d/Vagrantfile file
  config.berkshelf.enabled = true

  # An array of symbols representing groups of cookbook described in the Vagrantfile
  # to exclusively install and copy to Vagrant's shelf.
  # config.berkshelf.only = []

  # An array of symbols representing groups of cookbook described in the Vagrantfile
  # to skip installing and copying to Vagrant's shelf.
  # config.berkshelf.except = []

  config.vm.box = "precise64"

  config.vm.provision :chef_solo do |chef|
    chef.json = 
      {
        kibana: { 
          webserver_listen: "0.0.0.0",
          webserver: "nginx",
          install_type: "git",
          config_cookbook: "opsworks-kibana",
          nginx: {
            template_cookbook: "opsworks-kibana"
          }
        },
        elasticsearch: {
          min_mem: '64m',
          max_mem: '64m',
          limits: {
              nofile: 1024,
              memlock: 512
          }
        },
      }
    chef.run_list = [ 
      "recipe[apt::default]",
      "recipe[java::default]",
      #"recipe[elasticsearch::default]",
      "recipe[opsworks-kibana::default]"
    ]
  end

  #config.vm.provision :shell, :inline => <<-FAKELOGSTASH
  #  INDEX=logstash-`date +"%Y.%m.%d"`
  #  TIMESTAMP=`date --iso-8601=seconds`
  #  curl -s -XPUT "http://localhost:9200/${INDEX}/"
  #  curl -s -XPOST "http://localhost:9200/${INDEX}/test/" -d '{ "@timestamp" : "'${TIMESTAMP}'", "message" : "I am not a real log" }'
  #FAKELOGSTASH

  config.vm.network "forwarded_port", guest: 80, host: 8080
  config.vm.network "forwarded_port", guest: 9200, host: 9200
  config.vm.network "private_network", ip: "33.33.33.88"



  # Ubuntu 12.04 Config
  #config.vm.define :ubuntu1204 do |ubuntu1204|
  #  ubuntu1204.vm.hostname = "ubuntu1204"
  #  ubuntu1204.vm.box = "opscode-ubuntu-12.04"
  #  ubuntu1204.vm.box_url = "https://opscode-vm-bento.s3.amazonaws.com/vagrant/opscode_ubuntu-12.04_provisionerless.box"
  #end

  # Ubuntu 13.04 Config
  #config.vm.define :ubuntu1304 do |ubuntu1304|
  #  ubuntu1304.vm.hostname = "ubuntu1304"
  #  ubuntu1304.vm.box = "opscode-ubuntu-13.04"
  #  ubuntu1304.vm.box_url = "https://opscode-vm-bento.s3.amazonaws.com/vagrant/opscode_ubuntu-13.04_provisionerless.box"
  #end

  #config.vm.provider :virtualbox do |vb|
  #  vb.customize ['modifyvm', :id, '--memory', '1024']
  #end
  


end
