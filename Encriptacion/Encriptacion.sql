USE G13COM5600
GO

-----

-- CREAR ESQUEMA ENCRIPTACION
IF NOT EXISTS (SELECT * FROM SYS.SCHEMAS WHERE name = 'encriptacion')
	EXEC('CREATE SCHEMA encriptacion')
GO

-- CREAR PROCEDURE PARA AÑADIR COLUMNAS
CREATE OR ALTER PROCEDURE encriptacion.addColEncrypt
AS
BEGIN
	BEGIN TRY
		ALTER TABLE recursosHumanos.Empleado ADD 
			nombreEncriptado VARBINARY(256),
			apellidoEncriptado VARBINARY(256),
			dniEncriptado VARBINARY(256),
			cuilEncriptado VARBINARY(256),
			emailPerEncriptado VARBINARY(256),
			emailEmpEncriptado VARBINARY(256),
			direccionEncriptado VARBINARY(256);
	END TRY
	BEGIN CATCH
		PRINT('ERROR ' + CAST(ERROR_NUMBER() AS VARCHAR) + ': NO SE PUDO CREAR LAS COLUMNAS')
		RETURN 0
	END CATCH
END
GO

-- PROCEDURE PARA ENCRIPTAR
CREATE OR ALTER PROCEDURE encriptacion.encriptarEmpleados (@password NVARCHAR(128))
AS
BEGIN
	IF(@password IS NULL)
	BEGIN
		PRINT('La contraseña digitada no es valida')
		RETURN 0
	END

	ELSE
	BEGIN
		BEGIN TRY
		
			UPDATE recursosHumanos.Empleado SET
				nombreEncriptado = ENCRYPTBYPASSPHRASE(@password,nombre),
				apellidoEncriptado = ENCRYPTBYPASSPHRASE(@password,apellido),
				dniEncriptado = ENCRYPTBYPASSPHRASE(@password,CAST(dni as varchar)),
				cuilEncriptado = ENCRYPTBYPASSPHRASE(@password,cuil),
				emailPerEncriptado = ENCRYPTBYPASSPHRASE(@password,emailPer),
				emailEmpEncriptado = ENCRYPTBYPASSPHRASE(@password,emailEmp),
				direccionEncriptado = ENCRYPTBYPASSPHRASE(@password,direccion);

			PRINT('Encriptacion llevada con exito')
			RETURN 1

		END TRY
		BEGIN CATCH
			PRINT('ERROR ' + CAST(ERROR_NUMBER() AS VARCHAR) + ': NO SE PUDO REALIZAR LA ENCRIPTACION')
			RETURN 0
		END CATCH
	END
END
GO

-- PROCEDURE PARA BORRAR DATOS NO ENCRIPTADOS
CREATE OR ALTER PROCEDURE encriptacion.borrarNoEncript
AS
BEGIN
	BEGIN TRY
		ALTER TABLE recursosHumanos.Empleado
		DROP COLUMN nombre,apellido,cuil,emailPer,emailEmp,direccion;
	END TRY
	BEGIN CATCH
		PRINT('ERROR ' + CAST(ERROR_NUMBER() AS VARCHAR) + ': NO SE PUDO REALIZAR EL BORRADO')
		RETURN 0
	END CATCH
END
GO

-- VER DATOS ENCRIPTADOS
CREATE OR ALTER PROCEDURE encriptacion.verDatEmpleados (@password NVARCHAR(128))
AS
BEGIN
	IF(@password IS NULL)
	BEGIN
		PRINT('La contraseña digitada no es valida')
		RETURN 0
	END

	ELSE
	BEGIN
		BEGIN TRY
			SELECT 
				legajo,
				CONVERT(VARCHAR(50),DECRYPTBYPASSPHRASE(@password,nombreEncriptado)) AS nombre,
				CONVERT(VARCHAR(50),DECRYPTBYPASSPHRASE(@password,apellidoEncriptado)) AS apellido,
				CONVERT(INT,DECRYPTBYPASSPHRASE(@password,dniEncriptado)) AS dni,
				CONVERT(CHAR(13),DECRYPTBYPASSPHRASE(@password,cuilEncriptado)) AS cuil,
				CONVERT(VARCHAR(60),DECRYPTBYPASSPHRASE(@password,emailPerEncriptado)) AS emailPer,
				CONVERT(VARCHAR(60),DECRYPTBYPASSPHRASE(@password,emailEmpEncriptado)) AS emailEmp,
				CONVERT(VARCHAR(100),DECRYPTBYPASSPHRASE(@password,direccionEncriptado)) AS direccion,
				idSucursal,
				idTurno,
				idCargo,
				activo
			FROM recursosHumanos.Empleado
		END TRY
		BEGIN CATCH
			PRINT('ERROR ' + CAST(ERROR_NUMBER() AS VARCHAR) + ': NO SE PUDO REALIZAR LA DESENCRIPTACION')
			RETURN 0
		END CATCH
	END
END
GO