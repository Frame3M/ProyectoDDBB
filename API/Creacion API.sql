
USE G13COM5600
GO

-- CREACION DE ESQUEMAS PARA LO RELACIONADO A APIS

IF NOT EXISTS (SELECT * FROM SYS.SCHEMAS WHERE name = 'apis')
	EXEC('CREATE SCHEMA apis');
GO

-- PARTE DE LA CONFIGURACION
CREATE OR ALTER PROCEDURE apis.configuracion
AS
BEGIN
	EXEC('sp_configure ''show advanced options'', 1')
	RECONFIGURE
	
	EXEC('sp_configure ''Ole Automation Procedures'', 1')
	RECONFIGURE
END
GO

-- CREACION DE FUNCION PARA OBTENER EL DOLAR (COTIZACION EN BLUE 1140 A LA FECHA)
-- FUENTE: dolarapi.com
CREATE OR ALTER FUNCTION apis.dolarHoy(@retorno DECIMAL(9,2) = 1)
RETURNS DECIMAL(9,2)
AS
BEGIN
	
	DECLARE @url NVARCHAR(MAX) = 'https://dolarapi.com/v1/dolares/blue';
	DECLARE @object INT;
	DECLARE @response NVARCHAR(3333);

	EXEC sp_OACreate 'MSXML2.XMLHTTP',@object OUT;
	EXEC sp_OAMethod @object,'OPEN',NULL,'GET',@url,'FALSE'
	EXEC sp_OAMethod @object,'SEND'
	EXEC sp_OAMethod @object,'RESPONSETEXT',@response OUTPUT

	SET @retorno = (SELECT venta FROM OPENJSON(@response)
	WITH(
		--moneda VARCHAR(50) '$.moneda',
		--casa VARCHAR(50) '$.casa',
		--nombre VARCHAR(50) '$.casa',
		--compra DECIMAL(9,2) '$.compra',
		venta DECIMAL(9,2) '$.venta'
		--fecha SMALLDATETIME '$.fechaActualizacion'
	));
	EXEC sp_OADestroy @object

	RETURN @retorno
END
GO
/*
EXEC apis.configuracion
SELECT apis.dolarHoy(1)
*/
/*
use master
*/

