USE G13COM5600
GO

/*	CREACION DE PROCEDURES PARA ELIMINACION	*/

-- BORRADO LOGICO EMPLEADO ---------------------------------------------------------------------
CREATE OR ALTER PROCEDURE	recursosHumanos.BajaEmpleado ( @legajo INT )
AS
BEGIN
	IF(@legajo IS NULL OR @legajo < 0)
	BEGIN
		PRINT('Ingrese un legajo valido')	
		RETURN 0
	END

	ELSE
	BEGIN
		IF(NOT EXISTS(SELECT 1 FROM recursosHumanos.Empleado WHERE legajo = @legajo))
		BEGIN
			PRINT('Legajo no registrado en la base de datos')
			RETURN 0
		END

		ELSE
		BEGIN
			IF((SELECT activo FROM recursosHumanos.Empleado WHERE legajo = @legajo) = 0)
			BEGIN
				PRINT('El legajo ''' + CAST(@legajo AS VARCHAR) + ''' ya se encuentra dado de baja.')
				RETURN 0
			END

			ELSE
			BEGIN
				UPDATE recursosHumanos.Empleado SET
					activo = 0 WHERE legajo = @legajo;
				PRINT('Baja a empleado ''' + CAST(@legajo AS VARCHAR) + ''' realizada correctamente.')
				RETURN 1
			END
		END
	END
END
GO

-- BORRADO DE CARGO TRABAJO
CREATE OR ALTER PROCEDURE recursosHumanos.EliminarCargo ( @cargo VARCHAR(50) )
AS
BEGIN
	IF(@cargo IS NULL)
	BEGIN
		PRINT('Ingrese un nombre valido')	
		RETURN 0
	END

	ELSE
	BEGIN
		IF(NOT EXISTS(SELECT 1 FROM recursosHumanos.CargoTrabajo WHERE cargo = @cargo COLLATE SQL_Latin1_General_CP1_CI_AI))
		BEGIN
			PRINT('Cargo no registrado en la base de datos')
			RETURN 0
		END

		ELSE
		BEGIN
			BEGIN TRY
				DELETE FROM recursosHumanos.CargoTrabajo WHERE cargo = @cargo COLLATE SQL_Latin1_General_CP1_CI_AI
				PRINT('El cargo ''' + UPPER(@cargo) + ''' se ha eliminado correctamente. ')
				RETURN 1
			END TRY
			BEGIN CATCH
				PRINT('El cargo ''' + UPPER(@cargo) + ''' aun se encuentra en uso.')
				RETURN 0
			END CATCH
		END
	END
END
GO

-- BORRADO DE TURNO TRABAJO
CREATE OR ALTER PROCEDURE recursosHumanos.EliminarTurno ( @turno VARCHAR(50) )
AS
BEGIN
	IF(@turno IS NULL)
	BEGIN
		PRINT('Ingrese un turno valido')	
		RETURN 0
	END

	ELSE
	BEGIN
		IF(NOT EXISTS(SELECT 1 FROM recursosHumanos.TurnoTrabajo WHERE turno = @turno COLLATE SQL_Latin1_General_CP1_CI_AI))
		BEGIN
			PRINT('Turno no registrado en la base de datos')
			RETURN 0
		END

		ELSE
		BEGIN
			BEGIN TRY
				DELETE FROM recursosHumanos.TurnoTrabajo WHERE turno = @turno COLLATE SQL_Latin1_General_CP1_CI_AI
				PRINT('El turno ''' + UPPER(@turno) + ''' se ha eliminado correctamente. ')
				RETURN 1
			END TRY
			BEGIN CATCH
				PRINT('El turno ''' + UPPER(@turno) + ''' aun se encuentra en uso.')
				RETURN 0
			END CATCH
		END
	END
END
GO
-----------------------------------------------------------------------------------------------

-- BORRADO LOGICO DE SUCURSAL------------------------------------------------------------------
CREATE OR ALTER PROCEDURE sucursales.BajaSucursal ( @id INT )
AS
BEGIN
	IF(@id IS NULL OR @id < 0)
	BEGIN
		PRINT('Ingrese un ID valido')	
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
			IF((SELECT activo FROM sucursales.Sucursal WHERE id = @id) = 0)
			BEGIN
				PRINT('La sucursal con ID ''' + CAST(@id AS VARCHAR) + ''' ya se encuentra dada de baja.')
				RETURN 0
			END

			ELSE
			BEGIN
				UPDATE sucursales.Sucursal SET
					activo = 0 WHERE id=@id;
				PRINT('Baja a sucursal ID ''' + CAST(@id AS VARCHAR) + ''' realizada correctamente.')
				RETURN 1
			END
		END
	END
END
GO
-----------------------------------------------------------------------------------------------

-- BORRADO LOGICO DE PRODUCTO------------------------------------------------------------------
CREATE OR ALTER PROCEDURE catalogos.BajaProducto ( @id INT )
AS
BEGIN
	IF(@id IS NULL OR @id < 0)
	BEGIN
		PRINT('Ingrese un ID valido')	
		RETURN 0
	END

	ELSE
	BEGIN
		IF(NOT EXISTS(SELECT 1 FROM catalogos.Producto WHERE id=@id))
		BEGIN
			PRINT('ID no registrado en la base de datos')
			RETURN 0
		END

		ELSE
		BEGIN
			IF((SELECT activo FROM catalogos.Producto WHERE id = @id) = 0)
			BEGIN
				PRINT('El producto con ID ''' + CAST(@id AS VARCHAR) + ''' ya se encuentra dado de baja.')
				RETURN 0
			END

			ELSE
			BEGIN
				UPDATE catalogos.Producto SET
					activo = 0 WHERE id=@id;
				PRINT('Baja a producto ID ''' + CAST(@id AS VARCHAR) + ''' realizada correctamente.')
				RETURN 1
			END
		END
	END
END
GO

-- BORRADO DE CATEGORIA DE PRODUCTO
CREATE OR ALTER PROCEDURE catalogos.EliminarCategoriaProducto( @categoria VARCHAR(50) )
AS
BEGIN
	IF(@categoria IS NULL)
	BEGIN
		PRINT('Ingrese una categoria valida')
		RETURN 0
	END

	IF(NOT EXISTS(SELECT 1 FROM catalogos.CategoriaProducto WHERE categoria=@categoria COLLATE SQL_Latin1_General_CP1_CI_AI))
	BEGIN
		PRINT('Categoria no registrada en la base de datos')
		RETURN 0
	END

	ELSE
	BEGIN
		BEGIN TRY
			DELETE FROM catalogos.CategoriaProducto WHERE categoria=@categoria COLLATE SQL_Latin1_General_CP1_CI_AI;
			PRINT('Se ha eliminado categoria ''' + @categoria + '''')
			RETURN 1
		END TRY
		BEGIN CATCH
			PRINT('ERROR ' + CAST(ERROR_NUMBER() AS VARCHAR) + ': NO SE PUDO REALIZAR LA ELIMINACION')
			RETURN 0
		END CATCH
	END
END
GO

-- BORRADO DE LINEA CATEGORIA
CREATE OR ALTER PROCEDURE catalogos.EliminaLineaCategoria ( @linea VARCHAR(20) )
AS
BEGIN
	IF(@linea IS NULL)
	BEGIN
		PRINT('Ingrese una linea valida')
		RETURN 0
	END

	IF(NOT EXISTS(SELECT 1 FROM catalogos.LineaCategoria WHERE linea=@linea))
	BEGIN
		PRINT('Linea de producto no registrada en la base de datos')
		RETURN 0
	END

	ELSE
	BEGIN
		BEGIN TRY
			DELETE FROM catalogos.LineaCategoria WHERE linea=@linea COLLATE SQL_Latin1_General_CP1_CI_AI;
			PRINT('Se ha eliminado la linea de producto ''' + @linea + '''')
			RETURN 1
		END TRY
		BEGIN CATCH
			PRINT('ERROR ' + CAST(ERROR_NUMBER() AS VARCHAR) + ': NO SE PUDO REALIZAR LA ELIMINACION')
			RETURN 0
		END CATCH
	END

END
GO
-------------------------------------------------------------------------------------------

-- BORRADO DE FACTURA ---------------------------------------------------------------------
CREATE OR ALTER PROCEDURE ventas.EliminarFacturaComprobante( @idFactura CHAR(11) )
AS
BEGIN
	IF(@idFactura IS NULL)
	BEGIN
		PRINT('Ingrese un ID valido')	
		RETURN 0
	END

	IF(NOT EXISTS(SELECT 1 FROM ventas.Factura WHERE idFactura=@idFactura))
	BEGIN
		PRINT('ID no registrado en la base de datos')
		RETURN 0
	END

	ELSE
	BEGIN
		BEGIN TRY
			DELETE FROM ventas.Factura WHERE idFactura=@idFactura
			PRINT('Se ha eliminado la factura asociada al ID ''' + @idFactura + '''')
			RETURN 1
		END TRY
		BEGIN CATCH
			PRINT('ERROR ' + CAST(ERROR_NUMBER() AS VARCHAR) + ': NO SE PUDO REALIZAR LA ELIMINACION')
			RETURN 0
		END CATCH
	END
END
GO

-- BORRADO DE TIPO DE FACTURA
CREATE OR ALTER PROCEDURE ventas.EliminarTipoFactura( @tipo CHAR(1) )
AS
BEGIN
	IF(@tipo IS NULL)
	BEGIN
		PRINT('Ingrese un tipo valido')
		RETURN 0
	END

	IF(NOT EXISTS ( SELECT 1 FROM ventas.TipoFactura WHERE tipo = @tipo COLLATE SQL_Latin1_General_CP1_CI_AI ))
	BEGIN
		PRINT('Tipo no registrado en la base de datos')
		RETURN 0
	END

	ELSE
	BEGIN
		BEGIN TRY
			DELETE FROM ventas.TipoFactura WHERE tipo = @tipo COLLATE SQL_Latin1_General_CP1_CI_AI;
			PRINT('Se ha eliminado correctamente el tipo de factura')
			RETURN 1
		END TRY
		BEGIN CATCH
			PRINT('ERROR ' + CAST(ERROR_NUMBER() AS VARCHAR) + ': NO SE PUDO REALIZAR LA ELIMINACION')
			RETURN 0
		END CATCH
	END
END
GO

-- BORRADO DE TIPO DE CLIENTE
CREATE OR ALTER PROCEDURE clientes.EliminarTipoCliente( @tipo VARCHAR(20) )
AS
BEGIN
	IF(@tipo IS NULL)
	BEGIN
		PRINT('Ingrese un tipo valido')
		RETURN 0		
	END

	IF(NOT EXISTS(SELECT 1 FROM clientes.TipoCliente WHERE tipo = @tipo COLLATE SQL_Latin1_General_CP1_CI_AI))
	BEGIN
		PRINT('Tipo no registrado en la base de datos')
		RETURN 0	
	END

	ELSE
	BEGIN
		BEGIN TRY
			DELETE FROM ventas.TipoFactura WHERE tipo = @tipo COLLATE SQL_Latin1_General_CP1_CI_AI;
			PRINT('Se ha eliminado correctamente el tipo de cliente')
			RETURN 1
		END TRY
		BEGIN CATCH
			PRINT('ERROR ' + CAST(ERROR_NUMBER() AS VARCHAR) + ': NO SE PUDO REALIZAR LA ELIMINACION')
			RETURN 0
		END CATCH
	END
END
GO

-----------------------------------------------------------------------------------------

-- BORRADO DE LISTA DE PRODUCTO ---------------------------------------------------------
CREATE OR ALTER PROCEDURE ventas.EliminarListaProducto ( @idFactura CHAR(11) )
AS
BEGIN
	IF(@idFactura IS NULL)
	BEGIN
		PRINT('Ingrese un ID de factura valido')
		RETURN 0	
	END

	IF(NOT EXISTS(SELECT 1 FROM ventas.ListaProducto WHERE idFactura=@idFactura))
	BEGIN
		PRINT('ID no registrado en la base de datos')
		RETURN 0	
	END

	ELSE
	BEGIN
		BEGIN TRY
			DELETE FROM ventas.ListaProducto WHERE idFactura = @idFactura;
			PRINT('Se ha eliminado correctamente la lista de productos')
			RETURN 1
		END TRY
		BEGIN CATCH
			PRINT('ERROR ' + CAST(ERROR_NUMBER() AS VARCHAR) + ': NO SE PUDO REALIZAR LA ELIMINACION')
			RETURN 0
		END CATCH
	END

END
GO

-----------------------------------------------------------------------------------------

-- BORRADO DE COMPROBANTE FACTURA -------------------------------------------------------
CREATE OR ALTER PROCEDURE ventas.EliminarComprobanteFactura ( @idFactura CHAR(11) )
AS
BEGIN
	IF( @idFactura IS NULL )
	BEGIN
		PRINT('Ingrese un ID de factura valido')
		RETURN 0
	END

	IF(NOT EXISTS(SELECT 1 FROM ventas.Comprobante WHERE idFactura=@idFactura))
	BEGIN
		PRINT('ID no registrado en la base de datos')
		RETURN 0
	END

	ELSE
	BEGIN
		BEGIN TRY
			DELETE FROM ventas.ComprobanteFactura WHERE id = (SELECT id FROM ventas.Comprobante WHERE idFactura=@idFactura)
			DELETE FROM ventas.Comprobante WHERE idFactura=@idFactura;
			PRINT('Se ha eliminado correctamente el comprobante factura')
			RETURN 1
		END TRY
		BEGIN CATCH
			PRINT('ERROR ' + CAST(ERROR_NUMBER() AS VARCHAR) + ': NO SE PUDO REALIZAR LA ELIMINACION')
			RETURN 0
		END CATCH
	END
END
GO

-- BORRADO DE MEDIO DE PAGO
CREATE OR ALTER PROCEDURE ventas.EliminarMedioDePago( @nombre VARCHAR(25) )
AS
BEGIN
	IF(@nombre IS NULL)
	BEGIN
		PRINT('Ingrese un nombre valido')
		RETURN 0
	END

	IF(NOT EXISTS(SELECT 1 FROM ventas.MedioDePago WHERE nombreESP = @nombre OR nombreING = @nombre))
	BEGIN
		PRINT('Medio de pago no registrado en la base de datos')
		RETURN 0
	END

	ELSE
	BEGIN
		BEGIN TRY
			DELETE FROM ventas.MedioDePago WHERE nombreESP=@nombre OR nombreING=@nombre
			PRINT('Se ha eliminado correctamente el medio de pago')
			RETURN 1
		END TRY
		BEGIN CATCH
			PRINT('ERROR ' + CAST(ERROR_NUMBER() AS VARCHAR) + ': NO SE PUDO REALIZAR LA ELIMINACION')
			RETURN 0
		END CATCH
	END
END
GO

-- BORRADO DE NOTA DE CREDITO
CREATE OR ALTER PROCEDURE ventas.EliminarNotaDeCredito( @idFactura CHAR(11) )
AS
BEGIN
	IF(@idFactura IS NULL)
	BEGIN
		PRINT('Ingrese un ID de factura valido')
		RETURN 0
	END

	IF(NOT EXISTS(SELECT 1 FROM ventas.Comprobante WHERE idFactura=@idFactura))
	BEGIN
		PRINT('Nota de credito no registrado en la base de datos')
		RETURN 0
	END

	ELSE
	BEGIN
		BEGIN TRY
			DELETE FROM ventas.NotaDeCredito WHERE id = (SELECT id FROM ventas.Comprobante WHERE idFactura=@idFactura)
			DELETE FROM ventas.Comprobante WHERE idFactura=@idFactura
			PRINT('Se ha eliminado correctamente la Nota de credito')
			RETURN 1
		END TRY
		BEGIN CATCH
			PRINT('ERROR ' + CAST(ERROR_NUMBER() AS VARCHAR) + ': NO SE PUDO REALIZAR LA ELIMINACION')
			RETURN 0
		END CATCH
	END
END
GO

-----------------------------------------------------------------------------------------