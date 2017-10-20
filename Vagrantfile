Vagrant.configure("2") do |config|
  config.vm.hostname = 'jonppenny-wordpress-dev'
  config.vm.box = "ubuntu/xenial64"
  config.vm.provision :shell, path: "bootstrap.sh"
  config.vm.network :forwarded_port, guest: 80, host: 8080
  config.vm.synced_folder "", "/var/www/html", :owner=> 'www-data', :group=>'www-data', :mount_options => ['dmode=775', 'fmode=775']
end
