/*GRUPO 13
BASE DE DATOS APLICADA

ORTEGA MARCO ANTONIO - 44108566

Se requiere que importe toda la información antes mencionada a la base de datos:
	• Genere los objetos necesarios (store procedures, funciones, etc.) para importar los
	archivos antes mencionados. Tenga en cuenta que cada mes se recibirán archivos de
	novedades con la misma estructura, pero datos nuevos para agregar a cada maestro.

	• Considere este comportamiento al generar el código. Debe admitir la importación de
	novedades periódicamente.

	• Cada maestro debe importarse con un SP distinto. No se aceptarán scripts que
	realicen tareas por fuera de un SP.

	• La estructura/esquema de las tablas a generar será decisión suya. Puede que deba
	realizar procesos de transformación sobre los maestros recibidos para adaptarlos a la
	estructura requerida.

	• Los archivos CSV/JSON no deben modificarse. En caso de que haya datos mal
	cargados, incompletos, erróneos, etc., deberá contemplarlo y realizar las correcciones
	en el fuente SQL. (Sería una excepción si el archivo está malformado y no es posible
	interpretarlo como JSON o CSV).
*/

USE G13COM5600
GO

--

IF NOT EXISTS (SELECT * FROM SYS.SCHEMAS WHERE name = 'importacion')
	EXEC('CREATE SCHEMA importacion')
GO

--

CREATE OR ALTER PROCEDURE importacion.ConfExcelImport
AS
BEGIN
	-- CONFIGURACION PARA CONSULTAS DISTRIBUIDAS (NECESARIO)
	sp_configure 'show advanced options', 1;
	RECONFIGURE;
	GO
	sp_configure 'Ad Hoc Distributed Queries', 1;
	RECONFIGURE;
	GO
	--
	-- CONFIGURACION PARA ARQUITECTURA OLEDB (CONF PARA ERROR)
	EXEC sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1;
	EXEC sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1;

END
GO

--CARGAR TABLA SUCUURSAL
CREATE OR ALTER PROCEDURE importacion.importarSucursal ( @path VARCHAR(300) ) 
AS
BEGIN
	CREATE TABLE #TempSucursal(
	ciudad VARCHAR(100),
	reemplazo VARCHAR(100),
	direccion VARCHAR(100),
	horario VARCHAR(100),
	telefono VARCHAR(100))

	DECLARE @query NVARCHAR(MAX)
	SET @query = 'INSERT INTO #TempSucursal SELECT * 
				 FROM OPENROWSET(''Microsoft.ACE.OLEDB.12.0'',''Excel 12.0; Database=' + @path + ''',[sucursal$])';

	BEGIN TRY
		EXEC sp_executesql @query
	END TRY
	BEGIN CATCH
		DROP TABLE #TempSucursal
		PRINT('ERROR ' + CAST(ERROR_NUMBER() AS VARCHAR) + ': NO SE PUDO REALIZAR LA CARGA')
		RETURN
	END CATCH

	-- CARGO TABLA QUE CONTIENE SUCURSALES
	INSERT INTO sucursales.Sucursal (ciudad,direccion,horario,telefono)
	SELECT reemplazo, direccion, horario, telefono FROM #TempSucursal B
	WHERE NOT EXISTS (SELECT 1 FROM sucursales.Sucursal A WHERE A.direccion = B.direccion)

	DROP TABLE #TempSucursal
END
GO

CREATE OR ALTER PROCEDURE importacion.importarEmpleado ( @path VARCHAR(300) ) 
AS
BEGIN
	CREATE TABLE #TempEmpleado(
	legajo VARCHAR(100),
	nombre VARCHAR(100),
	apellido VARCHAR(100),
	dni INT,
	direccion VARCHAR(100),
	emailPer VARCHAR(100),
	emailEmp VARCHAR(100),
	cuil VARCHAR(100),
	cargo VARCHAR(100),
	sucursal VARCHAR(100),
	turno VARCHAR(100))

	DECLARE @query NVARCHAR(MAX)
	SET @query = 'INSERT INTO #TempEmpleado SELECT * 
				 FROM OPENROWSET(''Microsoft.ACE.OLEDB.12.0'',''Excel 12.0; Database=' + @path + ''',[Empleados$])';

	BEGIN TRY
	 EXEC sp_executesql @query
	END TRY
	BEGIN CATCH
		DROP TABLE #TempEmpleado
		PRINT('ERROR ' + CAST(ERROR_NUMBER() AS VARCHAR) + ': NO SE PUDO REALIZAR LA CARGA')
		RETURN
	END CATCH

	--CASTEAMOS VALORES
	UPDATE #TempEmpleado SET
		legajo = CAST(legajo AS INT)

	--CARGO TABLA QUE CONTIENE CARGOS
	INSERT INTO recursosHumanos.CargoTrabajo (cargo)
	SELECT DISTINCT cargo FROM #TempEmpleado te
	WHERE cargo IS NOT NULL AND NOT EXISTS (SELECT 1 FROM recursosHumanos.CargoTrabajo c WHERE c.cargo = te.cargo)

	--CARGO TABLA QUE CONTIENE TURNOS
	INSERT INTO recursosHumanos.TurnoTrabajo(turno)
	SELECT DISTINCT turno FROM #TempEmpleado te
	WHERE turno IS NOT NULL AND NOT EXISTS (SELECT 1 FROM recursosHumanos.TurnoTrabajo t WHERE t.turno = te.turno)

	--CARGO TABLA QUE CONTIENE EMPLEADOS
	INSERT INTO recursosHumanos.Empleado (legajo,nombre,apellido,dni,cuil,emailPer,emailEmp,direccion,idSucursal,idTurno,idCargo)
	SELECT legajo,nombre,apellido,dni,cuil,emailPer,emailEmp,te.direccion,s.id,t.id,c.id
	FROM #TempEmpleado te
	INNER JOIN recursosHumanos.TurnoTrabajo t ON t.turno = te.turno
	INNER JOIN recursosHumanos.CargoTrabajo c ON c.cargo = te.cargo
	INNER JOIN sucursales.Sucursal s ON s.ciudad = te.sucursal  
	WHERE legajo IS NOT NULL AND NOT EXISTS (SELECT 1 FROM recursosHumanos.Empleado e WHERE e.legajo = te.legajo)
	
	DROP TABLE #TempEmpleado
END
GO

CREATE OR ALTER PROCEDURE importacion.importarMedioDePago ( @path VARCHAR(300) )
AS
BEGIN
	CREATE TABLE #TempMedios(
	vacio VARCHAR(100),
	nombreEsp VARCHAR(100),
	nombreIng VARCHAR(100))

	DECLARE @query NVARCHAR(MAX)
	SET @query = 'INSERT INTO #TempMedios SELECT * 
				 FROM OPENROWSET(''Microsoft.ACE.OLEDB.12.0'',''Excel 12.0; Database=' + @path + ''',[''medios de pago$''])';

	BEGIN TRY
	 EXEC sp_executesql @query
	END TRY
	BEGIN CATCH
		DROP TABLE #TempMedios
		PRINT('ERROR ' + CAST(ERROR_NUMBER() AS VARCHAR) + ': NO SE PUDO REALIZAR LA CARGA')
		RETURN
	END CATCH

	--CARGO LA TABLA QUE CONTIENE MEDIOS DE PAGO
	INSERT INTO ventas.MedioDePago (nombreEsp,nombreIng)
	SELECT nombreEsp,nombreing FROM #TempMedios t 
	WHERE NOT EXISTS (SELECT 1 FROM ventas.MedioDePago mp WHERE mp.nombreEsp = t.nombreEsp AND mp.nombreIng = mp.nombreEsp)

	DROP TABLE #TempMedios
END
GO

CREATE OR ALTER PROCEDURE importacion.importarClasificacion ( @path VARCHAR(300) )
AS
BEGIN
	CREATE TABLE #TempClasf(
	lineaProd VARCHAR(100),
	categoria VARCHAR(100))

	DECLARE @query NVARCHAR(MAX)
	SET @query = 'INSERT INTO #TempClasf SELECT * 
				 FROM OPENROWSET(''Microsoft.ACE.OLEDB.12.0'',
				 ''Excel 12.0; Database=' + @path + ''',[''Clasificacion productos$''])';

	BEGIN TRY
	 EXEC sp_executesql @query
	END TRY
	BEGIN CATCH
		DROP TABLE #TempClasf
		PRINT('ERROR ' + CAST(ERROR_NUMBER() AS VARCHAR) + ': NO SE PUDO REALIZAR LA CARGA')
		RETURN
	END CATCH

	--CARGO LA TABLA QUE CONTIENE LINEAS DE PRODUCTO
	INSERT INTO catalogos.LineaCategoria (linea)
	SELECT DISTINCT lineaProd FROM #TempClasf t
	WHERE NOT EXISTS (SELECT 1 FROM catalogos.LineaCategoria lc WHERE lc.linea = t.lineaProd)

	--CARGO LA TABLA QUE CONTIENE LAS CATEGORIAS
	INSERT INTO catalogos.CategoriaProducto (categoria, idLineaCategoria)
	SELECT categoria,lc.id FROM #TempClasf t
	INNER JOIN catalogos.LineaCategoria lc ON lc.linea = t.lineaProd
	WHERE NOT EXISTS (SELECT 1 FROM catalogos.CategoriaProducto c WHERE c.categoria = t.categoria)

	DROP TABLE #TempClasf
END
GO

CREATE OR ALTER PROCEDURE importacion.importarCatalogo ( @path VARCHAR(300) )
AS
BEGIN
	CREATE TABLE #TempCatalogo(
	id VARCHAR(100),
	categoria VARCHAR(100),
	nombre VARCHAR(100),
	precio VARCHAR(100),
	precioRef VARCHAR(100),
	unidadRef VARCHAR(100),
	fecha smalldatetime)

	DECLARE @query NVARCHAR(MAX)
	SET @query = 'BULK INSERT #TempCatalogo
				 FROM''' + @path + '''
				 WITH(
					 FIELDTERMINATOR = '','',
					 ROWTERMINATOR = ''\n'',
					 CODEPAGE = ''ACP'',
					 FIRSTROW = 2,
					 FORMAT = ''CSV'',
					 MAXERRORS = 1)';

	BEGIN TRY
		EXEC sp_executesql @query
	END TRY
	BEGIN CATCH
		DROP TABLE #TempCatalogo
		PRINT('ERROR ' + CAST(ERROR_NUMBER() AS VARCHAR) + ': NO SE PUDO REALIZAR LA CARGA')
		RETURN
	END CATCH

	SELECT * FROM #TempCatalogo

	DROP TABLE #TempCatalogo
END
GO

EXEC importacion.ConfExcelImport
EXEC importacion.importarSucursal 'E:\PROYECTODDBB\TP_integrador_Archivos\Informacion_complementaria.xlsx'
EXEC importacion.importarEmpleado 'E:\PROYECTODDBB\TP_integrador_Archivos\Informacion_complementaria.xlsx'
EXEC importacion.importarMedioDePago'E:\PROYECTODDBB\TP_integrador_Archivos\Informacion_complementaria.xlsx'

EXEC importacion.importarClasificacion 'E:\PROYECTODDBB\TP_integrador_Archivos\Informacion_complementaria.xlsx'

EXEC importacion.importarCatalogo'E:\PROYECTODDBB\TP_integrador_Archivos\Productos\catalogo.csv'


SELECT * FROM sucursales.Sucursal

SELECT * FROM recursosHumanos.TurnoTrabajo
SELECT * FROM recursosHumanos.CargoTrabajo
SELECT * FROM recursosHumanos.Empleado

SELECT * FROM ventas.MedioDePago

SELECT * FROM catalogos.LineaCategoria
SELECT * FROM catalogos.CategoriaProducto


/*

DROP TABLE catalogos.CategoriaProducto
DROP TABLE catalogos.LineaCategoria
DROP TABLE catalogos.Producto
DROP TABLE clientes.Cliente
DROP TABLE clientes.TipoCiente
DROP TABLE recursosHumanos.CargoTrabajo
DROP TABLE recursosHumanos.Empleado
DROP TABLE recursosHumanos.TurnoTrabajo
DROP TABLE sucursales.Sucursal
DROP TABLE Ventas.Comprobante
DROP TABLE Ventas.Factura
DROP TABLE Ventas.ListaProducto
DROP TABLE Ventas.MedioDePago
DROP TABLE Ventas.TipoComprobante
DROP TABLE Ventas.TipoFactura

*/

USE master
GO

