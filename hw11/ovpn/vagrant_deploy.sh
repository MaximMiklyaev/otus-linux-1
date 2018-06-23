#!/bin/sh
vagrant plugin install vagrant-scp
vagrant up ovpn
mkdir client
vagrant scp :/home/vagrant/output/* client/
cd client
sudo openvpn client.conf
