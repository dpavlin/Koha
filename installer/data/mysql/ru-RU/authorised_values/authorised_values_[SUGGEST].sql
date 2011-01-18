DELETE FROM authorised_values WHERE category='SUGGEST';

INSERT INTO authorised_values (category, authorised_value, lib) VALUES 
('SUGGEST', 'BSELL', 'Бестселлер'),
('SUGGEST', 'SCD',   'Экземпляр с полки поврежден'),
('SUGGEST', 'LCL',   'Библиотечный экземпляр утерян'),
('SUGGEST', 'AVILL', 'Доступный через межбиблиотечный обмен');

