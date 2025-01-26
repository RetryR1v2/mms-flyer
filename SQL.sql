CREATE TABLE `mms_flyer` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`identifier` VARCHAR(50) NULL DEFAULT NULL COLLATE 'armscii8_general_ci',
	`charidentifier` INT(11) NULL DEFAULT NULL,
	`name` VARCHAR(50) NULL DEFAULT NULL COLLATE 'armscii8_general_ci',
	`flyername` LONGTEXT NULL DEFAULT NULL COLLATE 'armscii8_general_ci',
	`photolink` LONGTEXT NULL DEFAULT NULL COLLATE 'armscii8_general_ci',
	`hanging` INT(11) NULL DEFAULT '0',
	`hangtime` INT(11) NULL DEFAULT '0',
	`posx` FLOAT NULL DEFAULT '0',
	`posy` FLOAT NULL DEFAULT '0',
	`posz` FLOAT NULL DEFAULT '0',
	`postmodel` VARCHAR(50) NULL DEFAULT NULL COLLATE 'armscii8_general_ci',
	PRIMARY KEY (`id`) USING BTREE
)
COLLATE='armscii8_general_ci'
ENGINE=InnoDB
AUTO_INCREMENT=2
;
