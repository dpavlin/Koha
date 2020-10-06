create temporary table remove_debarred as 
select b.borrowernumber, userid, dateexpiry from borrower_debarments bd join borrowers b on b.borrowernumber = bd.borrowernumber where bd.type = 'DISCHARGE' and year(dateexpiry) = year( now() + interval 1 year ) ;

select * from remove_debarred ;

delete from borrower_debarments where borrowernumber in (select borrowernumber from remove_debarred);

update borrowers set debarred = null, debarredcomment = null where borrowernumber in (select borrowernumber from remove_debarred);

