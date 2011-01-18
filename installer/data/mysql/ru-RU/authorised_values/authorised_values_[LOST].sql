DELETE FROM authorised_values WHERE category='LOST';

INSERT INTO authorised_values (category, authorised_value, lib) VALUES 
('LOST','0','Не утрачено'),
('LOST','1','Утрачено'),
('LOST','2','Длительная просрочка (утрачено)'),
('LOST','3','Потеряны и заплачено за экземпляр'),
('LOST','5','Отсутствует при запросе на резервирование'),
('LOST','4','Отсутствует при инвентиризации');

