DELETE FROM authorised_values WHERE category='RESTRICTED';

INSERT INTO authorised_values (category, authorised_value, lib) VALUES 
('RESTRICTED','0','Без обмежень'),
('RESTRICTED','1','Доступ обмежений');
