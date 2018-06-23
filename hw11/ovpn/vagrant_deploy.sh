#!/bin/sh
mkdir ovpn_test_reddare && cd ovpn_test_reddare
wget https://raw.githubusercontent.com/reddare/otus-linux/master/hw11/ovpn/Vagrantfile
vagrant plugin install vagrant-scp
vagrant up ovpn
mkdir client
vagrant scp :/home/vagrant/output/* client/
cd client
sudo openvpn client.conf
