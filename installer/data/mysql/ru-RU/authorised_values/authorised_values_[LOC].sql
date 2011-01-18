DELETE FROM authorised_values WHERE category='LOC';

INSERT INTO authorised_values (category, authorised_value, lib) VALUES 
('LOC','FIC',    'Художественная литература'),
('LOC','SCIENCE','Научный фонд'),
('LOC','CHILD',  'Детская область'),
('LOC','DISPLAY','На демонстрации'),
('LOC','NEW',    'На полке новых поступлений'),
('LOC','STAFF',  'Офис работников библиотеки'),
('LOC','GEN',    'Общее фондохранилище'),
('LOC','AV',     'Аудио-визуальные материалы'),
('LOC','REF',    'Справочник'),
('LOC','CART',   'Корзина/тележка с (возвращенными) книгами'),
('LOC','PROC',   'В центре обработки');
