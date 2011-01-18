-- TRUNCATE categories;


-- Совершеннолетние посетители

INSERT INTO categories (categorycode, description, enrolmentperiod, upperagelimit, dateofbirthrequired, finetype, bulk, enrolmentfee, overduenoticerequired, issuelimit, reservefee, category_type) VALUES 
(            'HB',                  'Посетители, находящиеся дома',                99,              999,                    18,         NULL,     NULL,             '0.000000',                      1,           NULL,           '0.000000',              'A')
ON DUPLICATE KEY UPDATE description='Посетители, находящиеся дома',enrolmentperiod=99,upperagelimit=999,dateofbirthrequired=18,finetype=NULL,bulk=NULL,enrolmentfee='0.000000',overduenoticerequired=1,issuelimit=NULL,reservefee='0.000000',category_type='A';

INSERT INTO categories (categorycode, description, enrolmentperiod, upperagelimit, dateofbirthrequired, finetype, bulk, enrolmentfee, overduenoticerequired, issuelimit, reservefee, category_type) VALUES 
(            'PT',                  'Посетитель',                99,              999,                    18,         NULL,     NULL,             '0.000000',                      1,           NULL,           '0.000000',              'A')
ON DUPLICATE KEY UPDATE description='Посетитель',enrolmentperiod=99,upperagelimit=999,dateofbirthrequired=18,finetype=NULL,bulk=NULL,enrolmentfee='0.000000',overduenoticerequired=1,issuelimit=NULL,reservefee='0.000000',category_type='A';

INSERT INTO categories (categorycode, description, enrolmentperiod, upperagelimit, dateofbirthrequired, finetype, bulk, enrolmentfee, overduenoticerequired, issuelimit, reservefee, category_type) VALUES 
(            'ST',                  'Студент',                99,              999,                    18,         NULL,     NULL,             '0.000000',                      1,           NULL,           '0.000000',              'A')
ON DUPLICATE KEY UPDATE description='Студент',enrolmentperiod=99,upperagelimit=999,dateofbirthrequired=18,finetype=NULL,bulk=NULL,enrolmentfee='0.000000',overduenoticerequired=1,issuelimit=NULL,reservefee='0.000000',category_type='A';

-- Дети

INSERT INTO categories (categorycode, description, enrolmentperiod, upperagelimit, dateofbirthrequired, finetype, bulk, enrolmentfee, overduenoticerequired, issuelimit, reservefee, category_type) VALUES 
(            'J',                   'Несовершеннолетний',                99,              17,                    5,         NULL,     NULL,             '0.000000',                      1,           NULL,           '0.000000',              'C')
ON DUPLICATE KEY UPDATE description='Несовершеннолетний',enrolmentperiod=99,upperagelimit=17,dateofbirthrequired=5,finetype=NULL,bulk=NULL,enrolmentfee='0.000000',overduenoticerequired=1,issuelimit=NULL,reservefee='0.000000',category_type='C';

INSERT INTO categories (categorycode, description, enrolmentperiod, upperagelimit, dateofbirthrequired, finetype, bulk, enrolmentfee, overduenoticerequired, issuelimit, reservefee, category_type) VALUES 
(            'K',                   'Ребёнок',                99,              17,                    5,         NULL,     NULL,             '0.000000',                      1,           NULL,           '0.000000',              'C')
ON DUPLICATE KEY UPDATE description='Ребёнок',enrolmentperiod=99,upperagelimit=17,dateofbirthrequired=5,finetype=NULL,bulk=NULL,enrolmentfee='0.000000',overduenoticerequired=1,issuelimit=NULL,reservefee='0.000000',category_type='C';

INSERT INTO categories (categorycode, description, enrolmentperiod, upperagelimit, dateofbirthrequired, finetype, bulk, enrolmentfee, overduenoticerequired, issuelimit, reservefee, category_type) VALUES 
(            'YA',                  'Юноша',                99,              17,                    5,         NULL,     NULL,             '0.000000',                      1,           NULL,           '0.000000',              'C')
ON DUPLICATE KEY UPDATE description='Юноша',enrolmentperiod=99,upperagelimit=17,dateofbirthrequired=5,finetype=NULL,bulk=NULL,enrolmentfee='0.000000',overduenoticerequired=1,issuelimit=NULL,reservefee='0.000000',category_type='C';

-- Член коллектива, организации, объединения

INSERT INTO categories (categorycode, description, enrolmentperiod, upperagelimit, dateofbirthrequired, finetype, bulk, enrolmentfee, overduenoticerequired, issuelimit, reservefee, category_type) VALUES 
(            'B',                   'Совет',                99,              17,                    5,         NULL,     NULL,             '0.000000',                      1,           NULL,           '0.000000',              'P')
ON DUPLICATE KEY UPDATE description='Совет',enrolmentperiod=99,upperagelimit=17,dateofbirthrequired=5,finetype=NULL,bulk=NULL,enrolmentfee='0.000000',overduenoticerequired=1,issuelimit=NULL,reservefee='0.000000',category_type='P';

INSERT INTO categories (categorycode, description, enrolmentperiod, upperagelimit, dateofbirthrequired, finetype, bulk, enrolmentfee, overduenoticerequired, issuelimit, reservefee, category_type) VALUES 
(            'T',                   'Преподаватель',                99,              999,                    18,         NULL,     NULL,             '0.000000',                      0,           NULL,           '0.000000',              'P')
ON DUPLICATE KEY UPDATE description='Преподаватель',enrolmentperiod=99,upperagelimit=999,dateofbirthrequired=18,finetype=NULL,bulk=NULL,enrolmentfee='0.000000',overduenoticerequired=0,issuelimit=NULL,reservefee='0.000000',category_type='P';

-- Коллектив, организация, объединение

INSERT INTO categories (categorycode, description, enrolmentperiod, upperagelimit, dateofbirthrequired, finetype, bulk, enrolmentfee, overduenoticerequired, issuelimit, reservefee, category_type) VALUES 
(            'IL',                  'Межбиблиотечный обмен',                99,              999,                    18,         NULL,     NULL,             '0.000000',                      1,           NULL,           '0.000000',              'I')
ON DUPLICATE KEY UPDATE description='Межбиблиотечный обмен',enrolmentperiod=99,upperagelimit=999,dateofbirthrequired=18,finetype=NULL,bulk=NULL,enrolmentfee='0.000000',overduenoticerequired=1,issuelimit=NULL,reservefee='0.000000',category_type='I';

INSERT INTO categories (categorycode, description, enrolmentperiod, upperagelimit, dateofbirthrequired, finetype, bulk, enrolmentfee, overduenoticerequired, issuelimit, reservefee, category_type) VALUES 
(            'SC',                  'Школа',                99,              999,                    18,         NULL,     NULL,             '0.000000',                      1,           NULL,           '0.000000',              'I')
ON DUPLICATE KEY UPDATE description='Школа',enrolmentperiod=99,upperagelimit=999,dateofbirthrequired=18,finetype=NULL,bulk=NULL,enrolmentfee='0.000000',overduenoticerequired=1,issuelimit=NULL,reservefee='0.000000',category_type='I';


INSERT INTO categories (categorycode, description, enrolmentperiod, upperagelimit, dateofbirthrequired, finetype, bulk, enrolmentfee, overduenoticerequired, issuelimit, reservefee, category_type) VALUES 
(            'L',                   'Библиотека',                99,              999,                    18,         NULL,     NULL,             '0.000000',                      1,           NULL,           '0.000000',              'I')
ON DUPLICATE KEY UPDATE description='Библиотека',enrolmentperiod=99,upperagelimit=999,dateofbirthrequired=18,finetype=NULL,bulk=NULL,enrolmentfee='0.000000',overduenoticerequired=1,issuelimit=NULL,reservefee='0.000000',category_type='I';

-- Работник библиотеки

INSERT INTO categories (categorycode, description, enrolmentperiod, upperagelimit, dateofbirthrequired, finetype, bulk, enrolmentfee, overduenoticerequired, issuelimit, reservefee, category_type) VALUES 
(            'S',                   'Персонал библиотеки',                99,              999,                    18,         NULL,     NULL,             '0.000000',                      0,           NULL,           '0.000000',              'S')
ON DUPLICATE KEY UPDATE description='Персонал библиотеки',enrolmentperiod=99,upperagelimit=999,dateofbirthrequired=18,finetype=NULL,bulk=NULL,enrolmentfee='0.000000',overduenoticerequired=0,issuelimit=NULL,reservefee='0.000000',category_type='S';

