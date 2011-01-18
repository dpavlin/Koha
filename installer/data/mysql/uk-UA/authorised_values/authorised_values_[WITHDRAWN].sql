DELETE FROM authorised_values WHERE category='WITHDRAWN';

INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES 
('WITHDRAWN','0','Не вилучено'),
('WITHDRAWN','1','Вилучено з обігу');
