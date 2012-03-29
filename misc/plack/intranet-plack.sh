#!/bin/sh -xe

site=ffzg
test ! -z "$1" && site=$1
dir=`dirname $0`

export KOHA_CONF=/etc/koha/sites/$site/koha-conf.xml 
export INTRANETDIR="$( xmlstarlet sel -t -v 'yazgfs/config/intranetdir' $KOHA_CONF )"

if [ ! -e "$INTRANETDIR/C4" ] ; then
	echo "intranetdir in $KOHA_CONF doesn't point to Koha git checkout"
	exit 1
fi

# we are not wathcing all CGI scripts since that tends to use a lot of CPU time for plackup
opt="--reload -R $INTRANETDIR/C4"
sudo -E -u $site-koha plackup -I $INTRANETDIR $opt --port 5001 $dir/koha.psgi
