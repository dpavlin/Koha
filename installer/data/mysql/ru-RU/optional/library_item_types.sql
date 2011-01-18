TRUNCATE itemtypes;

# itemtype			- код типа,
# description		- описание, 
# rentalcharge		- плата за прокат,
# notforloan		- не для займа,
# imageurl			- путь к иконке,
# summary			- итог.

INSERT INTO `itemtypes` (`itemtype`, `description`, `rentalcharge`, `notforloan`, `imageurl`, `summary`) VALUES 
('BOOK',		' Книги',							0.0000, 0, 'bridge/book.gif',''),
('MIX',  	' Смешанные материалы',			0.0000, 0, 'bridge/kit.gif',''),
('MAP',  	'Картографические материалы',	0.0000, 0, 'bridge/map.gif',''),
('REF', 		'Справочники',						0.0000, 1, 'npl/Reference.gif',''),
('DICT',		'Словари',							0.0000, 0, 'vokal/Reference-32px.png',''),
('ENC',		'Энциклопедии',					0.0000, 0, 'vokal/HOLIDAY-32px.png',''),
('LEGAL',	'Законодательные акты',			0.0000, 0, 'npl/Faculty-Course-Materials.gif',''),
('LIT',		'Литературное произведение',	0.0000, 0, 'vokal/BOOK-32px.png',''),
#
('DISS',		'Дисертации',						0.0000, 1, 'npl/Faculty-Course-Materials.gif',''),
('THES',		'Авторефераты дисертаций',		0.0000, 1, 'npl/Faculty-Course-Materials.gif',''),
#
('PER',  	'Периодические издания',		0.0000, 0, 'bridge/periodical.gif',''),
('JOURNAL',	'Журналы',							0.0000, 0, 'bridge/journal.gif',''),
('ISSUE',  	'Номера/выпуски периодики',	0.0000, 0, 'bridge/periodical.gif',''),
('SERIAL', 	'Сериальные издания',			0.0000, 0, 'bridge/periodical.gif',''),
('CONT',  	'Продолжающиеся ресурсы',		0.0000, 0, 'bridge/periodical.gif',''),
#
('ARTICLE',	'Статьи периодики',				0.0000, 0, 'npl/SIRS.gif',''),
('PART',  	'Составные части документа',	0.0000, 0, 'npl/SIRS.gif',''),
#
('TECH',  	'Tехнические документы',		0.0000, 0, 'npl/Faculty-Course-Materials.gif',''),
('PAT',  	'Патентные документы',			0.0000, 0, 'npl/Faculty-Course-Materials.gif',''),
#
('METHOD', 	'Методические пособия',			0.0000, 0, 'bridge/book.gif',''),
('EDU', 		'Учебные издания',				0.0000, 0, 'npl/Juvenile-fiction.gif',''),
#
('CONF',  	'Материалы конференций',		0.0000, 0, 'npl/Biography.gif',''),
#
('VISUAL', 	'Визуальные материалы',			0.0000, 1, 'npl/AVA.gif',''),
('MUS',  	'Музыкальные произведения',	0.0000, 0, 'bridge/sound.gif',''),
('WEB',		'Интернет-ресурсы',				0.0000, 1, 'npl/WEB.gif',''),
('DISK',  	'Компьютерные диски',			0.0000, 0, 'npl/Music-CD.gif',''),
('FILE',  	'Компьютерные файлы',			0.0000, 0, 'bridge/computer_file.gif',''),
('AUDIO',  	'Аудио-материалы',				0.0000, 0, 'bridge/audio.gif',''),
('VIDEO',  	'Видео-материалы',				0.0000, 0, 'npl/Microfilm.gif',''),
#
('RARE',		'Редкие книги',					0.0000, 1, 'npl/Rare-Book.gif',''),
('ARHIV',	'Архивные материалы',			0.0000, 1, 'bridge/archive.gif',''),
('MANUS',  	'Рукописи',							0.0000, 1, 'npl/SIRS.gif','')
;
