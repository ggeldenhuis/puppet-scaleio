#!/bin/bash
puppet module install puppetlabs/stdlib
truncate -s 500GB /var/scaleio.device
/vagrant/installnewcode.sh
rm -r /root/anaconda-ks.cfg
