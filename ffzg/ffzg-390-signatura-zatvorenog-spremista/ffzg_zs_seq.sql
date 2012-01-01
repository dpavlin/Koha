
drop table if exists ffzg_zs_seq;

create table ffzg_zs_seq (
	name varchar(2) unique not null,
	current integer unsigned not null
);

insert into ffzg_zs_seq values ('PA',100000);
insert into ffzg_zs_seq values ('PB',100000);
insert into ffzg_zs_seq values ('PC',100000);
insert into ffzg_zs_seq values ('PD',100000);
insert into ffzg_zs_seq values ('PE',100000);
insert into ffzg_zs_seq values ('DD',100000);
insert into ffzg_zs_seq values ('MR',100000);
insert into ffzg_zs_seq values ('DR',100000);
insert into ffzg_zs_seq values ('FO',100000);
insert into ffzg_zs_seq values ('SE',100000);

update ffzg_zs_seq
set current=(
	select
		max(substring_index(itemcallnumber,' ',-1))
	from items
	where substring_index(itemcallnumber,' ',1) = ffzg_zs_seq.name
);

update ffzg_zs_seq set current = 100000 where current < 100000 ;

select * from ffzg_zs_seq ;

delimiter |

create function ffzg_zs_nextval( seq_name varchar(2) )
returns integer unsigned
begin
	update ffzg_zs_seq set current = ( @next_val := current + 1 ) where name = seq_name ;
        return @next_val;
end|

delimiter ;
