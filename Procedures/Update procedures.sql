USE G13COM5600
GO

/*	CREACION DE PROCEDURES PARA MODIFICACION	*/

-- MODIFICACION DE TELEFONO SUCURSAL ---------------------------------------------------
CREATE OR ALTER PROCEDURE sucursales.ModificarTelefono ( @id INT, @telefono CHAR(9) )
AS
BEGIN
	IF(@id IS NULL OR @telefono IS NULL)
	BEGIN
		PRINT('Ingrese datos validos')
		RETURN 0
	END

	IF(@telefono NOT LIKE '[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]')
	BEGIN
		PRINT('Formato de telefono incorrecto')
		RETURN 0
	END

	IF(EXISTS (SELECT 1 FROM sucursales.Sucursal WHERE telefono=@telefono))
	BEGIN
		PRINT('Ya existe una sucursal con ese telefono')
		RETURN 0
	END

	ELSE
	BEGIN
		IF(NOT EXISTS(SELECT 1 FROM sucursales.Sucursal WHERE id=@id))
		BEGIN
			PRINT('ID no registrado en la base de datos')
			RETURN 0
		END

		ELSE
		BEGIN
			BEGIN TRY
				UPDATE sucursales.Sucursal SET telefono=@telefono WHERE id=@id
				PRINT('Telefono actualizado correctamente')
				RETURN 1
			END TRY
			BEGIN CATCH
				PRINT('ERROR ' + CAST(ERROR_NUMBER() AS VARCHAR) + ': NO SE PUDO REALIZAR LA ACTUALIZACION')
				RETURN 0
			END CATCH
		END
	END
END
GO
----------------------------------------------------------------------------------------

--MODIFICACION DE EMAIL PERSONAL EMPLEADO ----------------------------------------------
CREATE OR ALTER PROCEDURE recursosHumanos.ModificarEmailPer ( @legajo INT, @emailPer VARCHAR(60) )
AS
BEGIN
	IF(@legajo IS NULL OR @legajo < 0 OR @emailPer IS NULL)
	BEGIN
		PRINT('Ingrese valores validos')
		RETURN 0
	END

	IF(NOT EXISTS(SELECT 1 FROM recursosHumanos.Empleado WHERE legajo=@legajo))
	BEGIN
		PRINT('Legajo no registrado en la base de datos')
		RETURN 0
	END

	IF(@emailPer NOT LIKE '[A-Z]%[A-Z0-9][@][A-Z]%[.][A-Z]%')
	BEGIN
		PRINT('El email no cumple con el formato')
		RETURN 0
	END

	ELSE
	BEGIN
		BEGIN TRY 
			UPDATE recursosHumanos.Empleado SET emailPer = @emailPer WHERE legajo=@legajo
			PRINT('Email personal cambiado correctamente')
			RETURN 1
		END TRY
		BEGIN CATCH
			PRINT('ERROR ' + CAST(ERROR_NUMBER() AS VARCHAR) + ': NO SE PUDO REALIZAR LA ACTUALIZACION')
			RETURN 0	
		END CATCH
	END
END
GO

-- MODIFICACION TURNO TRABAJO
CREATE OR ALTER PROCEDURE recursosHumanos.ModificarNombreTurno( @turno VARCHAR(20), @nuevo VARCHAR(20) )
AS
BEGIN
	IF(@turno IS NULL OR @nuevo IS NULL)
	BEGIN
		PRINT('Ingrese valores validos')
		RETURN 0
	END

	IF(NOT EXISTS (SELECT 1 FROM recursosHumanos.TurnoTrabajo WHERE turno = @turno COLLATE SQL_Latin1_General_CP1_CI_AI))
	BEGIN
		PRINT('Turno no registrado en la base de datos')
		RETURN 0
	END

	IF(EXISTS(SELECT 1 FROM recursosHumanos.TurnoTrabajo WHERE turno = @nuevo COLLATE SQL_Latin1_General_CP1_CI_AI))
	BEGIN
		PRINT('Ya existe un turno con el nombre ingresado')
		RETURN 0
	END

	ELSE
	BEGIN
		BEGIN TRY
			UPDATE recursosHumanos.TurnoTrabajo SET turno = @nuevo WHERE turno = @turno COLLATE SQL_Latin1_General_CP1_CI_AI
			PRINT('Actualizacion realizada con exito')
			RETURN 1
		END TRY
		BEGIN CATCH
			PRINT('ERROR ' + CAST(ERROR_NUMBER() AS VARCHAR) + ': NO SE PUDO REALIZAR LA ACTUALIZACION')
			RETURN 0	
		END CATCH
	END
END
GO

-- MODIFICACION CARGO TRABAJO
CREATE OR ALTER PROCEDURE recursosHumanos.ModificarNombreCargo (@cargo VARCHAR (30), @nuevo VARCHAR(30) )
AS
BEGIN
	IF(@cargo IS NULL OR @nuevo IS NULL)
	BEGIN
		PRINT('Ingrese valores validos')
		RETURN 0
	END

	IF(NOT EXISTS(SELECT 1 FROM recursosHumanos.CargoTrabajo WHERE cargo = @cargo COLLATE SQL_Latin1_General_CP1_CI_AI))
	BEGIN
		PRINT('Cargo no registrado en la base de datos')
		RETURN 0
	END

	IF(EXISTS(SELECT 1 FROM recursosHumanos.CargoTrabajo WHERE cargo= @nuevo COLLATE SQL_Latin1_General_CP1_CI_AI))
	BEGIN
		PRINT('Ya existe un cargo con el nombre ingresado')
		RETURN 0
	END

	ELSE
	BEGIN
		BEGIN TRY
			UPDATE recursosHumanos.CargoTrabajo SET cargo = @nuevo WHERE cargo = @cargo COLLATE SQL_Latin1_General_CP1_CI_AI
			PRINT('La actualizacion se realizo correctamente')
			RETURN 1
		END TRY
		BEGIN CATCH
			PRINT('ERROR ' + CAST(ERROR_NUMBER() AS VARCHAR) + ': NO SE PUDO REALIZAR LA ACTUALIZACION')
			RETURN 0	
		END CATCH
	END
END
GO
----------------------------------------------------------------------------------------

--MODIFICACION DE PRECIO USD DE PRODUCTO -----------------------------------------------
CREATE OR ALTER PROCEDURE catalogos.ModificarPrecioUSD ( @id INT, @precio DECIMAL(9,2) )
AS
BEGIN
	IF(@id IS NULL OR @id < 0 OR @precio IS NULL OR @precio < 0)
	BEGIN
		PRINT('Ingrese valores validos')
		RETURN 0
	END

	IF(NOT EXISTS(SELECT 1 FROM catalogos.Producto WHERE id=@id))
	BEGIN
		PRINT('ID producto no registrado en la base de datos')
		RETURN 0
	END

	ELSE
	BEGIN
		BEGIN TRY
			UPDATE catalogos.Producto SET precioUSD = @precio WHERE id=@id
			PRINT('Precio actualizado correctamente')
			RETURN 1
		END TRY
		BEGIN CATCH
			PRINT('ERROR ' + CAST(ERROR_NUMBER() AS VARCHAR) + ': NO SE PUDO REALIZAR LA ACTUALIZACION')
			RETURN 0
		END CATCH
	END
END
GO



--MODIFICAR NOMBRE CATEGORIA
CREATE OR ALTER PROCEDURE catalogos.ModificarNombreCat( @categoria VARCHAR(50), @nueva VARCHAR(50) )
AS
BEGIN
	IF(@categoria IS NULL OR @nueva IS NULL)
	BEGIN
		PRINT('Ingrese datos validos')
		RETURN 0
	END

	IF(NOT EXISTS(SELECT 1 FROM catalogos.CategoriaProducto WHERE categoria=@categoria COLLATE SQL_Latin1_General_CP1_CI_AI))
	BEGIN
		PRINT('Categoria no registrada en la base de datos')
		RETURN 0
	END

	IF(EXISTS(SELECT 1 FROM catalogos.CategoriaProducto WHERE categoria=@nueva COLLATE SQL_Latin1_General_CP1_CI_AI))
	BEGIN
		PRINT('Ya existe una categoria con el nombre ingresado')
		RETURN 0
	END

	ELSE
	BEGIN
		BEGIN TRY
			UPDATE catalogos.CategoriaProducto SET categoria = @nueva WHERE categoria=@categoria COLLATE SQL_Latin1_General_CP1_CI_AI
			PRINT('Categoria actualizada con exito')
			RETURN 1
		END TRY
		BEGIN CATCH
			PRINT('ERROR ' + CAST(ERROR_NUMBER() AS VARCHAR) + ': NO SE PUDO REALIZAR LA ACTUALIZACION')
			RETURN 0	
		END CATCH
	END
END
GO

-- MODIFICACION LINEA PRODUCTO 
CREATE OR ALTER PROCEDURE catalogos.ModificarNombreLinea( @linea VARCHAR(20), @nueva VARCHAR(20) )
AS
BEGIN
	IF(@linea IS NULL OR @nueva IS NULL)
	BEGIN
		PRINT('Ingrese datos validos')
		RETURN 0
	END

	IF(NOT EXISTS(SELECT 1 FROM catalogos.LineaCategoria WHERE linea=@linea COLLATE SQL_Latin1_General_CP1_CI_AI))
	BEGIN
		PRINT('Linea de producto no registrada en la base de datos')
		RETURN 0
	END

	IF(EXISTS(SELECT 1 FROM catalogos.LineaCategoria WHERE linea=@nueva COLLATE SQL_Latin1_General_CP1_CI_AI))
	BEGIN
		PRINT('Ya existe una linea de producto con el nombre ingresado')
		RETURN 0
	END

	ELSE
	BEGIN
		BEGIN TRY
			UPDATE catalogos.LineaCategoria SET linea = @nueva WHERE linea = @linea COLLATE SQL_Latin1_General_CP1_CI_AI
			PRINT('Linea de producto actualizada con exito')
			RETURN 1
		END TRY
		BEGIN CATCH
			PRINT('ERROR ' + CAST(ERROR_NUMBER() AS VARCHAR) + ': NO SE PUDO REALIZAR LA ACTUALIZACION')
			RETURN 0	
		END CATCH
	END
END
GO
----------------------------------------------------------------------------------------

--MODIFICACION DE ESTADO DE FACTURA ----------------------------------------------------
CREATE OR ALTER PROCEDURE ventas.ModificarEstadoFactura ( @idFactura CHAR(11) , @estado char(6) )
AS
BEGIN
	IF(@idFactura IS NULL OR @estado IS NULL)
	BEGIN 
		PRINT('Ingrese valores validos')
		RETURN 0
	END

	IF(@idFactura NOT LIKE '[0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9]')
	BEGIN
		PRINT('El ID factura no esta en un formato correcto')
		RETURN 0
	END

	IF(NOT EXISTS(SELECT 1 FROM ventas.Factura WHERE idFactura = @idFactura))
	BEGIN
		PRINT('ID de factura no registrado en la base de datos')
		RETURN 0
	END

	IF(@estado COLLATE SQL_Latin1_General_CP1_CI_AI NOT IN ('Impaga','Pagada'))
	BEGIN
		PRINT('Ingrese un estado de factura valido')
		RETURN 0
	END

	IF((SELECT estado FROM ventas.Factura WHERE idFactura=@idFactura) = @estado)
	BEGIN
		PRINT('El estado actual ya se encuentra en ''' + @estado +'''')
		RETURN 0
	END

	ELSE
	BEGIN
		BEGIN TRY
			UPDATE ventas.Factura SET estado = @estado WHERE idFactura=@idFactura
			PRINT('Estado de factura actualizado correctamente')
			RETURN 1
		END TRY
		BEGIN CATCH
			PRINT('ERROR ' + CAST(ERROR_NUMBER() AS VARCHAR) + ': NO SE PUDO REALIZAR LA ACTUALIZACION')
			RETURN 0
		END CATCH
	END
END
GO

-- MODIFICACION DE TIPO DE CLIENTE
CREATE OR ALTER PROCEDURE clientes.ModificarNombreTCliente ( @tipo VARCHAR(20) , @nueva VARCHAR(20) )
AS
BEGIN
	IF(@tipo IS NULL OR @nueva IS NULL)
	BEGIN
		PRINT('Ingrese datos validos')
		RETURN 0
	END

	IF(NOT EXISTS(SELECT 1 FROM clientes.TipoCliente WHERE tipo=@tipo COLLATE SQL_Latin1_General_CP1_CI_AI))
	BEGIN
		PRINT('Tipo de cliente no registrado en la base de datos')
		RETURN 0
	END

	IF(EXISTS(SELECT 1 FROM clientes.TipoCliente WHERE tipo=@nueva COLLATE SQL_Latin1_General_CP1_CI_AI))
	BEGIN
		PRINT('Ya existe un tipo de cliente con el nombre ingresado')
		RETURN 0
	END

	ELSE
	BEGIN
		BEGIN TRY
			UPDATE clientes.TipoCliente SET tipo = @nueva WHERE tipo = @tipo COLLATE SQL_Latin1_General_CP1_CI_AI
			PRINT('Se actualizo el tipo de cliente con exito')
			RETURN 1
		END TRY
		BEGIN CATCH
			PRINT('ERROR ' + CAST(ERROR_NUMBER() AS VARCHAR) + ': NO SE PUDO REALIZAR LA ACTUALIZACION')
			RETURN 0
		END CATCH
	END
END
GO
----------------------------------------------------------------------------------------

-- MODIFICACION COMPROBANTE ------------------------------------------------------------
CREATE OR ALTER PROCEDURE ventas.ModificarMPComprobanteF ( @idFactura CHAR(11) , @medio VARCHAR(25) )
AS
BEGIN
	IF(@idFactura IS NULL OR @medio IS NULL)
	BEGIN
		PRINT('Ingrese datos validos')
		RETURN 0
	END

	IF(@idFactura NOT LIKE '[0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9]')
	BEGIN
		PRINT('ID de factura ingresado no cumple con el formato correcto')
		RETURN 0
	END

	IF(NOT EXISTS(SELECT 1 FROM ventas.Comprobante WHERE idFactura=@idFactura ))
	BEGIN
		PRINT('ID factura no registrado en la base de datos')
		RETURN 0
	END

	ELSE
	BEGIN
		BEGIN TRY
			UPDATE ventas.ComprobanteFactura 
			SET idMedioPago = (SELECT id FROM ventas.MedioDePago 
			WHERE nombreESP = @medio COLLATE SQL_Latin1_General_CP1_CI_AI OR nombreING = @medio COLLATE SQL_Latin1_General_CP1_CI_AI)
			WHERE id = (SELECT id FROM ventas.Comprobante WHERE idFactura=@idFactura)
			PRINT('Medio de pago actualizado con exito')
			RETURN 1
		END TRY
		BEGIN CATCH
			PRINT('ERROR ' + CAST(ERROR_NUMBER() AS VARCHAR) + ': NO SE PUDO REALIZAR LA ACTUALIZACION')
			RETURN 0
		END CATCH
	END
END
GO

-- MODIFICACION NOTA DE CREDITO
CREATE OR ALTER PROCEDURE ventas.ModificarMotivoNC( @idFactura CHAR(11) , @motivo VARCHAR(50) )
AS
BEGIN
	IF(@idFactura IS NULL OR @motivo IS NULL)
	BEGIN
		PRINT('Ingrese valores validos')
		RETURN 0
	END

	IF(@idFactura NOT LIKE '[0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9]')
	BEGIN
		PRINT('ID de factura ingresado no cumple con el formato correcto')
		RETURN 0
	END

	IF(NOT EXISTS(SELECT 1 FROM ventas.Comprobante WHERE idFactura=@idFactura ))
	BEGIN
		PRINT('ID factura no registrado en la base de datos')
		RETURN 0
	END

	IF(NOT EXISTS(SELECT 1 FROM ventas.NotaDeCredito WHERE id = (SELECT id FROM ventas.Comprobante WHERE idFactura=@idFactura)))
	BEGIN
		PRINT('No existe una nota de credito asociada a la factura ingresada')
		RETURN 0
	END

	ELSE
	BEGIN
		BEGIN TRY
			UPDATE ventas.NotaDeCredito SET motivo = @motivo WHERE id = (SELECT id FROM ventas.Comprobante WHERE idFactura=@idFactura)
			PRINT('Motivo de nota de credito actualizado con exito')
			RETURN 1
		END TRY
		BEGIN CATCH
			PRINT('ERROR ' + CAST(ERROR_NUMBER() AS VARCHAR) + ': NO SE PUDO REALIZAR LA ACTUALIZACION')
			RETURN 0
		END CATCH
	END
END
GO
----------------------------------------------------------------------------------------