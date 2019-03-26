#!/bin/sh -xe

sudo /etc/init.d/memcached restart
( time sudo -u ffzg-koha KOHA_CONF=/etc/koha/sites/ffzg/koha-conf.xml PERL5LIB=/srv/koha_ffzg ./installer/data/mysql/updatedatabase.pl 2>&1 ) | tee `date +%Y-%m-%d`.update.log
sudo /etc/init.d/memcached restart
sudo koha-plack --restart ffzg
