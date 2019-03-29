#!/bin/sh -xe
cd /srv/koha_ffzg/misc/translator
export KOHA_CONF=/etc/koha/sites/ffzg/koha-conf.xml
export PERL5LIB=/srv/koha_ffzg
./translate update
./translate install
