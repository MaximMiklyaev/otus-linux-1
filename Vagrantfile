# -*- mode: ruby -*-
# vim: set ft=ruby :

MACHINES = {
  :otuslinux => {
        :box_name => "centos/7",
        :ip_addr => '192.168.11.101'
  },
}

Vagrant.configure("2") do |config|

  MACHINES.each do |boxname, boxconfig|

      config.vm.define boxname do |box|

          box.vm.box = boxconfig[:box_name]
          box.vm.host_name = boxname.to_s

          #box.vm.network "forwarded_port", guest: 3260, host: 3260+offset

          box.vm.network "private_network", ip: boxconfig[:ip_addr]

          box.vm.provider :virtualbox do |vb|
            vb.customize ["modifyvm", :id, "--memory", "1024"]

            unless File.exist?("disk-1.vmdk")
              vb.customize ["storagectl", :id, "--name", "SATA", "--add", "sata", "--portcount", "10", "--bootable" , "on"]
            end  

            (1..4).each do |i|  
              unless File.exist?("disk-#{i}.vmdk")
                vb.customize [ "createmedium", "disk", "--filename", "disk-#{i}.vmdk", "--format", "vmdk", "--size", 1024 * 10 ]
                vb.customize [ "storageattach", :id, "--storagectl", "SATA", "--port", i, "--device", "0", "--type", "hdd", "--medium", "disk-#{i}.vmdk"]
              end
            end
            
          end

          box.vm.provision :shell do |s|
             s.inline = 'mkdir -p ~root/.ssh; cp ~vagrant/.ssh/auth* ~root/.ssh'
          end

          $raid = <<SCRIPT
          yum install -y mdadm gdisk
          mdadm --create --verbose /dev/md0 --level=5 --raid-devices=4 /dev/sd[b-e]
          cat /proc/mdstat
          bash -c "mdadm --detail --scan > /etc/mdadm.conf"
          mkfs.ext4 /dev/md0
          mkdir -p /mnt/raid5
          chmod 777 /mnt/raid5
          bash -c "echo /dev/md0 /mnt/raid5 ext4 rw,user,exec 0 0 >> /etc/fstab"
          mount /mnt/raid5
          chmod 777 /mnt/raid5
SCRIPT

          #config.vm.provision "shell", inline: $raid

      end
  end
end

