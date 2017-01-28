#!/bin/sh -xe
test -d ip || mkdir ip
echo add usernames here with cp ip/10.60.0.92:9000 user/dpavlin@ffzg.hr
test -d user || mkdir user
test -d reader || mkdir reader
test -d download || mkdir download
# enable server write
sudo chgrp www-data ip reader download
sudo chmod g+w ip reader download
