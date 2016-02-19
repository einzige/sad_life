# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "some-ruby-box"
  config.vm.box_url = "~/git/virtualka/package.box"

   config.vm.network :forwarded_port, guest: 3000, host: 3001
   config.vm.network :forwarded_port, guest: 1080, host: 1081

   config.vm.provider :virtualbox do |vb|
     vb.customize ['modifyvm', :id, '--memory', '2048', '--name', 'sad-life']
   end

   config.vm.synced_folder ".", "/home/vagrant/app"
   config.ssh.forward_agent = true
end
