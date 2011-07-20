INSERT INTO `systempreferences` (`variable`,`value`,`options`,`explanation`,`type`)
VALUES
	('decreaseLoanHighHolds', NULL, '', 'Decreases the loan period for items with number of holds above the threshold specified in decreaseLoanHighHoldsValue', 'YesNo');

INSERT INTO `systempreferences` (`variable`,`value`,`options`,`explanation`,`type`)
VALUES
	('decreaseLoanHighHoldsValue', NULL, '', 'Specifies a threshold for the minimum number of holds needed to trigger a reduction in loan duration (used with decreaseLoanHighHolds)', 'Integer');

INSERT INTO `systempreferences` (`variable`,`value`,`options`,`explanation`,`type`)
VALUES
	('decreaseLoanHighHoldsDuration', NULL, '', 'Specifies a number of days that a loan is reduced to when used in conjunction with decreaseLoanHighHolds', 'Integer');
