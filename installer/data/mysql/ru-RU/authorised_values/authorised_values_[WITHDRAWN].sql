DELETE FROM authorised_values WHERE category='WITHDRAWN';

INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES 
('WITHDRAWN','0','Не изьято'),
('WITHDRAWN','1','Изъято из оборота');


