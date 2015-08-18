/*Disparador que inserta los valores para la tabla formulas*/

CREATE TRIGGER insercionFormulas
AFTER INSERT ON `datos_paneles`
FOR EACH ROW
BEGIN
	DECLARE energia_capt DECIMAL(10,2) DEFAULT 0;
	DECLARE energia_disp DECIMAL(10,2) DEFAULT 0;
	DECLARE eficiencia DECIMAL(10,2) DEFAULT 0;
	DECLARE deltat DECIMAL(10,2) DEFAULT 0;
	DECLARE dif_in_out DECIMAL(10,2) DEFAULT 0;
	DECLARE f01 DECIMAL(10,2) DEFAULT 0;
	DECLARE f02 DECIMAL(10,2) DEFAULT 0;
	DECLARE f03 DECIMAL(10,2) DEFAULT 0;
	DECLARE f04 DECIMAL(10,2) DEFAULT 0;
	DECLARE f05 DECIMAL(10,2) DEFAULT 0;

	DECLARE iniciov DECIMAL(10,2) DEFAULT 0;
	DECLARE finv DECIMAL(10,2) DEFAULT 0;
	DECLARE cpv DECIMAL(10,2) DEFAULT 0;
	DECLARE masav DECIMAL(10,2) DEFAULT 0;
	DECLARE areav DECIMAL(10,2) DEFAULT 0;

	# Constantes
	SET iniciov = (SELECT INICIO FROM constantes WHERE Id_Empresa = NEW.Id_Empresa);
	SET finv = (SELECT FIN FROM constantes WHERE Id_Empresa = NEW.Id_Empresa);
	SET cpv = (SELECT CP FROM constantes WHERE Id_Empresa = NEW.Id_Empresa);
	SET masav = (SELECT MASA FROM constantes WHERE Id_Empresa = NEW.Id_Empresa);
	SET areav = (SELECT AREA FROM constantes WHERE Id_Empresa = NEW.Id_Empresa);

	# Formulas
	IF NEW.Inclinacion > (iniciov+1) AND NEW.Pos_solar < finv
	AND NEW.Pos_solar > iniciov THEN
		SET f01 = NEW.Irradiacion;
		SET f02 = 1;
		SET f03 = NEW.Temp1;
		SET f04 = NEW.Temp2;
		SET f05 = NEW.Temp_tanque;
	END IF;

	# Delt_T
	SET deltat = (SELECT MIN(Formula5) FROM formulas
	WHERE Id_Empresa = NEW.Id_Empresa AND DATE(Fecha) = DATE(NEW.Fecha) AND Formula5 > 0);

	IF deltat IS NOT NULL THEN
		IF f05 < deltat THEN
			SET deltat = f05;
		END IF;
	ELSE SET deltat = 0;
	END IF;

	SET deltat = f05 - deltat;

	# Energia_disp

	SET energia_disp = (SELECT formulas.Energia_disp FROM formulas WHERE Id_Empresa = NEW.Id_Empresa
	AND Hora = (SELECT MAX(Hora) FROM formulas WHERE Id_Empresa = NEW.Id_Empresa AND DATE(Fecha) = DATE(NEW.Fecha)) LIMIT 1);

	IF energia_disp IS NULL THEN
		SET energia_disp = 0;
	END IF;

	SET energia_disp = ((f01 * areav * 60)/1000) + energia_disp;

	# Energia_capt y Eficiencia
	IF f02 > 0 THEN
		SET energia_capt = (cpv * masav * deltat)/1000;
		SET eficiencia = (energia_capt/energia_disp)*100;
	END IF;

	# Dif_in_out
	SET dif_in_out = f03 - f04;

	# INSTRUCCION DE INSERCION
	INSERT INTO formulas (Id_Empresa,Energia_capt,Energia_disp,Eficiencia,Delta_T,
						  Dif_in_out,Formula1,Formula2,Formula3,Formula4,Formula5,Fecha,Hora)
	VALUES (NEW.Id_Empresa,energia_capt,energia_disp,eficiencia,deltat,dif_in_out,f01,f02,f03,f04,f05,NEW.Fecha,NEW.Hora);

	IF NEW.Hora >= '22:00:00' AND NEW.Hora < '22:01:00' THEN
		CALL insertaConcentrado(NEW.Id_Empresa,NEW.Fecha,cpv,masav,areav);
	END IF;
END;

/*Procedimiento almacenado que inserta los datos en la tabla de concentrado correspondientes al dia*/

CREATE PROCEDURE insertaConcentrado(id VARCHAR(3), fecha_act DATETIME, cp DECIMAL(10,2), masa DECIMAL(10,2), area DECIMAL(10,2))
BEGIN
	DECLARE sumf01 DECIMAL(10,2) DEFAULT 0;
	DECLARE sumf03 DECIMAL(10,2) DEFAULT 0;
	DECLARE sumf04 DECIMAL(10,2) DEFAULT 0;
	DECLARE gasv DECIMAL(10,2) DEFAULT 0;
	DECLARE kcal_kgv DECIMAL(10,2) DEFAULT 0;
	DECLARE kg_kgv DECIMAL(10,2) DEFAULT 0;
	DECLARE kj_kcalv DECIMAL(10,2) DEFAULT 0;
	DECLARE effv DECIMAL(10,2) DEFAULT 0;

	DECLARE prom_irrad DECIMAL(10,2) DEFAULT 0;
	DECLARE prom_delta DECIMAL(10,2) DEFAULT 0;
	DECLARE deltat DECIMAL(10,2) DEFAULT 0;
	DECLARE tempmin DECIMAL(10,2) DEFAULT 0;
	DECLARE tempmax DECIMAL(10,2) DEFAULT 0;
	DECLARE tiempo_total DECIMAL(10,2) DEFAULT 0;
	DECLARE energia_capt DECIMAL(10,2) DEFAULT 0;
	DECLARE energia_disp DECIMAL(10,2) DEFAULT 0;
	DECLARE eficiencia DECIMAL(10,2) DEFAULT 0;
	DECLARE costokj DECIMAL(10,5) DEFAULT 0;
	DECLARE ganancia DECIMAL(10,5) DEFAULT 0;

	# Irradiacion solar y Tiempo total
	SET sumf01 = (SELECT SUM(Formula1) FROM formulas WHERE Id_Empresa = id AND DATE(Fecha) = DATE(fecha_act));
	SET tiempo_total = (SELECT SUM(Formula2) FROM formulas WHERE Id_Empresa = id AND DATE(Fecha) = DATE(fecha_act));
	SET prom_irrad = sumf01/tiempo_total;

	# Promedio Delta_T
	SET sumf03 = (SELECT SUM(Formula3) FROM formulas WHERE Id_Empresa = id AND DATE(Fecha) = DATE(fecha_act));
	SET sumf04 = (SELECT SUM(Formula4) FROM formulas WHERE Id_Empresa = id AND DATE(Fecha) = DATE(fecha_act));
	SET prom_delta = (sumf03/tiempo_total) - (sumf04/tiempo_total);

	# Temperatura minima, maxima y Delta T
	SET tempmin = (SELECT MIN(Formula5) FROM formulas WHERE Id_Empresa = id AND DATE(Fecha) = DATE(fecha_act) AND Formula5>0);
	SET tempmax = (SELECT MAX(Formula5) FROM formulas WHERE Id_Empresa = id AND DATE(Fecha) = DATE(fecha_act));
	SET deltat = tempmax - tempmin;

	#Energia captada, Energia disponible y Eficiencia
	SET energia_capt = (cp*masa*deltat)/1000;
	SET energia_disp = (sumf01*60*area)/1000;
	SET eficiencia = energia_capt/energia_disp;

	# costo/kj y Ganancia

	SET gasv = (SELECT GAS FROM constantes WHERE Id_Empresa = id);
	SET kcal_kgv = (SELECT KCAL_KG FROM constantes WHERE Id_Empresa = id);
	SET kg_kgv = (SELECT KG_KG FROM constantes WHERE Id_Empresa = id);
	SET kj_kcalv = (SELECT KJ_KCAL FROM constantes WHERE Id_Empresa = id);
	SET effv = (SELECT EFF FROM constantes WHERE Id_Empresa = id);

	SET costokj = gasv/(kcal_kgv*kg_kgv*kj_kcalv*effv);
	SET ganancia = costokj*energia_capt;

	INSERT INTO concentrado (Id_Empresa,Fecha,Irradiacion_solar,Promedio_Delta_T,Delta_T,Ener_captada,Ener_disponible,
							 Eficiencia,Masa,Temp_max,Temp_min,Ganancia,Tiempo_total,Costo_KJ) 
	VALUES (id,DATE(fecha_act),prom_irrad,prom_delta,deltat,energia_capt,energia_disp,eficiencia,masa,tempmax,tempmin,ganancia,tiempo_total,costokj);

END$$

/*Eliminación*/

DELETE FROM datos_paneles;
DELETE FROM formulas;
DELETE FROM concentrado;
