DELETE FROM authorised_values WHERE category='rusmarc856';

INSERT INTO authorised_values (category, authorised_value, lib) VALUES
('rusmarc856','1#','FTP'),
('rusmarc856','0#','Электронная почта');
