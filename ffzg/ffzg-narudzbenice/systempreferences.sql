update systempreferences set value='pdfformat::ffzg' where variable = 'OrderPdfFormat' ;

alter table aqbasketgroups add column ffzg_date datetime default now() ;

alter table aqbasketgroups add column ffzg_year int ;
alter table aqbasketgroups add column ffzg_nr int ;


-- basketgroups za stare nadužbenice
