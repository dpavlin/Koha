create table akzg_inventarna_knjiga (
	id int not null auto_increment primary key,
	year int not null,
	num int not null,
	biblionumber int not null,
	itemnumber int,
	last_update timestamp default current_timestamp on update current_timestamp,
	unique index akzg_inv_br(year,num)
);
