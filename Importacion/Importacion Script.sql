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
	EXEC('sp_configure ''show advanced options'', 1')
	RECONFIGURE
	
	EXEC('sp_configure ''Ad Hoc Distributed Queries'', 1')
	RECONFIGURE
	
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

	--EN CASO DE QUE CUIL SEA NULL SE HACE EL CAMBIO POR UN CUIL GENERICO
	UPDATE #TempEmpleado SET
		cuil = '20-22222222-3' WHERE cuil IS NULL; --nuevo

	--CARGO TABLA QUE CONTIENE EMPLEADOS
	INSERT INTO recursosHumanos.Empleado (nombre,apellido,dni,cuil,emailPer,emailEmp,direccion,idSucursal,idTurno,idCargo)
	SELECT nombre,apellido,dni,cuil,emailPer,emailEmp,te.direccion,s.id,t.id,c.id
	FROM #TempEmpleado te
	INNER JOIN recursosHumanos.TurnoTrabajo t ON t.turno = te.turno
	INNER JOIN recursosHumanos.CargoTrabajo c ON c.cargo = te.cargo
	INNER JOIN sucursales.Sucursal s ON s.ciudad = te.sucursal  
	WHERE legajo IS NOT NULL AND NOT EXISTS (SELECT 1 FROM recursosHumanos.Empleado e WHERE e.legajo = te.legajo)
	
	DROP TABLE #TempEmpleado
END
GO

CREATE OR ALTER PROCEDURE importacion.importarMedioDePago ( @path VARCHAR(300) ) --VARIOS CAMBIOS
AS
BEGIN
	CREATE TABLE #TempMedios(
	vacio VARCHAR(100),
	nombreIng VARCHAR(100),
	nombreEsp VARCHAR(100))

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
	WHERE NOT EXISTS (SELECT 1 FROM ventas.MedioDePago mp WHERE mp.nombreEsp = t.nombreEsp AND mp.nombreIng = mp.nombreIng)

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
	VOID VARCHAR(100),
	categoria VARCHAR(100),
	nombre VARCHAR(100),
	precioUSD VARCHAR(100),
	precioRef VARCHAR(100),
	unidadRef VARCHAR(100),
	fecha VARCHAR(100))

	DECLARE @query NVARCHAR(MAX)
	SET @query = 'BULK INSERT #TempCatalogo
				 FROM ''' + @path + '''
				 WITH(
					 FIELDTERMINATOR = '','',
					 ROWTERMINATOR = ''0x0a'',
					 CODEPAGE = ''65001'',
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

	UPDATE #TempCatalogo SET
		precioUSD = CAST(precioUSD AS DECIMAL(9,2)),
		precioRef = CAST(precioRef AS DECIMAL(9,2)),
		fecha = CONVERT(SMALLDATETIME,fecha);

	--ARREGLO CARACTERES DAÑADOS SI LOS HUBIERA
	UPDATE #TempCatalogo SET
		nombre = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(nombre, 'Ã±', 'ñ')
		, 'Ã³', 'ó'), 'Ã©', 'é'), 'Ã¡', 'á'), 'Ãº', 'ú'), 'Ã­', 'í'), 'ÃƒÂº', 'ú'), 'Ã‘', 'Ñ'), '?', 'ñ'), 'Ã‘', 'Ñ'), 'Âº' , 'º'), 'å˜', 'ñ'),'Ã','Á');

	--SE ELIMINAN COPIAS QUE CONTENGA LA TABLA TEMPORAL
	WITH Duplicados AS ( SELECT ROW_NUMBER() OVER(PARTITION BY nombre,precioUSD ORDER BY nombre,precioUSD ASC) AS COPIA,nombre,precioUSD FROM #TempCatalogo)
	DELETE FROM Duplicados WHERE COPIA > 1

	--CARGO LA TABLA QUE CONTIENE PRODUCTOS
	INSERT INTO catalogos.Producto (nombre,precioUSD,precioRef,unidadRef,fecha,idCategoria)
	SELECT nombre,precioUSD,precioRef,unidadRef,fecha,c.id FROM #TempCatalogo t
	INNER JOIN catalogos.CategoriaProducto c ON c.categoria = t.categoria
	WHERE nombre IS NOT NULL AND NOT EXISTS (SELECT 1 FROM catalogos.Producto p WHERE p.nombre = t.nombre AND p.precioUSD = t.precioUSD);

	DROP TABLE #TempCatalogo
END
GO

CREATE OR ALTER PROCEDURE importacion.importarAccesoriosElectronicos ( @path VARCHAR(300) )
AS
BEGIN
	CREATE TABLE #TempAccElect(
	nombre VARCHAR(100),
	precioUSD VARCHAR(100))

	DECLARE @query NVARCHAR(MAX)
	SET @query = 'INSERT INTO #TempAccElect SELECT * 
				 FROM OPENROWSET(''Microsoft.ACE.OLEDB.12.0'',''Excel 12.0; Database=' + @path + ''',[Sheet1$])';

	BEGIN TRY
	 EXEC sp_executesql @query
	END TRY
	BEGIN CATCH
		DROP TABLE #TempAccElect
		PRINT('ERROR ' + CAST(ERROR_NUMBER() AS VARCHAR) + ': NO SE PUDO REALIZAR LA CARGA')
		RETURN
	END CATCH
	
	UPDATE #TempAccElect SET
		precioUSD = CAST(precioUSD AS DECIMAL(9,2));

	--ARREGLO CARACTERES DAÑADOS SI LOS HUBIERA
	UPDATE #TempAccElect SET
		nombre = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(nombre, 'Ã±', 'ñ')
		, 'Ã³', 'ó'), 'Ã©', 'é'), 'Ã¡', 'á'), 'Ãº', 'ú'), 'Ã­', 'í'), 'ÃƒÂº', 'ú'), 'Ã‘', 'Ñ'), '?', 'ñ'), 'Ã‘', 'Ñ'), 'Âº' , 'º'), 'å˜', 'ñ'),'Ã','Á');

	--SE ELIMINAN DUPLICADOS QUE CONTENGA LA TABLA TEMPORAL
	WITH Duplicados AS ( SELECT ROW_NUMBER() OVER(PARTITION BY nombre,precioUSD ORDER BY nombre,precioUSD ASC) AS COPIA,nombre,precioUSD FROM #TempAccElect)
	DELETE FROM Duplicados WHERE COPIA > 1

	--SE AÑADEN LA LINEA DE PRODUCTO TECNOLOGIA Y LA CATEGORIA ELECTRONICA
	IF NOT EXISTS (SELECT 1 FROM catalogos.CategoriaProducto WHERE categoria = 'electronica')
	BEGIN
		INSERT INTO catalogos.LineaCategoria VALUES ('Tecnologia')
		INSERT INTO catalogos.CategoriaProducto (categoria,idLineaCategoria) SELECT 'electronica',id FROM catalogos.LineaCategoria WHERE linea = 'Tecnologia'
	END

	--DECLARO UNA VARIABLE QUE CONTENGA EL ID DE CATEGORIA ELECTRONICA
	DECLARE @idCat INT;
	SELECT @idCat = id FROM catalogos.CategoriaProducto WHERE categoria = 'electronica'

	--CARGO LA TABLA QUE CONTIENE PRODUCTOS
	INSERT INTO catalogos.Producto (nombre,precioUSD,idCategoria)
	SELECT nombre,precioUSD,@idCat FROM #TempAccElect t
	WHERE nombre IS NOT NULL AND NOT EXISTS (SELECT 1 FROM catalogos.Producto p WHERE p.nombre = t.nombre AND p.precioUSD = t.precioUSD)

	DROP TABLE #TempAccElect
END
GO

CREATE OR ALTER PROCEDURE importacion.importarProductosImportados ( @path VARCHAR(300) )
AS
BEGIN
	CREATE TABLE #TempProdImport(
		VOID VARCHAR(100),
		nombre VARCHAR(100),
		proveedor VARCHAR(100),
		categoria VARCHAR(100),
		cantidadXun VARCHAR(100),
		precioUSD VARCHAR(100))

	DECLARE @query NVARCHAR(MAX)
	SET @query = 'INSERT INTO #TempProdImport SELECT * 
				 FROM OPENROWSET(''Microsoft.ACE.OLEDB.12.0'',''Excel 12.0; Database=' + @path + ''',[''Listado de Productos$''])';

	BEGIN TRY
		EXEC sp_executesql @query
	END TRY
	BEGIN CATCH
		DROP TABLE #TempProdImport
		PRINT('ERROR ' + CAST(ERROR_NUMBER() AS VARCHAR) + ': NO SE PUDO REALIZAR LA CARGA')
		RETURN
	END CATCH

	--CAMBIO LOS TIPO DE DATO
	UPDATE #TempProdImport SET
		precioUSD = CAST(precioUSD AS DECIMAL(9,2));

	--ARREGLO CARACTERES DAÑADOS SI LOS HUBIERA
	UPDATE #TempProdImport SET
		nombre = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(nombre, 'Ã±', 'ñ')
		, 'Ã³', 'ó'), 'Ã©', 'é'), 'Ã¡', 'á'), 'Ãº', 'ú'), 'Ã­', 'í'), 'ÃƒÂº', 'ú'), 'Ã‘', 'Ñ'), '?', 'ñ'), 'Ã‘', 'Ñ'), 'Âº' , 'º'), 'å˜', 'ñ'),'Ã','Á');

	--SE ELIMINAN DUPLICADOS QUE CONTENGA LA TABLA TEMPORAL
	WITH Duplicados AS ( SELECT ROW_NUMBER() OVER(PARTITION BY nombre,precioUSD ORDER BY nombre,precioUSD ASC) AS COPIA,nombre,precioUSD FROM #TempProdImport)
	DELETE FROM Duplicados WHERE COPIA > 1

	--CARGO LA TABLA QUE CONTIENE CATEGORIAS
	INSERT INTO catalogos.CategoriaProducto (categoria)
	SELECT DISTINCT categoria FROM #TempProdImport t WHERE NOT EXISTS (SELECT 1 FROM catalogos.CategoriaProducto c WHERE c.categoria = t.categoria)

	--CARGO LA TABLA QUE CONTIENE PRODUCTOS
	INSERT INTO catalogos.Producto (nombre,proveedor,cantXUn,precioUSD,idCategoria)
	SELECT nombre,proveedor,cantidadXun,precioUSD,c.id FROM #TempProdImport t
	INNER JOIN  catalogos.CategoriaProducto c ON c.categoria = t.categoria
	WHERE nombre IS NOT NULL AND NOT EXISTS (SELECT 1 FROM catalogos.Producto p WHERE p.nombre = t.nombre AND p.precioUSD = t.precioUSD)

	DROP TABLE #TempProdImport
END
GO

CREATE OR ALTER PROCEDURE importacion.importarVentasRegistradas ( @path VARCHAR(300) )
AS
BEGIN
	CREATE TABLE #TempVentas(
		idFactura VARCHAR(100),
		tipoFactura VARCHAR(100),
		ciudad VARCHAR(100),
		tipoCliente VARCHAR(100),
		generoCliente VARCHAR(100),
		producto NVARCHAR(100),
		precioUn VARCHAR(100),
		cantidad VARCHAR(100),
		fecha VARCHAR(100),
		hora VARCHAR(100),
		medioDePago VARCHAR(100),
		empleadoLeg VARCHAR(100),
		identPago VARCHAR(100))

	DECLARE @query NVARCHAR(MAX)
	SET @query = 'BULK INSERT #TempVentas
				 FROM ''' + @path + '''
				 WITH(
					 FIELDTERMINATOR = '';'',
					 ROWTERMINATOR = ''0x0a'',
					 CODEPAGE = ''65001'',
					 FIRSTROW = 2,
					 FORMAT = ''CSV'',
					 MAXERRORS = 1)';

	BEGIN TRY
		EXEC sp_executesql @query
	END TRY
	BEGIN CATCH
		DROP TABLE #TempVentas
		PRINT('ERROR ' + CAST(ERROR_NUMBER() AS VARCHAR) + ': NO SE PUDO REALIZAR LA CARGA')
		RETURN
	END CATCH

	UPDATE #TempVentas SET
		idFactura = CAST(idFactura AS CHAR(11)),
		tipoFactura = CAST(tipoFactura AS CHAR(1)),
		generoCliente = CAST(generoCliente AS CHAR(10)),
		precioUn = CAST(precioUn AS DECIMAL(9,2)),
		cantidad = CAST(cantidad AS INT),
		fecha = CAST(fecha AS DATE),
		hora = CONVERT(TIME,hora,108),
		empleadoLeg = CAST(empleadoLeg AS INT);

	--ARREGLO CARACTERES DAÑADOS SI LOS HUBIERA
	UPDATE #TempVentas SET
		producto = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(producto, 'Ã±', 'ñ')
		, 'Ã³', 'ó'), 'Ã©', 'é'), 'Ã¡', 'á'), 'Ãº', 'ú'), 'Ã­', 'í'), 'ÃƒÂº', 'ú'), 'Ã‘', 'Ñ'), '?', 'ñ'), 'Ã‘', 'Ñ'), 'Âº' , 'º'), 'å˜', 'ñ'),'Ã','Á');

	--CARGAMOS LA TABLA QUE CONTIENE LOS TIPO DE CLIENTE
	INSERT INTO clientes.TipoCliente (tipo)
	SELECT DISTINCT tipoCliente FROM #TempVentas t
	WHERE NOT EXISTS (SELECT 1 FROM clientes.TipoCliente tc WHERE tc.tipo = t.tipoCliente)

	--CARGAMOS LA TABLA QUE CONTIENE LOS TIPO DE FACTURA
	INSERT INTO ventas.TipoFactura (tipo)
	SELECT DISTINCT tipoFactura FROM #TempVentas t
	WHERE NOT EXISTS (SELECT 1 FROM ventas.TipoFactura tf WHERE tf.tipo = t.tipoFactura)

	--CARGAMOS LA TABLA QUE CONTIENE LAS FACTURAS
	INSERT INTO ventas.Factura (idFactura,idTipoFactura,ciudad,idTipoCliente,generoCliente,fecha,hora,legajoEmp,estado)
	SELECT idFactura,tf.id,ciudad,tc.id,generoCliente,fecha,hora,empleadoLeg,'Pagada' FROM #TempVentas t
	INNER JOIN ventas.TipoFactura tf ON tf.tipo = t.tipoFactura
	INNER JOIN clientes.TipoCliente tc ON tc.tipo = t.tipoCliente
	WHERE t.idFactura IS NOT NULL AND t.empleadoLeg IS NOT NULL AND NOT EXISTS (SELECT 1 FROM ventas.Factura vf WHERE vf.idFactura = t.idFactura)
	
	--CARGAMOS LA TABLA QUE CONTIENE LA RELACION N:N ENTRE PRODUCTO Y FACTURA (LISTA DE PRODUCTOS)

	;WITH Precios AS (
		SELECT id,nombre,precioARS,precioUSD FROM #TempVentas t
		INNER JOIN catalogos.Producto p ON p.nombre = t.producto COLLATE SQL_Latin1_General_CP1_CI_AI)
	UPDATE Precios SET precioARS = apis.dolarHoy(1) * precioUSD;

	INSERT INTO ventas.ListaProducto (idFactura,idProducto,cantidad,subtotal)
	SELECT idFactura,p.id,cantidad,precioARS*cantidad FROM #TempVentas t
	INNER JOIN catalogos.Producto p ON p.nombre = t.producto AND p.precioUSD = t.precioUn
	WHERE t.idFactura IS NOT NULL AND t.cantidad IS NOT NULL
	AND NOT EXISTS (SELECT 1 FROM ventas.ListaProducto lp WHERE lp.idFactura = t.idFactura AND lp.idProducto = p.id AND lp.cantidad = t.cantidad)

	--CARGAMOS LA TABLA QUE CONTIENE COMPROBANTES
	 INSERT INTO ventas.Comprobante (idFactura,fecha,hora)
	 SELECT idFactura,fecha,hora FROM #TempVentas t
	 WHERE idFactura IS NOT NULL AND NOT EXISTS (SELECT 1 FROM ventas.Comprobante c WHERE c.idFactura = t.idFactura)

	--CARGAMOS LA INFORMACION DE COMPROBANTES FACTURA
	;WITH Montos AS (
		SELECT idFactura,SUM(subtotal) AS total FROM ventas.ListaProducto GROUP BY idFactura
	)

	INSERT INTO ventas.ComprobanteFactura(id,monto,identificadorPago,idMedioPago)
	SELECT c.id,total,identPago,mp.id FROM ventas.Comprobante c
	INNER JOIN Montos m ON m.idFactura = c.idFactura
	INNER JOIN #TempVentas t ON t.idFactura = c.idFactura
	INNER JOIN ventas.MedioDePago mp ON mp.nombreING = t.medioDePago COLLATE SQL_Latin1_General_CP1_CI_AI OR mp.nombreESP = t.medioDePago COLLATE SQL_Latin1_General_CP1_CI_AI
	WHERE c.idFactura IS NOT NULL AND NOT EXISTS (SELECT 1 FROM ventas.ComprobanteFactura cf WHERE cf.id = c.id)

	DROP TABLE #TempVentas
END
GO


--SELECT * FROM ventas.ListaProducto WHERE idFactura = '133-14-7229'

/*
EXEC importacion.ConfExcelImport

EXEC importacion.importarSucursal 'E:\PROYECTODDBB\TP_integrador_Archivos\Informacion_complementaria.xlsx'

EXEC importacion.importarEmpleado 'E:\PROYECTODDBB\TP_integrador_Archivos\Informacion_complementaria.xlsx'

EXEC importacion.importarMedioDePago'E:\PROYECTODDBB\TP_integrador_Archivos\Informacion_complementaria.xlsx'

EXEC importacion.importarClasificacion 'E:\PROYECTODDBB\TP_integrador_Archivos\Informacion_complementaria.xlsx'

EXEC importacion.importarCatalogo 'E:\PROYECTODDBB\TP_integrador_Archivos\Productos\catalogo.csv'
EXEC importacion.importarAccesoriosElectronicos 'E:\PROYECTODDBB\TP_integrador_Archivos\Productos\Electronic accessories.xlsx'
EXEC importacion.importarProductosImportados 'E:\PROYECTODDBB\TP_integrador_Archivos\Productos\Productos_importados.xlsx'

EXEC importacion.importarVentasRegistradas 'E:\PROYECTODDBB\TP_integrador_Archivos\Ventas_registradas.csv'


SELECT * FROM sucursales.Sucursal

SELECT * FROM recursosHumanos.TurnoTrabajo
SELECT * FROM recursosHumanos.CargoTrabajo
SELECT * FROM recursosHumanos.Empleado

SELECT * FROM ventas.MedioDePago

SELECT * FROM catalogos.LineaCategoria
SELECT * FROM catalogos.CategoriaProducto
SELECT * FROM catalogos.Producto order by precioUSD



SELECT * FROM clientes.TipoCliente
SELECT * FROM ventas.TipoFactura
SELECT * FROM ventas.Factura

SELECT * FROM ventas.TipoComprobante

SELECT * FROM ventas.Comprobante
SELECT * FROM ventas.MedioDePago
SELECT * FROM ventas.ListaProducto where idFactura = '187-83-5490'

SELECT * FROM ventas.ComprobanteFactura
SELECT c.id,idFactura,fecha,hora,monto,identificadorPago,idMedioPago FROM ventas.Comprobante c INNER JOIN ventas.ComprobanteFactura cf ON c.id = cf.id

*/

