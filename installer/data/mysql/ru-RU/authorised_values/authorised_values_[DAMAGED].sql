DELETE FROM authorised_values WHERE category='DAMAGED';

INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES 
('DAMAGED','0','Без повреждений'),
('DAMAGED','1','Повреждено');

