#!/bin/sh -xe

# --max-requests decreased from 1000 to 50 to keep memory usage sane
# --workers 8 which is number of cores on machine

site=ffzg
test ! -z "$1" && site=$1 && shift
dir=`dirname $0`

# enable memcache - it's safe even on installation which don't have it
# since Koha has check on C4::Context
export MEMCACHED_SERVERS=localhost:11211
export MEMCACHED_NAMESPACE=$site
export MEMCACHED_DEBUG=1

export KOHA_CONF=/etc/koha/sites/$site/koha-conf.xml
export OPACDIR="$( sudo -u $site-koha xmlstarlet sel -t -v 'yazgfs/config/opacdir' $KOHA_CONF | sed 's,/cgi-bin/opac,,' )"
export LOGDIR="$( sudo -u $site-koha xmlstarlet sel -t -v 'yazgfs/config/logdir' $KOHA_CONF )"

# uncomment to enable logging
#opt="$opt --access-log $LOGDIR/opac-access.log --error-log $LOGDIR/opac-error.log"
opt="$opt --server Starman -M FindBin --max-requests 50 --workers 4 -E deployment"
opt="$opt --reload -R $OPACDIR/../C4 -R $OPACDIR/../Koha"
sudo -E -u $site-koha plackup -I $OPACDIR/.. $opt $* $dir/koha.psgi
