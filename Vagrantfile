Vagrant.configure("2") do |config|
  config.vm.hostname = 'ubuntu'
  config.vm.box = "ubuntu/xenial64"
  config.vm.provision :shell, path: "bootstrap.sh"
  config.vm.network "private_network", ip: "192.168.0.10"
  config.vm.synced_folder "", "/var/www/html", :owner=> 'www-data', :group=>'www-data', :mount_options => ['dmode=775', 'fmode=775']
end
