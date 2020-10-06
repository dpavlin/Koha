select userid, dateexpiry from borrower_debarments bd join borrowers b on b.borrowernumber = bd.borrowernumber where bd.type = 'DISCHARGE' and year(dateexpiry) = year( now() + interval 1 year ) ;

