-- TRUNCATE branches;
-- TRUNCATE branchcategories;
-- TRUNCATE branchrelations;

#************************************************* TABLE `brances`  *************************************************
INSERT INTO branches (branchcode, branchname, branchaddress1, branchaddress2, branchaddress3, branchphone, branchfax, branchemail, issuing, branchip, branchprinter) VALUES 
(                                  'AB',            'Абонемент',                'Украина',                'г. Тернополь',
                'кабинет 53 (2-ой этаж)',             '8 (0352) 52-53-45',           '',             'lib@tu.edu.te.ua',         NULL,'',NULL)
ON DUPLICATE KEY UPDATE branchcode='AB', branchname='Абонемент', branchaddress1='Украина', branchaddress2='г. Тернополь',
 branchaddress3='кабинет 53 (2-ой этаж)', branchphone='8 (0352) 52-53-45', branchfax='', branchemail='lib@tu.edu.te.ua', issuing=NULL, branchip='', branchprinter=NULL;

INSERT INTO branches (branchcode, branchname, branchaddress1, branchaddress2, branchaddress3, branchphone, branchfax, branchemail, issuing, branchip, branchprinter) VALUES 
('ABH', 'Абонемент художественной литературы', 'Украина', 'г. Тернополь', 'кабинет 53 (2-ой этаж)', '8 (0352) 52-53-45', '', 'lib@tu.edu.te.ua', NULL, '', NULL)
ON DUPLICATE KEY UPDATE branchcode='ABH', branchname='Абонемент художественной литературы', branchaddress1='Украина', branchaddress2='г. Тернополь',
 branchaddress3='кабинет 53 (2-ой этаж)', branchphone='8 (0352) 52-53-45', branchfax='', branchemail='lib@tu.edu.te.ua', issuing=NULL, branchip='', branchprinter=NULL;

INSERT INTO branches (branchcode, branchname, branchaddress1, branchaddress2, branchaddress3, branchphone, branchfax, branchemail, issuing, branchip, branchprinter) VALUES 
('CHZ', 'Читательский зал', 'Украина', 'г. Тернополь', 'кабинет 58 (3-ий этаж)', '8 (0352) 52-53-45', '', 'lib@tu.edu.te.ua', NULL, '', NULL)
ON DUPLICATE KEY UPDATE branchcode='CHZ', branchname='Читательский зал', branchaddress1='Украина', branchaddress2='г. Тернополь',
 branchaddress3='кабинет 58 (3-ий этаж)', branchphone='8 (0352) 52-53-45', branchfax='', branchemail='lib@tu.edu.te.ua', issuing=NULL, branchip='', branchprinter=NULL;

INSERT INTO branches (branchcode, branchname, branchaddress1, branchaddress2, branchaddress3, branchphone, branchfax, branchemail, issuing, branchip, branchprinter) VALUES 
('CHZP', 'Читательский зал периодики, каталог', 'Украина', 'г. Тернополь', 'кабинет 2 (1-ый этаж)', '8 (0352) 52-53-45', '', 'lib@tu.edu.te.ua', NULL, '', NULL)
ON DUPLICATE KEY UPDATE branchcode='CHZP', branchname='Читательский зал периодики, каталог', branchaddress1='Украина', branchaddress2='г. Тернополь', branchaddress3='кабинет 2 (1-ый этаж)', branchphone='8 (0352) 52-53-45', branchfax='', branchemail='lib@tu.edu.te.ua', issuing=NULL, branchip='', branchprinter=NULL;

INSERT INTO branches (branchcode, branchname, branchaddress1, branchaddress2, branchaddress3, branchphone, branchfax, branchemail, issuing, branchip, branchprinter) VALUES 
('ECHZ', 'Электронный читательский зал', 'Украина', 'г. Тернополь', 'кабинет 54 (2-ой этаж)', '8 (0352) 52-53-45', '', 'lib@tu.edu.te.ua', NULL, '', NULL)
ON DUPLICATE KEY UPDATE branchcode='ECHZ', branchname='Электронный читательский зал', branchaddress1='Украина', branchaddress2='г. Тернополь',
 branchaddress3='кабинет 54 (2-ой этаж)', branchphone='8 (0352) 52-53-45', branchfax='', branchemail='lib@tu.edu.te.ua', issuing=NULL, branchip='', branchprinter=NULL;

INSERT INTO branches (branchcode, branchname, branchaddress1, branchaddress2, branchaddress3, branchphone, branchfax, branchemail, issuing, branchip, branchprinter) VALUES 
('STL',  'Научно-техническая библиотека Тернопольского национального техниеского университета им. Ив Пулюя', 'Украина', 'г. Тернополь', 'ул. Руська 56, кабинет 5 (второй корпус)', '8 (0352) 52-53-45', '', 'lib@tu.edu.te.ua', NULL, '', NULL)
ON DUPLICATE KEY UPDATE branchcode='STL', branchname='Научно-техническая библиотека Тернопольского национального техниеского университета им. Ив Пулюя', branchaddress1='Украина', branchaddress2='г. Тернополь', branchaddress3='ул. Руська 56, кабинет 5 (второй корпус)', branchphone='8 (0352) 52-53-45', branchfax='', branchemail='lib@tu.edu.te.ua', issuing=NULL, branchip='', branchprinter=NULL;

-- ('LNSL', 'Львовская национальная научная библиотека им. В.Стефаника НАНУ', 'Украина', 'г. Львов', 'ул. Стефаника 2', '8 (032) 272-45-36', '', 'library@library.lviv.ua', NULL, '', NULL),
-- ('NPLU', 'Национальная парламентская библиотека Украины', 'Украина', 'г. Киев', 'ул. Грушевского, 1', '38 (044) 278-85-12', '38 (044) 278-85-12', 'office@nplu.org', NULL, '192.168.1.*', NULL)


#************************************************* TABLE `branchcategories`  *************************************************
INSERT INTO branchcategories (categorycode, categoryname, codedescription, categorytype) VALUES 
('HOME',   'Дом',                    'Может устанавливаться как домашняя библиотека',   'properties')
ON DUPLICATE KEY UPDATE categorycode='HOME', categoryname='Дом', codedescription='Может устанавливаться как домашняя библиотека', categorytype='properties';

INSERT INTO branchcategories (categorycode, categoryname, codedescription, categorytype) VALUES 
('ISSUE',  'Книговыдача',                'Может выдавать книги',                          'properties')
ON DUPLICATE KEY UPDATE categorycode='ISSUE', categoryname='Книговыдача', codedescription='Может выдавать книги', categorytype='properties';

INSERT INTO branchcategories (categorycode, categoryname, codedescription, categorytype) VALUES 
('NATIOS', 'Национальные библиотеки',    'Поисковая область национальных библиотек',      'searchdomain')
ON DUPLICATE KEY UPDATE categorycode='NATIOS', categoryname='Национальные библиотеки', codedescription='Поисковая область национальных библиотек', categorytype='searchdomain';

INSERT INTO branchcategories (categorycode, categoryname, codedescription, categorytype) VALUES 
('PUBLS',  'Публичные библиотеки',       'Поисковая область публичных библиотек',         'searchdomain')
ON DUPLICATE KEY UPDATE categorycode='PUBLS', categoryname='Публичные библиотеки', codedescription='Поисковая область публичных библиотек', categorytype='searchdomain';

INSERT INTO branchcategories (categorycode, categoryname, codedescription, categorytype) VALUES 
('UNIVS',  'Университетские библиотеки', 'Поисковая область университетских библиотек',  'searchdomain')
ON DUPLICATE KEY UPDATE categorycode='UNIVS', categoryname='Университетские библиотеки', codedescription='Поисковая область университетских библиотек', categorytype='searchdomain';


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
