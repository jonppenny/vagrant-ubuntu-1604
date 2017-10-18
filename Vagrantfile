Vagrant.configure("2") do |config|
  config.vm.hostname = 'jonppenny-wordpress-dev'
  config.vm.box = "ubuntu/xenial64"
  config.vm.provision :shell, path: "bootstrap.sh"
  config.vm.network :forwarded_port, guest: 80, host: 8888
  config.vm.synced_folder "public/", "/var/www/html"
end
