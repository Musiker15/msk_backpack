INSERT INTO `items` (`name`, `label`, `weight`, `rare`, `can_remove`) VALUES
	('bag', 'Tasche', 4, 0, 1),
	('bag2', 'Tasche2', 4, 0, 1),
	('nobag', 'Tasche', 0, 0, 0)
;

CREATE TABLE `msk_backpack` (
  `identifier` varchar(80) NOT NULL,
  `bag` longtext DEFAULT NULL
);

ALTER TABLE `msk_backpack`
  ADD PRIMARY KEY (`identifier`);