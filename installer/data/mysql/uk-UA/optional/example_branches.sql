-- TRUNCATE branches;
-- TRUNCATE branchcategories;
-- TRUNCATE branchrelations;

#************************************************* TABLE `brances`  *************************************************
INSERT INTO branches (branchcode, branchname, branchaddress1, branchaddress2, branchaddress3, branchphone, branchfax, branchemail, issuing, branchip, branchprinter) VALUES 
(                                  'AB',            'Абонемент',                'Україна',                'м. Тернопіль',
                'кабінет 53 (2-ий поверх)',             '8 (0352) 52-53-45',           '',             'lib@tu.edu.te.ua',         NULL,'',NULL)
ON DUPLICATE KEY UPDATE branchcode='AB', branchname='Абонемент', branchaddress1='Україна', branchaddress2='м. Тернопіль',
 branchaddress3='кабінет 53 (2-ий поверх)', branchphone='8 (0352) 52-53-45', branchfax='', branchemail='lib@tu.edu.te.ua', issuing=NULL, branchip='', branchprinter=NULL;

INSERT INTO branches (branchcode, branchname, branchaddress1, branchaddress2, branchaddress3, branchphone, branchfax, branchemail, issuing, branchip, branchprinter) VALUES 
('ABH', 'Абонемент художньої літератури', 'Україна', 'м. Тернопіль', 'кабінет 53 (2-ий поверх)', '8 (0352) 52-53-45', '', 'lib@tu.edu.te.ua', NULL, '', NULL)
ON DUPLICATE KEY UPDATE branchcode='ABH', branchname='Абонемент художньої літератури', branchaddress1='Україна', branchaddress2='м. Тернопіль',
 branchaddress3='кабінет 53 (2-ий поверх)', branchphone='8 (0352) 52-53-45', branchfax='', branchemail='lib@tu.edu.te.ua', issuing=NULL, branchip='', branchprinter=NULL;

INSERT INTO branches (branchcode, branchname, branchaddress1, branchaddress2, branchaddress3, branchphone, branchfax, branchemail, issuing, branchip, branchprinter) VALUES 
('CHZ', 'Читальний зал', 'Україна', 'м. Тернопіль', 'кабінет 58 (3-ій поверх)', '8 (0352) 52-53-45', '', 'lib@tu.edu.te.ua', NULL, '', NULL)
ON DUPLICATE KEY UPDATE branchcode='CHZ', branchname='Читальний зал', branchaddress1='Україна', branchaddress2='м. Тернопіль',
 branchaddress3='кабінет 58 (3-ій поверх)', branchphone='8 (0352) 52-53-45', branchfax='', branchemail='lib@tu.edu.te.ua', issuing=NULL, branchip='', branchprinter=NULL;

INSERT INTO branches (branchcode, branchname, branchaddress1, branchaddress2, branchaddress3, branchphone, branchfax, branchemail, issuing, branchip, branchprinter) VALUES 
('CHZP', 'Читальний зал періодики, каталог', 'Україна', 'м. Тернопіль', 'кабінет 2 (1-ий поверх)', '8 (0352) 52-53-45', '', 'lib@tu.edu.te.ua', NULL, '', NULL)
ON DUPLICATE KEY UPDATE branchcode='CHZP', branchname='Читальний зал періодики, каталог', branchaddress1='Україна', branchaddress2='м. Тернопіль', branchaddress3='кабінет 2 (1-ий поверх)', branchphone='8 (0352) 52-53-45', branchfax='', branchemail='lib@tu.edu.te.ua', issuing=NULL, branchip='', branchprinter=NULL;

INSERT INTO branches (branchcode, branchname, branchaddress1, branchaddress2, branchaddress3, branchphone, branchfax, branchemail, issuing, branchip, branchprinter) VALUES 
('ECHZ', 'Електронний читальний зал', 'Україна', 'м. Тернопіль', 'кабінет 54 (2-ий поверх)', '8 (0352) 52-53-45', '', 'lib@tu.edu.te.ua', NULL, '', NULL)
ON DUPLICATE KEY UPDATE branchcode='ECHZ', branchname='Електронний читальний зал', branchaddress1='Україна', branchaddress2='м. Тернопіль',
 branchaddress3='кабінет 54 (2-ий поверх)', branchphone='8 (0352) 52-53-45', branchfax='', branchemail='lib@tu.edu.te.ua', issuing=NULL, branchip='', branchprinter=NULL;

INSERT INTO branches (branchcode, branchname, branchaddress1, branchaddress2, branchaddress3, branchphone, branchfax, branchemail, issuing, branchip, branchprinter) VALUES 
('STL',  'Науково-технічна бібліотека Тернопільського національного технічного університету ім. Ів. Пулюя', 'Україна', 'м. Тернопіль', 'вул. Руська 56, кабінет 5 (другий корпус)', '8 (0352) 52-53-45', '', 'lib@tu.edu.te.ua', NULL, '', NULL)
ON DUPLICATE KEY UPDATE branchcode='STL', branchname='Науково-технічна бібліотека Тернопільського національного технічного університету ім. Ів. Пулюя', branchaddress1='Україна', branchaddress2='м. Тернопіль', branchaddress3='вул. Руська 56, кабінет 5 (другий корпус)', branchphone='8 (0352) 52-53-45', branchfax='', branchemail='lib@tu.edu.te.ua', issuing=NULL, branchip='', branchprinter=NULL;

-- ('LNSL', 'Львівська національна наукова бібліотека ім. В. Стефаника НАНУ', 'Україна', 'м. Львів', 'вул. Стефаника 2', '8 (032) 272-45-36', '', 'library@library.lviv.ua', NULL, '', NULL),
-- ('NPLU', 'Національна парламентська бібліотека України', 'Україна', 'м. Київ', 'вул. Грушевського, 1', '38 (044) 278-85-12', '38 (044) 278-85-12', 'office@nplu.org', NULL, '192.168.1.*', NULL)


#************************************************* TABLE `branchcategories`  *************************************************
INSERT INTO branchcategories (categorycode, categoryname, codedescription, categorytype) VALUES 
('HOME',   'Домівка',                    'Може встановлюватися як домашня бібліотека',   'properties')
ON DUPLICATE KEY UPDATE categorycode='HOME', categoryname='Домівка', codedescription='Може встановлюватися як домашня бібліотека', categorytype='properties';

INSERT INTO branchcategories (categorycode, categoryname, codedescription, categorytype) VALUES 
('ISSUE',  'Книговидача',                'Може видавати книги',                          'properties')
ON DUPLICATE KEY UPDATE categorycode='ISSUE', categoryname='Книговидача', codedescription='Може видавати книги', categorytype='properties';

INSERT INTO branchcategories (categorycode, categoryname, codedescription, categorytype) VALUES 
('NATIOS', 'Національна бібліотека',     'Пошукова область національних бібліотек',      'searchdomain')
ON DUPLICATE KEY UPDATE categorycode='NATIOS', categoryname='Національна бібліотека', codedescription='Пошукова область національних бібліотек', categorytype='searchdomain';

INSERT INTO branchcategories (categorycode, categoryname, codedescription, categorytype) VALUES 
('PUBLS',  'Публічні бібліотеки',        'Пошукова область публічних бібліотек',         'searchdomain')
ON DUPLICATE KEY UPDATE categorycode='PUBLS', categoryname='Публічні бібліотеки', codedescription='Пошукова область публічних бібліотек', categorytype='searchdomain';

INSERT INTO branchcategories (categorycode, categoryname, codedescription, categorytype) VALUES 
('UNIVS',  'Університетські бібліотеки', 'Пошукова область університетських бібліотек',  'searchdomain')
ON DUPLICATE KEY UPDATE categorycode='UNIVS', categoryname='Університетські бібліотеки', codedescription='Пошукова область університетських бібліотек', categorytype='searchdomain';


#************************************************* TABLE `branchrelations`  *************************************************
INSERT INTO branchrelations (branchcode, categorycode) VALUES ('AB',               'ISSUE')
ON DUPLICATE KEY UPDATE                             branchcode='AB',  categorycode='ISSUE';

INSERT INTO branchrelations (branchcode, categorycode) VALUES ('ABH',              'ISSUE')
ON DUPLICATE KEY UPDATE                             branchcode='ABH', categorycode='ISSUE';

INSERT INTO branchrelations (branchcode, categorycode) VALUES ('STL',              'HOME')
ON DUPLICATE KEY UPDATE                             branchcode='STL', categorycode='HOME';

INSERT INTO branchrelations (branchcode, categorycode) VALUES ('STL',              'UNIVS')
ON DUPLICATE KEY UPDATE                             branchcode='STL', categorycode='UNIVS';

-- ('LNSL', 'HOME'),
-- ('LNSL', 'NATIOS'),
-- ('NPLU', 'HOME'),
-- ('NPLU', 'NATIOS'),
