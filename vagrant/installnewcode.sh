#!/bin/bash
cd /vagrant/
cp hiera/*  /root/
cp puppet/* /root/
rm -rf /etc/puppetlabs/code/environments/production/modules/scaleio
cd /etc/puppetlabs/code/environments/production/modules
tar xzf /vagrant/puppet-scaleio.tgz
mv puppet-scaleio scaleio

ln -s /vagrant/rpms /root/rpms
cp /vagrant/rpms/scaleio.repo /etc/yum.repos.d/
