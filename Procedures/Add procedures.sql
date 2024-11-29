USE G13COM5600
GO

/*	CREACION DE PROCEDURES PARA AGREGADO	*/

-- PROCEDIMIENTO PARA AÑADIR SUCURSALES ------------------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE sucursales.AddSucursal ( @ciudad VARCHAR(20) , @horario VARCHAR(50) , @direccion VARCHAR(100) , @telefono CHAR(9) )
AS
BEGIN
	IF(@ciudad IS NULL OR @direccion IS NULL)
	BEGIN
		PRINT('Ingrese datos validos')
		RETURN 0
	END

	IF(EXISTS(SELECT 1 FROM sucursales.Sucursal WHERE direccion=@direccion))
	BEGIN
		PRINT('Ya existe una sucursal en esa direccion')
		RETURN 0
	END

	IF(EXISTS(SELECT 1 FROM sucursales.Sucursal WHERE telefono=@telefono))
	BEGIN
		PRINT('Ya existe una sucursal con ese telefono')
		RETURN 0
	END

	ELSE
	BEGIN
		BEGIN TRY
			INSERT INTO sucursales.Sucursal (ciudad,horario,direccion,telefono) VALUES (@ciudad,@horario,@direccion,@telefono)
			PRINT('Se ha añadido la sucursal correctamente')
			RETURN 1
		END TRY
		BEGIN CATCH
			PRINT('ERROR ' + CAST(ERROR_NUMBER() AS VARCHAR) + ': NO SE PUDO AÑADIR LOS DATOS')
			RETURN 0			
		END CATCH
	END
END
GO
---------------------------------------------------------------------------------------------------------------------------------------

-- PROCEDIMIENTO PARA AÑADIR EMPLEADO -------------------------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE recursosHumanos.AddEmpleado(
	@nombre VARCHAR(20),
	@apellido VARCHAR(20),
	@dni INT,
	@cuil CHAR(13),
	@emailPer VARCHAR(60),
	@emailEmp VARCHAR(60),
	@direccion VARCHAR(100),
	@sucursal VARCHAR(20),
	@turno VARCHAR(30),
	@cargo VARCHAR(30))
AS
BEGIN
	IF(@nombre IS NULL OR @apellido IS NULL OR @dni IS NULL OR @sucursal IS NULL OR @turno IS NULL OR @cargo IS NULL)
	BEGIN
		PRINT('Ingrese valores validos')
		RETURN 0
	END

	IF(EXISTS(SELECT 1 FROM recursosHumanos.Empleado WHERE dni=@dni))
	BEGIN
		PRINT('Ya existe un empleado con el DNI ingresado')
		RETURN 0
	END

	IF(EXISTS(SELECT 1 FROM recursosHumanos.Empleado WHERE cuil=@cuil))
	BEGIN
		PRINT('Ya existe un empleado con el CUIL ingresado')
	END

	IF(NOT EXISTS(SELECT 1 FROM sucursales.Sucursal WHERE ciudad=@sucursal))
	BEGIN
		PRINT('Sucursal no registrada en la base de datos')
		RETURN 0
	END

	IF(NOT EXISTS(SELECT 1 FROM recursosHumanos.TurnoTrabajo WHERE turno=@turno))
	BEGIN
		PRINT('Turno de trabajo no registrado en la base de datos')
		RETURN 0
	END

	IF(NOT EXISTS(SELECT 1 FROM recursosHumanos.CargoTrabajo WHERE cargo=@cargo))
	BEGIN
		PRINT('Cargo de trabajo no registrado en la base de datos')
		RETURN 0
	END

	ELSE
	BEGIN
		BEGIN TRY
			DECLARE @idSucursal INT = (SELECT id FROM sucursales.Sucursal WHERE ciudad=@sucursal)
			DECLARE @idTurno INT = (SELECT id FROM recursosHumanos.TurnoTrabajo WHERE turno=@turno)
			DECLARE @idCargo INT = (SELECT id FROM recursosHumanos.CargoTrabajo WHERE cargo=@cargo)

			INSERT INTO recursosHumanos.Empleado (nombre,apellido,dni,cuil,emailPer,emailEmp,direccion,idSucursal,idTurno,idCargo) 
			VALUES (@nombre,@apellido,@dni,@cuil,@emailPer,@emailEmp,@direccion,@idSucursal,@idTurno,@idCargo) 
			PRINT('Empleado añadido con exito')
			RETURN 1
		END TRY
		BEGIN CATCH
			PRINT('ERROR ' + CAST(ERROR_NUMBER() AS VARCHAR) + ': NO SE PUDO AÑADIR LOS DATOS')
			RETURN 0
		END CATCH
	END
END
GO

-- PROCEDIMIENTO PARA AÑADIR TURNO TRABAJO
CREATE OR ALTER PROCEDURE recursosHumanos.AddTurnoT (@turno VARCHAR(20))
AS
BEGIN
	IF(@turno IS NULL)
	BEGIN
		PRINT('Ingrese valores validos')
		RETURN 0
	END

	IF(EXISTS(SELECT 1 FROM recursosHumanos.TurnoTrabajo WHERE turno=@turno COLLATE SQL_Latin1_General_CP1_CI_AI))
	BEGIN
		PRINT('Ya existe el turno de trabajo ingresado')
		RETURN 0
	END

	ELSE
	BEGIN
		BEGIN TRY
			INSERT INTO recursosHumanos.TurnoTrabajo (turno) VALUES (@turno)
			PRINT('Turno de trabajo añadido con exito')
			RETURN 1
		END TRY
		BEGIN CATCH
			PRINT('ERROR ' + CAST(ERROR_NUMBER() AS VARCHAR) + ': NO SE PUDO AÑADIR LOS DATOS')
			RETURN 0
		END CATCH
	END
END
GO

-- PROCEDIMIENTO PARA AÑADIR CARGO DE TRABAJO
CREATE OR ALTER PROCEDURE recursosHumanos.AddCargoT (@cargo VARCHAR(30))
AS
BEGIN
	IF(@cargo IS NULL)
	BEGIN
		PRINT('Ingrese datos validos')
		RETURN 0
	END

	IF(EXISTS(SELECT 1 FROM recursosHumanos.CargoTrabajo WHERE cargo = @cargo COLLATE SQL_Latin1_General_CP1_CI_AI))
	BEGIN
		PRINT('Ya existe el cargo de trabajo ingresado')
		RETURN 0
	END

	ELSE
	BEGIN
		BEGIN TRY
			INSERT INTO recursosHumanos.CargoTrabajo (cargo) VALUES (@cargo)
			PRINT('Cargo de trabajo añadido con exito')
			RETURN 1
		END TRY
		BEGIN CATCH
			PRINT('ERROR ' + CAST(ERROR_NUMBER() AS VARCHAR) + ': NO SE PUDO AÑADIR LOS DATOS')
			RETURN 0
		END CATCH
	END
END
GO
---------------------------------------------------------------------------------------------------------------------------------------

-- PROCEDIMIENTO PARA AÑADIR FACTURA --------------------------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE ventas.AddFactura (
	@idFactura CHAR(11),
	@tipoF CHAR(1),
	@ciudad VARCHAR(60),
	@tipoC VARCHAR(20),
	@generoC VARCHAR(10),
	@legajoE INT
	)
AS
BEGIN
	IF(@idFactura IS NULL OR @tipoF IS NULL OR @ciudad IS NULL OR @legajoE IS NULL)
	BEGIN
		PRINT('Ingrese datos validos')
		RETURN 0
	END

	IF(@idFactura NOT LIKE '[0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9]')
	BEGIN
		PRINT('El ID no cumple con el formato correcto')
		RETURN 0
	END

	IF(EXISTS(SELECT 1 FROM ventas.Factura WHERE idFactura = @idFactura))
	BEGIN
		PRINT('El ID ya pertenece a otra factura')
		RETURN 0
	END

	IF(NOT EXISTS(SELECT 1 FROM ventas.TipoFactura WHERE tipo=@tipoF))
	BEGIN
		PRINT('Tipo de factura no valido')
		RETURN 0
	END

	IF(NOT EXISTS(SELECT 1 FROM recursosHumanos.Empleado WHERE legajo=@legajoE))
	BEGIN
		PRINT('Legajo de empleado no valido')
	END

	ELSE
	BEGIN
		BEGIN TRY
			DECLARE @idTipoF INT = (SELECT id FROM ventas.TipoFactura WHERE tipo=@tipoF)
			DECLARE @idTipoC INT = (SELECT id FROM clientes.TipoCliente WHERE tipo=@tipoC)

			INSERT INTO ventas.Factura (idFactura,idTipoFactura,ciudad,idTipoCliente,generoCliente,legajoEmp,fecha,hora)
			VALUES (@idFactura,@idTipoF,@ciudad,@idTipoC,@generoC,@legajoE,CONVERT(date,GETDATE()),CONVERT(time,GETDATE()))
			PRINT('Factura añadida con exito')
			RETURN 1
		END TRY
		BEGIN CATCH
			PRINT('ERROR ' + CAST(ERROR_NUMBER() AS VARCHAR) + ': NO SE PUDO AÑADIR LOS DATOS')
			RETURN 0
		END CATCH
	END
END
GO

-- AÑADIR TIPO DE CLIENTE
CREATE OR ALTER PROCEDURE clientes.AddTipoCliente(@tipo VARCHAR(20))
AS
BEGIN
	IF(@tipo IS NULL)
	BEGIN
		PRINT('Ingrese datos validos')
		RETURN 0
	END

	IF(EXISTS(SELECT 1 FROM clientes.TipoCliente WHERE tipo=@tipo ))
	BEGIN
		PRINT('Tipo de cliente ya incluido en la base de datos')
		RETURN 0
	END

	ELSE
	BEGIN
		BEGIN TRY
			INSERT INTO clientes.TipoCliente (tipo) VALUES (@tipo)
			PRINT('Tipo de cliente añadido con exito')
			RETURN 1
		END TRY
		BEGIN CATCH
			PRINT('ERROR ' + CAST(ERROR_NUMBER() AS VARCHAR) + ': NO SE PUDO AÑADIR LOS DATOS')
			RETURN 0
		END CATCH
	END
END
GO

-- AÑADIR TIPO DE FACTURA
CREATE OR ALTER PROCEDURE ventas.AddTipoFactura (@tipo VARCHAR(10))
AS
BEGIN
	IF(@tipo IS NULL)
	BEGIN
		PRINT('Ingrese valores validos')
		RETURN 0
	END

	IF(EXISTS(SELECT 1 FROM ventas.TipoFactura WHERE tipo=@tipo))
	BEGIN
		PRINT('Tipo de factura ya incluido en la base de datos')
		RETURN 0
	END

	ELSE
	BEGIN
		BEGIN TRY
			INSERT INTO ventas.TipoFactura(tipo) VALUES (@tipo)
			PRINT('Tipo de factura añadido con exito')
			RETURN 1
		END TRY
		BEGIN CATCH
			PRINT('ERROR ' + CAST(ERROR_NUMBER() AS VARCHAR) + ': NO SE PUDO AÑADIR LOS DATOS')
			RETURN 0
		END CATCH
	END
END
GO
---------------------------------------------------------------------------------------------------------------------------------------

-- AÑADIR PRODUCTO --------------------------------------------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE catalogos.AddProducto (
	@nombre VARCHAR(100),
	@precioARS DECIMAL(9,2),
	@precioUSD DECIMAL(9,2),
	@precioRef DECIMAL(9,2),
	@unidadRef VARCHAR(10),
	@fecha SMALLDATETIME,
	@proveedor VARCHAR(50),
	@cantxUn VARCHAR(20),
	@categoria VARCHAR(50))
AS
BEGIN
	IF(@nombre IS NULL OR @precioUSD IS NULL OR @precioUSD < 0 OR @precioARS < 0 OR @categoria IS NULL)
	BEGIN
		PRINT('Ingrese datos validos')
		RETURN 0
	END

	IF(EXISTS(SELECT 1 FROM catalogos.Producto WHERE nombre=@nombre AND precioUSD=@precioUSD))
	BEGIN
		PRINT('El producto ya existe en el catalogo')
		RETURN 0
	END

	IF(NOT EXISTS(SELECT 1 FROM catalogos.CategoriaProducto WHERE categoria=@categoria))
	BEGIN
		PRINT('La categoria ingresada no existe')
		RETURN 0
	END

	ELSE
	BEGIN
		BEGIN TRY
			INSERT INTO catalogos.Producto (nombre,precioARS,precioUSD,precioRef,unidadRef,fecha,proveedor,cantXUN,idCategoria)
			VALUES (@nombre,@precioARS,@precioUSD,@precioRef,@unidadRef,@fecha,@proveedor,@cantxUn,(SELECT id FROM catalogos.CategoriaProducto WHERE categoria=@categoria))
			PRINT('Producto añadido con exito')
			RETURN 1
		END TRY
		BEGIN CATCH
			PRINT('ERROR ' + CAST(ERROR_NUMBER() AS VARCHAR) + ': NO SE PUDO AÑADIR LOS DATOS')
			RETURN 0
		END CATCH
	END
END
GO

-- AÑADIR CATEGORIA DE PRODUCTO
CREATE OR ALTER PROCEDURE catalogos.AddCategoria (@categoria VARCHAR(50), @linea VARCHAR(20))
AS
BEGIN
	IF(@categoria IS NULL OR @linea IS NULL)
	BEGIN
		PRINT('Ingrese valores validos')
		RETURN 0
	END

	IF(EXISTS(SELECT 1 FROM catalogos.CategoriaProducto WHERE categoria=@categoria))
	BEGIN
		PRINT('Ya existe la categoria ingresada')
		RETURN 0
	END

	IF(NOT EXISTS(SELECT 1 FROM catalogos.LineaCategoria WHERE linea=@linea))
	BEGIN
		PRINT('No existe la linea ingresada')
		RETURN 0
	END

	ELSE
	BEGIN
		BEGIN TRY
			INSERT INTO catalogos.CategoriaProducto (categoria, idLineaCategoria) VALUES (@categoria,(SELECT id FROM catalogos.LineaCategoria WHERE linea=@linea))
			PRINT('Se ha añadido correctamente la categoria')
			RETURN 0
		END TRY
		BEGIN CATCH
			PRINT('ERROR ' + CAST(ERROR_NUMBER() AS VARCHAR) + ': NO SE PUDO AÑADIR LOS DATOS')
			RETURN 0
		END CATCH
	END
END
GO

-- AÑADIR LINEA CATEGORIA
CREATE OR ALTER PROCEDURE catalogos.AddLineaC (@linea VARCHAR(20))
AS
BEGIN
	IF(@linea IS NULL)
	BEGIN
		PRINT('Ingrese valores validos')
		RETURN 0
	END

	IF(EXISTS(SELECT 1 FROM catalogos.LineaCategoria WHERE linea=@linea))
	BEGIN
		PRINT('Ya existe la linea de producto ingresada')
		RETURN 0
	END

	ELSE
	BEGIN
		BEGIN TRY
			INSERT INTO catalogos.LineaCategoria (linea) VALUES (@linea)
			PRINT('Se ha añadido correctamente la linea de categoria')
			RETURN 1
		END TRY
		BEGIN CATCH
			PRINT('ERROR ' + CAST(ERROR_NUMBER() AS VARCHAR) + ': NO SE PUDO AÑADIR LOS DATOS')
			RETURN 0
		END CATCH
	END
END
GO
---------------------------------------------------------------------------------------------------------------------------------------

--AÑADIR PRODUCTO A LA LISTA ----------------------------------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE ventas.AddProdLista (@idFactura CHAR(11), @idProducto INT, @cantidad INT)
AS
BEGIN
	IF(@idFactura IS NULL OR @idProducto IS NULL OR @cantidad IS NULL OR @cantidad < 0)
	BEGIN
		PRINT('Ingrese valores validos')
		RETURN 0
	END

	IF(@idFactura NOT LIKE '[0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9]')
	BEGIN
		PRINT('El ID de factura no cumple con el formato correcto')
		RETURN 0
	END

	IF(NOT EXISTS(SELECT 1 FROM ventas.Factura WHERE idFactura = @idFactura))
	BEGIN
		PRINT('No existe la factura a la cual se le quiere añadir productos')
		RETURN 0
	END

	IF(NOT EXISTS(SELECT 1 FROM catalogos.Producto WHERE id = @idProducto))
	BEGIN
		PRINT('No existe el producto a añadir')
		RETURN 0
	END

	IF(NOT EXISTS(SELECT precioARS,precioUSD FROM catalogos.Producto WHERE id=@idProducto))
	BEGIN
		PRINT('El producto esta sin precios')
		RETURN 0
	END

	IF(EXISTS(SELECT 1 FROM ventas.ListaProducto WHERE idFactura=@idFactura AND idProducto=@idProducto))
	BEGIN
		PRINT('Ya existe el producto en la lista de la factura indicada')
		RETURN 0
	END

	BEGIN
		BEGIN TRY
			DECLARE @subtotal DECIMAL (12,2)

			IF(EXISTS (SELECT precioARS FROM catalogos.Producto WHERE id = @idProducto))
				SET @subtotal = (SELECT precioARS FROM catalogos.Producto WHERE id = @idProducto) * @cantidad
			ELSE
				SET @subtotal = (SELECT precioUSD FROM catalogos.Producto WHERE id = @idProducto) * apis.dolarHoy(1) * @cantidad

			INSERT INTO ventas.ListaProducto (idFactura,idProducto,cantidad,subtotal) VALUES (@idFactura,@idProducto,@cantidad,@subtotal)
			PRINT('Se ha añadido correctamente el producto a la lista')
			RETURN 1
		END TRY
		BEGIN CATCH
			PRINT('ERROR ' + CAST(ERROR_NUMBER() AS VARCHAR) + ': NO SE PUDO AÑADIR LOS DATOS')
			RETURN 0
		END CATCH
	END
END
GO
---------------------------------------------------------------------------------------------------------------------------------------

--AÑADIR COMPROBANTE FACTURA ----------------------------------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE ventas.AddComprobanteFact (@idFactura CHAR(11), @medioDePago VARCHAR(25), @identificador VARCHAR(50))
AS
BEGIN
	IF(@idFactura IS NULL OR @medioDePago IS NULL)
	BEGIN
		PRINT('Ingrese valores validos')
		RETURN 0
	END

	IF(@idFactura NOT LIKE '[0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9]')
	BEGIN
		PRINT('El ID de factura no cumple con el formato correcto')
		RETURN 0
	END

	IF(NOT EXISTS(SELECT 1 FROM ventas.Factura WHERE idFactura=@idFactura))
	BEGIN
		PRINT('ID de factura no registrado en la base de datos')
		RETURN 0
	END

	IF(NOT EXISTS(SELECT 1 FROM ventas.MedioDePago WHERE nombreESP = @medioDePago OR nombreING = @medioDePago))
	BEGIN
		PRINT('No existe el medio de pago indicado')
		RETURN 0
	END

	IF(EXISTS(SELECT 1 FROM ventas.ComprobanteFactura cf JOIN ventas.Comprobante c ON c.id=cf.id WHERE idFactura=@idFactura))
	BEGIN
		PRINT('Ya existe un comprobante para la factura indicada')
		RETURN 0
	END

	ELSE
	BEGIN
		BEGIN TRY
			DECLARE @fecha DATE = CONVERT(DATE,GETDATE())
			DECLARE @hora TIME = CONVERT(TIME,GETDATE())

			INSERT INTO ventas.Comprobante (idFactura,fecha,hora) VALUES (@idFactura,@fecha,@hora)

			DECLARE @id INT = (SELECT id FROM ventas.Comprobante WHERE idFactura=@idFactura AND fecha=@fecha AND hora=@hora)
			DECLARE @idMedioP INT = (SELECT id FROM ventas.MedioDePago WHERE nombreESP = @medioDePago OR nombreING = @medioDePago)
			DECLARE @monto DECIMAL(12,2) = (SELECT SUM(subtotal) FROM ventas.ListaProducto WHERE idFactura=@idFactura GROUP BY idFactura)

			INSERT INTO ventas.ComprobanteFactura (id,monto,idMedioPago,identificadorPago) VALUES (@id,@monto,@idMedioP,@identificador)

			UPDATE ventas.Factura SET estado = 'Pagada' WHERE idFactura=@idFactura

			PRINT('Se ha añadido correctamente el comprobante de la factura ''' + @idFactura + '''')
			RETURN 1
		END TRY
		BEGIN CATCH
			PRINT('ERROR ' + CAST(ERROR_NUMBER() AS VARCHAR) + ': NO SE PUDO AÑADIR LOS DATOS')
			RETURN 0
		END CATCH
	END
END
GO
---------------------------------------------------------------------------------------------------------------------------------------

-- AÑADIR NOTA DE CREDITO -------------------------------------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE ventas.AddNotaDeCredito (@idFactura CHAR(11), @motivo VARCHAR(50), @idProducto INT)
AS
BEGIN
	IF(@idFactura IS NULL OR @idProducto IS NULL)
	BEGIN
		PRINT('Ingrese valores validos')
		RETURN 0
	END

	IF(@idFactura NOT LIKE '[0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9]')
	BEGIN
		PRINT('El ID de factura no cumple con el formato correcto')
		RETURN 0
	END

	IF(NOT EXISTS(SELECT 1 FROM ventas.Factura WHERE idFactura=@idFactura))
	BEGIN
		PRINT('ID de factura no registrado en la base de datos')
		RETURN 0
	END

	IF(NOT EXISTS(SELECT 1 FROM catalogos.Producto WHERE id=@idProducto))
	BEGIN
		PRINT('ID de producto no registrado en la base de datos')
		RETURN 0
	END

	IF(NOT EXISTS(SELECT 1 FROM ventas.ComprobanteFactura cf JOIN ventas.Comprobante c ON c.id=cf.id WHERE idFactura=@idFactura))
	BEGIN
		PRINT('La factura ingresada se encuentra en un estado Impago')
		RETURN 0
	END

	IF(EXISTS(SELECT 1 FROM ventas.NotaDeCredito nc JOIN ventas.Comprobante c ON c.id=nc.id WHERE idFactura=@idFactura))
	BEGIN
		PRINT('Ya existe una nota de credito para la factura indicada')
		RETURN 0
	END

	IF(NOT EXISTS(SELECT 1 FROM ventas.ListaProducto WHERE idFactura=@idFactura AND idProducto=@idProducto))
	BEGIN
		PRINT('El producto ingresado no se encuentra en la lista de productos de la factura')
		RETURN 0
	END

	ELSE
	BEGIN
		BEGIN TRY
			DECLARE @fecha DATE = CONVERT(DATE,GETDATE())
			DECLARE @hora TIME = CONVERT(TIME,GETDATE())

			INSERT INTO ventas.Comprobante (idFactura,fecha,hora) VALUES (@idFactura,@fecha,@hora)

			DECLARE @id INT = (SELECT id FROM ventas.Comprobante WHERE idFactura=@idFactura AND fecha=@fecha AND hora=@hora)
			DECLARE @credito DECIMAL(12,2) = (SELECT subtotal FROM ventas.ListaProducto WHERE idFactura=@idFactura AND idProducto=@idProducto)
			DECLARE @tipoP VARCHAR(50) = (SELECT categoria FROM catalogos.CategoriaProducto WHERE id=(SELECT idCategoria FROM catalogos.Producto WHERE id=@idProducto))

			INSERT INTO ventas.NotaDeCredito (id,credito,tipoProducto,motivo) VALUES (@id,@credito,@tipoP,@motivo)
			
			DELETE FROM ventas.ListaProducto WHERE idProducto=@idProducto AND idFactura=@idFactura
			PRINT('Se a creado la nota de credito con exito')
			RETURN 1
		END TRY
		BEGIN CATCH
			PRINT('ERROR ' + CAST(ERROR_NUMBER() AS VARCHAR) + ': NO SE PUDO AÑADIR LOS DATOS')
			RETURN 0
		END CATCH
	END
END
GO
---------------------------------------------------------------------------------------------------------------------------------------


/*
SELECT * FROM ventas.ListaProducto
SELECT * FROM ventas.NotaDeCredito

EXEC ventas.AddNotaDeCredito '101-17-6199','No me',1848

SELECT subtotal FROM ventas.ListaProducto WHERE idFactura='101-17-6199' AND idProducto=1848
SELECT categoria FROM catalogos.CategoriaProducto WHERE id=(SELECT idCategoria FROM catalogos.Producto WHERE id=1848)


SELECT * FROM clientes.TipoCliente

SELECT * FROM recursosHumanos.Empleado
SELECT * FROM ventas.TipoFactura

SELECT * FROM ventas.Factura

EXEC ventas.AddFactura '333-33-3335','B','Yugoslavia','Member','Male',257035

EXEC ventas.AddProdLista '333-33-3335',1848,2

EXEC ventas.AddComprobanteFact '333-33-3335','Ewallet',NULL

SELECT * FROM ventas.Comprobante
SELECT * FROM ventas.ComprobanteFactura

*/