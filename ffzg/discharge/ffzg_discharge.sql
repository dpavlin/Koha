create table ffzg_discharges (
	id int not null auto_increment,	
	discharge_id int(11),
	borrower int(11),
    needed timestamp,
    validated timestamp,
    firstname text,
    surname text,
    userid text,
    oib text,
    jmbag text,
    k_borrowernumber int(11),
    k_firstname text,
    k_surname text,
    k_userid text,
    primary key(id)
);
