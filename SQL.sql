CREATE TABLE `mms_flyer` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`identifier` VARCHAR(50) NULL DEFAULT NULL COLLATE 'armscii8_general_ci',
	`charidentifier` VARCHAR(50) NULL DEFAULT NULL COLLATE 'armscii8_general_ci',
	`name` VARCHAR(50) NULL DEFAULT NULL COLLATE 'armscii8_general_ci',
	`flyername` LONGTEXT NULL DEFAULT NULL COLLATE 'armscii8_general_ci',
	`photolink` LONGTEXT NULL DEFAULT NULL COLLATE 'armscii8_general_ci',
	PRIMARY KEY (`id`) USING BTREE
)
COLLATE='armscii8_general_ci'
ENGINE=InnoDB
;
