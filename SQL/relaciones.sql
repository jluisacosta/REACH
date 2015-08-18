
/* Relaciones tabla datos_paneles */

	ALTER TABLE  `datos_paneles` ADD CONSTRAINT  `fk_id_empresa` FOREIGN KEY (`Id_Empresa`) 
	REFERENCES `alejand_reach`.`empresas` (`Id_Empresa`) ON DELETE CASCADE ON UPDATE CASCADE;

	# Primero de asignó como clave primaria al atributo Id_Vineto en la tabla dir_viento

	ALTER TABLE  `datos_paneles` ADD CONSTRAINT  `fk_id_viento` FOREIGN KEY (`Id_Viento`) 
	REFERENCES `alejand_reach`.`dir_viento` (`Id_Viento`) ON DELETE CASCADE ON UPDATE CASCADE;

/* Relaciones tabla formulas */

	ALTER TABLE  `formulas` ADD CONSTRAINT  `fk_id_empresa2` FOREIGN KEY (`Id_Empresa`)
	REFERENCES `alejand_reach`.`datos_paneles` (`Id_Empresa`) ON DELETE CASCADE ON UPDATE CASCADE;

/* Relaciones tabla concentrado */

	ALTER TABLE  `concentrado` ADD CONSTRAINT  `fk_id_empresa3` FOREIGN KEY (`Id_empresa`)
	REFERENCES `alejand_reach`.`formulas` (`Id_Empresa`) ON DELETE CASCADE ON UPDATE CASCADE;

/* Relaciones tabla datos_personales */

	ALTER TABLE  `datos_personales` ADD CONSTRAINT  `fk_id_empresa4` FOREIGN KEY (`Id_empresa`)
	REFERENCES `alejand_reach`.`empresas` (`Id_Empresa`) ON DELETE CASCADE ON UPDATE CASCADE;

/* Relaciones tabla configuracion */

	/* El tipo de dato definido en la tabla configuracion para el atributo Id_Empresa era erroneo (INT)
	se cambió a VARCHAR 3 como viene especificado en el documento de la BD */

	ALTER TABLE  `configuracion` ADD CONSTRAINT  `fk_id_empresa5` FOREIGN KEY (`Id_Empresa`)
	REFERENCES `alejand_reach`.`empresas` (`Id_Empresa`) ON DELETE CASCADE ON UPDATE CASCADE;

	/* El tipo de dato definido en la tabla configuracion para el atributo Id_usuario era erroneo (VARCHAR 45)
	se cambió a VARCHAR 3 como viene especificado en el documento de la BD, además se asignó como clave
	primaria al atributo Id_usuario en la tabla usuarios */

	ALTER TABLE  `configuracion` ADD CONSTRAINT  `fk_id_usuario` FOREIGN KEY (`Id_usuario`)
	REFERENCES `alejand_reach`.`usuarios` (`Id_usuario`) ON DELETE CASCADE ON UPDATE CASCADE;

/* Relaciones tabla usuarios */

	ALTER TABLE  `usuarios` ADD CONSTRAINT  `fk_id_empresa6` FOREIGN KEY (`Id_empresa`)
	REFERENCES `alejand_reach`.`datos_personales` (`Id_empresa`) ON DELETE CASCADE ON UPDATE CASCADE;

	ALTER TABLE  `usuarios` ADD CONSTRAINT  `fk_id_persona` FOREIGN KEY (`Id_persona`)
	REFERENCES `alejand_reach`.`datos_personales` (`Id_persona`) ON DELETE CASCADE ON UPDATE CASCADE;

	ALTER TABLE  `usuarios` ADD CONSTRAINT  `fk_id_privilegio` FOREIGN KEY (`Id_privilegio`)
	REFERENCES `alejand_reach`.`privilegios` (`Id_privilegio`) ON DELETE CASCADE ON UPDATE CASCADE;

/* Relaciones tabla bitacora */

	ALTER TABLE  `bitacora` ADD CONSTRAINT  `fk_id_empresa7` FOREIGN KEY (`Id_empresa`)
	REFERENCES `alejand_reach`.`configuracion` (`Id_Empresa`) ON DELETE CASCADE ON UPDATE CASCADE;

	ALTER TABLE  `bitacora` ADD CONSTRAINT  `fk_id_usuario2` FOREIGN KEY (`Id_usuario`)
	REFERENCES `alejand_reach`.`configuracion` (`Id_usuario`) ON DELETE CASCADE ON UPDATE CASCADE;

/* Relaciones tabla constantes */

	/* El tipo de dato definido en la tabla constantes para el atributo Id_Empresa era erroneo (INT)
	se cambió a VARCHAR 3 como viene especificado en el documento de la BD */

	ALTER TABLE  `constantes` ADD CONSTRAINT  `fk_id_empresa8` FOREIGN KEY (`Id_Empresa`)
	REFERENCES `alejand_reach`.`empresas` (`Id_Empresa`) ON DELETE CASCADE ON UPDATE CASCADE;

