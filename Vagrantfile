# -- mode: ruby --
# vi: set ft=ruby :
Vagrant.configure("2") do |config|

 if Vagrant.has_plugin? "vagrant-vbguest"
  config.vbguest.no_install = true
  config.vbguest.auto_update = false
  config.vbguest.no_remote = true
 end

  $install_puppet = <<-PUPPET
    sudo apt-get update -y
    sudo apt-get install -y puppet
  PUPPET

 config.vm.define :haproxyServer do |haproxyServer|
  haproxyServer.vm.box = "bento/ubuntu-22.04"
  haproxyServer.vm.network :private_network, ip: "192.168.100.20"
  haproxyServer.vm.hostname = "haproxyServer"
  haproxyServer.vm.provision :puppet do |puppet|
    puppet.manifests_path = "puppet/manifests"
    puppet.manifest_file = "site.pp"
    puppet.module_path = "puppet/modules"
  end
 end

 config.vm.define :web1Server do |web1Server|
    web1Server.vm.box = "bento/ubuntu-22.04"
    web1Server.vm.network :private_network, ip: "192.168.100.30"
    web1Server.vm.hostname = "web1Server"
    web1Server.vm.provision :puppet do |puppet|
      puppet.manifests_path = "puppet/manifests"
      puppet.manifest_file = "site.pp"
      puppet.module_path = "puppet/modules"
    end
  end

 config.vm.define :web2Server do |web2Server|
    web2Server.vm.box = "bento/ubuntu-22.04"
    web2Server.vm.network :private_network, ip: "192.168.100.40"
    web2Server.vm.hostname = "web2Server"
    web2Server.vm.provision :puppet do |puppet|
      puppet.manifests_path = "puppet/manifests"
      puppet.manifest_file = "site.pp"
      puppet.module_path = "puppet/modules"
    end
  end

end