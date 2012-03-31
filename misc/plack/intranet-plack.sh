#!/bin/sh -xe

site=ffzg
test ! -z "$1" && site=$1
dir=`dirname $0`

export KOHA_CONF=/etc/koha/sites/$site/koha-conf.xml 
export INTRANETDIR="$( sudo -u $site-koha xmlstarlet sel -t -v 'yazgfs/config/intranetdir' $KOHA_CONF )"

if [ ! -e "$INTRANETDIR/C4" ] ; then
	echo "intranetdir in $KOHA_CONF doesn't point to Koha git checkout"
	exit 1
fi

# CGI scripts are automatically reloaded
opt="--reload -R $INTRANETDIR/C4"
sudo -E -u $site-koha plackup -I $INTRANETDIR -I $INTRANETDIR/installer $opt --port 5001 $dir/koha.psgi
