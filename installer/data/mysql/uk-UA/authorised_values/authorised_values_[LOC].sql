DELETE FROM authorised_values WHERE category='LOC';

INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES 
('LOC','FIC',    'Художня література'),
('LOC','SCIENCE','Науковий фонд'),
('LOC','CHILD',  'Дитяча область'),
('LOC','DISPLAY','На демонстрації'),
('LOC','NEW',    'На поличці нових надходжень'),
('LOC','STAFF',  'В офисе работников библиотеки '),
('LOC','GEN',    'Загальне фондосховище'),
('LOC','AV',     'Аудіо-візуальні матеріали'),
('LOC','REF',    'Довідник'),
('LOC','CART',   'Кошик/возик з (повернутими) книжками'),
('LOC','PROC',   'У центрі обробки');
