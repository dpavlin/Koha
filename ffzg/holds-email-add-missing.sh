#!/bin/sh -xe

db=koha_ffzg

mysql --skip-column-names --batch -e 'select borrowernumber from borrowers order by borrowernumber asc' $db > /dev/shm/1

mysql --batch -e 'select distinct borrowernumber from borrower_message_preferences order by borrowernumber asc' $db > /dev/shm/2

wc -l /dev/shm/[12]

diff /dev/shm/[12] | grep '^< ' | cut -d' ' -f2 | xargs -i mysql -e 'insert into borrower_message_preferences (borrowernumber,message_attribute_id,days_in_advance) values ({},2,0),({},1,null),({},4,null),({},5,null),({},6,null) ;' $db

mysql --batch -e 'select distinct borrower_message_preference_id from borrower_message_transport_preferences order by borrower_message_preference_id asc' $db > /dev/shm/3

mysql --batch -e 'select borrower_message_preference_id from borrower_message_preferences where message_attribute_id = 4 order by borrower_message_preference_id asc' $db > /dev/shm/4

diff /dev/shm/[34] | grep '^> ' | cut -d' ' -f2 | xargs -i mysql -e "insert into borrower_message_transport_preferences (borrower_message_preference_id,message_transport_type) values ({},'email')" $db
