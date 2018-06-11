# -*- mode: ruby -*-
# vim: set ft=ruby :

MACHINES = {
:inetRouter => {
        :box_name => "centos/7",
        #:public => {:ip => '10.10.10.1', :adapter => 1},
        :net => [
                   {adapter: 2, auto_config: false, virtualbox__intnet: "router-net"},
                   {adapter: 3, auto_config: false, virtualbox__intnet: "router-net"}
               ]
  },

  :centralRouter => {
        :box_name => "centos/7",
        :net => [
                   #{ip: '192.168.255.2', adapter: 2, netmask: "255.255.255.252", virtualbox__intnet: "router-net"},
                   #{ip: '192.168.0.1', adapter: 3, netmask: "255.255.255.240", virtualbox__intnet: "dir-net"},
                   #{ip: '192.168.0.33', adapter: 4, netmask: "255.255.255.240", virtualbox__intnet: "hw-net"},
                   #{ip: '192.168.0.65', adapter: 5, netmask: "255.255.255.192", virtualbox__intnet: "wi-fi-net"}                  
                   {ip: '192.168.0.1', adapter: 2, netmask: "255.255.255.240", virtualbox__intnet: "dir-net"},
                   {ip: '192.168.0.33', adapter: 3, netmask: "255.255.255.240", virtualbox__intnet: "hw-net"},
                   {ip: '192.168.0.65', adapter: 4, netmask: "255.255.255.192", virtualbox__intnet: "wi-fi-net"}, 
                   {adapter: 5, auto_config: false, virtualbox__intnet: "router-net"},
                   {adapter: 6, auto_config: false, virtualbox__intnet: "router-net"}
                ]
  },  

  :centralServer => {
        :box_name => "centos/7",
        :net => [
                   {ip: '192.168.0.2', adapter: 2, netmask: "255.255.255.240", virtualbox__intnet: "dir-net"}
                ]
  },

  :office1Router => {
    :box_name => "centos/7",
    :net => [
               {ip: '192.168.254.2', adapter: 2, netmask: "255.255.255.252", virtualbox__intnet: "router-net"},
               {ip: '192.168.2.1', adapter: 3, netmask: "255.255.255.192", virtualbox__intnet: "dev-office1-net"},
               {ip: '192.168.2.65', adapter: 4, netmask: "255.255.255.192", virtualbox__intnet: "testservers-office1-net"},
               {ip: '192.168.2.129', adapter: 5, netmask: "255.255.255.192", virtualbox__intnet: "managers-net"},
               {ip: '192.168.2.193', adapter: 6, netmask: "255.255.255.192", virtualbox__intnet: "hardware-office1-net"},
               {ip: '192.168.3.1', adapter: 7, netmask: "255.255.255.192", virtualbox__intnet: "test-net"}
            ]
  },

  :office1Server => {
    :box_name => "centos/7",
    :net => [
               {ip: '192.168.2.2', adapter: 2, netmask: "255.255.255.192", virtualbox__intnet: "dev-office1-net"}
            ]
  },

  :testServer1 => {
    :box_name => "centos/7",
    :net => [
               {ip: '192.168.3.2', adapter: 2, netmask: "255.255.255.192", virtualbox__intnet: "test-net"},
               {adapter: 3, auto_config: false, virtualbox__intnet: "test-lan"}
            ]
  },
 
  :testClient1 => {
    :box_name => "centos/7",
    :net => [
               {ip: '192.168.3.3', adapter: 2, netmask: "255.255.255.192", virtualbox__intnet: "test-net"},
               {adapter: 3, auto_config: false, virtualbox__intnet: "test-lan"}
            ]
  },

  :testServer2 => {
    :box_name => "centos/7",
    :net => [
               {ip: '192.168.3.4', adapter: 2, netmask: "255.255.255.192", virtualbox__intnet: "test-net"},
               {adapter: 3, auto_config: false, virtualbox__intnet: "test-lan"}
            ]
  },
 
  :testClient2 => {
    :box_name => "centos/7",
    :net => [
               {ip: '192.168.3.5', adapter: 2, netmask: "255.255.255.192", virtualbox__intnet: "test-net"},
               {adapter: 3, auto_config: false, virtualbox__intnet: "test-lan"}
            ]
  },

  :office2Router => {
    :box_name => "centos/7",
    :net => [
              {ip: '192.168.253.2', adapter: 2, netmask: "255.255.255.252", virtualbox__intnet: "router-net"},
              {ip: '192.168.1.1', adapter: 3, netmask: "255.255.255.128", virtualbox__intnet: "dev-office2-net"},
              {ip: '192.168.1.129', adapter: 4, netmask: "255.255.255.192", virtualbox__intnet: "testservers-office2-net"},
              {ip: '192.168.1.193', adapter: 5, netmask: "255.255.255.192", virtualbox__intnet: "hardware-office2-net"}
            ]
  }, 
  
  :office2Server => {
    :box_name => "centos/7",
    :net => [
               {ip: '192.168.1.2', adapter: 2, netmask: "255.255.255.192", virtualbox__intnet: "dev-office2-net"}
            ]
  }

}

Vagrant.configure("2") do |config|

  MACHINES.each do |boxname, boxconfig|
      
    config.vm.define boxname do |box|

        box.vm.box = boxconfig[:box_name]
        box.vm.host_name = boxname.to_s

        config.vm.provider "virtualbox" do |v|
          v.memory = 256
        end

        boxconfig[:net].each do |ipconf|
          box.vm.network "private_network", ipconf
        end
        
        if boxconfig.key?(:public)
          box.vm.network "public_network", boxconfig[:public]
        end

        box.vm.provision "shell", inline: <<-SHELL
          mkdir -p ~root/.ssh
                cp ~vagrant/.ssh/auth* ~root/.ssh
        SHELL
        
        case boxname.to_s
          when "inetRouter"
            box.vm.provision "shell", run: "always", inline: <<-SHELL
              cat <<EOT >> /etc/sysconfig/network-scripts/ifcfg-bond0
DEVICE=bond0
NAME=bond0
TYPE=Bond
BONDING_MASTER=yes
IPADDR=192.168.255.1
PREFIX=30
IPV6INIT=no
MTU=9000
ONBOOT=yes
USERCTL=no
NM_CONTROLLED=yes
BOOTPROTO=none
BONDING_OPTS="mode=1 fail_over_mac=1 miimon=100"
EOT
              cat <<EOT > /etc/sysconfig/network-scripts/ifcfg-eth1
NM_CONTROLLED=yes
BOOTPROTO=none
ONBOOT=yes
DEVICE=eth1
PEERDNS=no
MASTER=bond0
SLAVE=yes
EOT
              cat <<EOT > /etc/sysconfig/network-scripts/ifcfg-eth2
NM_CONTROLLED=yes
BOOTPROTO=none
ONBOOT=yes
DEVICE=eth2
PEERDNS=no
MASTER=bond0
SLAVE=yes
EOT
              echo net.ipv4.conf.all.forwarding=1  >> /etc/sysctl.conf
              echo net.ipv4.ip_forward=1 >> /etc/sysctl.conf
              echo "192.168.0.0/16 via 192.168.255.2 dev bond0" >> /etc/sysconfig/network-scripts/route-bond0
              systemctl restart network
              iptables -t nat -A POSTROUTING ! -d 192.168.0.0/16 -o eth0 -j MASQUERADE
              SHELL
          when "centralRouter"
            box.vm.provision "shell", run: "always", inline: <<-SHELL
              echo net.ipv4.conf.all.forwarding=1  >> /etc/sysctl.conf
              echo net.ipv4.ip_forward=1 >> /etc/sysctl.conf
              #echo "GATEWAY=192.168.255.1" >> /etc/sysconfig/network-scripts/ifcfg-eth1
              echo "DEFROUTE=no" >> /etc/sysconfig/network-scripts/ifcfg-eth0 
              cat <<EOT >> /etc/sysconfig/network-scripts/ifcfg-bond0
DEVICE=bond0
NAME=bond0
TYPE=Bond
BONDING_MASTER=yes
IPADDR=192.168.255.2
GATEWAY=192.168.255.1
PREFIX=30
IPV6INIT=no
MTU=9000
ONBOOT=yes
USERCTL=no
NM_CONTROLLED=yes
BOOTPROTO=none
BONDING_OPTS="mode=1 fail_over_mac=1 miimon=100"
EOT
              cat <<EOT > /etc/sysconfig/network-scripts/ifcfg-eth4
NM_CONTROLLED=yes
BOOTPROTO=none
ONBOOT=yes
DEVICE=eth4
PEERDNS=no
MASTER=bond0
SLAVE=yes
EOT
              cat <<EOT > /etc/sysconfig/network-scripts/ifcfg-eth5
NM_CONTROLLED=yes
BOOTPROTO=none
ONBOOT=yes
DEVICE=eth5
PEERDNS=no
MASTER=bond0
SLAVE=yes
EOT
              cat <<EOT >> /etc/sysconfig/network-scripts/ifcfg-bond0:0 
DEVICE=bond0:0
BOOTPROTO=static
IPADDR=192.168.254.1
NETMASK=255.255.255.252
ONBOOT=yes
EOT
              cat <<EOT >> /etc/sysconfig/network-scripts/ifcfg-bond0:1
DEVICE=bond0:1
BOOTPROTO=static
IPADDR=192.168.253.1
NETMASK=255.255.255.252
ONBOOT=yes
EOT
              #echo "192.168.2.0/24 via 192.168.254.2 dev eth1:0" >> /etc/sysconfig/network-scripts/route-eth1
              #echo "192.168.1.0/24 via 192.168.253.2 dev eth1:1" >> /etc/sysconfig/network-scripts/route-eth1
              #echo "192.168.3.0/24 via 192.168.254.2 dev eth1:0" >> /etc/sysconfig/network-scripts/route-eth1
              echo "192.168.2.0/24 via 192.168.254.2 dev bond0:0" >> /etc/sysconfig/network-scripts/route-bond0
              echo "192.168.3.0/24 via 192.168.254.2 dev bond0:0" >> /etc/sysconfig/network-scripts/route-bond0
              echo "192.168.1.0/24 via 192.168.253.2 dev bond0:1" >> /etc/sysconfig/network-scripts/route-bond0
              systemctl restart network
              SHELL
          when "centralServer"
            box.vm.provision "shell", run: "always", inline: <<-SHELL
              echo "DEFROUTE=no" >> /etc/sysconfig/network-scripts/ifcfg-eth0 
              echo "GATEWAY=192.168.0.1" >> /etc/sysconfig/network-scripts/ifcfg-eth1
              systemctl restart network
              SHELL
          when "office1Router"
            box.vm.provision "shell", run: "always", inline: <<-SHELL
              echo net.ipv4.ip_forward=1 >> /etc/sysctl.conf
              echo "DEFROUTE=no" >> /etc/sysconfig/network-scripts/ifcfg-eth0 
              echo "GATEWAY=192.168.254.1" >> /etc/sysconfig/network-scripts/ifcfg-eth1
              systemctl restart network
              SHELL
          when "office1Server"
            box.vm.provision "shell", run: "always", inline: <<-SHELL
              echo "DEFROUTE=no" >> /etc/sysconfig/network-scripts/ifcfg-eth0 
              echo "GATEWAY=192.168.2.1" >> /etc/sysconfig/network-scripts/ifcfg-eth1
              systemctl restart network
              SHELL
          when "testServer1"
            box.vm.provision "shell", run: "always", inline: <<-SHELL
              echo "DEFROUTE=no" >> /etc/sysconfig/network-scripts/ifcfg-eth0 
              echo "GATEWAY=192.168.3.1" >> /etc/sysconfig/network-scripts/ifcfg-eth1
              cat <<EOT >> /etc/sysconfig/network-scripts/ifcfg-vlan10
VLAN=yes
DEVICE=vlan10
PHYSDEV=eth2
VLAN_ID=10
BOOTPROTO=static
ONBOOT=yes
TYPE=Vlan
IPADDR=10.10.10.1
NETMASK=255.255.255.0
EOT
              systemctl restart network
              SHELL
          when "testClient1"
            box.vm.provision "shell", run: "always", inline: <<-SHELL
              echo "DEFROUTE=no" >> /etc/sysconfig/network-scripts/ifcfg-eth0 
              echo "GATEWAY=192.168.3.1" >> /etc/sysconfig/network-scripts/ifcfg-eth1
              cat <<EOT >> /etc/sysconfig/network-scripts/ifcfg-vlan10
VLAN=yes
DEVICE=vlan10
PHYSDEV=eth2
VLAN_ID=10
BOOTPROTO=static
ONBOOT=yes
TYPE=Vlan
IPADDR=10.10.10.254
NETMASK=255.255.255.0
EOT
              systemctl restart network
              SHELL
          when "testServer2"
            box.vm.provision "shell", run: "always", inline: <<-SHELL
              echo "DEFROUTE=no" >> /etc/sysconfig/network-scripts/ifcfg-eth0 
              echo "GATEWAY=192.168.3.1" >> /etc/sysconfig/network-scripts/ifcfg-eth1
              cat <<EOT >> /etc/sysconfig/network-scripts/ifcfg-vlan10
VLAN=yes
DEVICE=vlan20
PHYSDEV=eth2
VLAN_ID=20
BOOTPROTO=static
ONBOOT=yes
TYPE=Vlan
IPADDR=10.10.10.1
NETMASK=255.255.255.0
EOT
              systemctl restart network
              SHELL
          when "testClient2"
            box.vm.provision "shell", run: "always", inline: <<-SHELL
              echo "DEFROUTE=no" >> /etc/sysconfig/network-scripts/ifcfg-eth0 
              echo "GATEWAY=192.168.3.1" >> /etc/sysconfig/network-scripts/ifcfg-eth1
              cat <<EOT >> /etc/sysconfig/network-scripts/ifcfg-vlan10
VLAN=yes
DEVICE=vlan20
PHYSDEV=eth2
VLAN_ID=20
BOOTPROTO=static
ONBOOT=yes
TYPE=Vlan
IPADDR=10.10.10.254
NETMASK=255.255.255.0
EOT
              systemctl restart network
              SHELL
          when "office2Router"
              box.vm.provision "shell", run: "always", inline: <<-SHELL
                echo net.ipv4.ip_forward=1 >> /etc/sysctl.conf
                echo "DEFROUTE=no" >> /etc/sysconfig/network-scripts/ifcfg-eth0 
                echo "GATEWAY=192.168.253.1" >> /etc/sysconfig/network-scripts/ifcfg-eth1
                systemctl restart network
                SHELL
          when "office2Server"
            box.vm.provision "shell", run: "always", inline: <<-SHELL
              echo "DEFROUTE=no" >> /etc/sysconfig/network-scripts/ifcfg-eth0 
              echo "GATEWAY=192.168.1.1" >> /etc/sysconfig/network-scripts/ifcfg-eth1
              systemctl restart network
              SHELL
          
        end

      end

  end
  
end
