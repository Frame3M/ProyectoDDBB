/* GRUPO 13
BASE DE DATOS APLICADA

ORTEGA MARCO ANTONIO - 44108566

Luego de decidirse por un motor de base de datos relacional, llegó el momento de generar la
base de datos.
Deberá instalar el DMBS y documentar el proceso. No incluya capturas de pantalla. Detalle
las configuraciones aplicadas (ubicación de archivos, memoria asignada, seguridad, puertos,
etc.) en un documento como el que le entregaría al DBA.
Cree la base de datos, entidades y relaciones. Incluya restricciones y claves. Deberá entregar
un archivo .sql con el script completo de creación (debe funcionar si se lo ejecuta “tal cual” es
entregado). Incluya comentarios para indicar qué hace cada módulo de código.
Genere store procedures para manejar la inserción, modificado, borrado (si corresponde,
también debe decidir si determinadas entidades solo admitirán borrado lógico) de cada tabla.
Los nombres de los store procedures NO deben comenzar con “SP”.
Genere esquemas para organizar de forma lógica los componentes del sistema y aplique esto
*/

IF NOT EXISTS (SELECT * FROM SYS.DATABASES WHERE name = 'G13COM5600')
	CREATE DATABASE G13COM5600
GO

USE G13COM5600
GO

---

IF NOT EXISTS (SELECT * FROM SYS.SCHEMAS WHERE name = 'ventas')
	EXEC('CREATE SCHEMA ventas')
GO

IF NOT EXISTS (SELECT * FROM SYS.SCHEMAS WHERE name = 'catalogos')
	EXEC('CREATE SCHEMA catalogos')
GO

IF NOT EXISTS (SELECT * FROM SYS.SCHEMAS WHERE name = 'recursosHumanos')
	EXEC('CREATE SCHEMA recursosHumanos')
GO

IF NOT EXISTS (SELECT * FROM SYS.SCHEMAS WHERE name = 'clientes')
	EXEC('CREATE SCHEMA clientes')
GO

IF NOT EXISTS (SELECT * FROM SYS.SCHEMAS WHERE name = 'sucursales')
	EXEC('CREATE SCHEMA sucursales')
GO

--- TABLAS PERTENECIENTES AL SCHEMA 'SUCURSALES'

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA = 'sucursales' AND TABLE_NAME = 'Sucursal')
BEGIN
	CREATE TABLE sucursales.Sucursal(
		id INT IDENTITY (1,1) PRIMARY KEY,
		ciudad VARCHAR(20),
		horario VARCHAR(50),
		direccion VARCHAR(100),
		telefono CHAR(9),
		activo INT DEFAULT 1,

		CONSTRAINT UNIQUE_sucursal UNIQUE (direccion,ciudad))
END
GO

--- TABLAS PERTENECIENTES AL SCHEMA 'RECURSOSHUMANOS'

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA = 'recursosHumanos' AND TABLE_NAME = 'CargoTrabajo')
BEGIN
	CREATE TABLE recursosHumanos.CargoTrabajo(
	id INT IDENTITY (1,1) PRIMARY KEY,
	cargo VARCHAR(30))
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA = 'recursosHumanos' AND TABLE_NAME = 'TurnoTrabajo')
BEGIN
	CREATE TABLE recursosHumanos.TurnoTrabajo(
	id INT IDENTITY (1,1) PRIMARY KEY,
	turno VARCHAR(20))
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA = 'recursosHumanos' AND TABLE_NAME = 'Empleado')
BEGIN
	CREATE TABLE recursosHumanos.Empleado(
	--id INT IDENTITY(1,1) PRIMARY KEY,
	legajo INT IDENTITY(257020,1) PRIMARY KEY,
	nombre VARCHAR(50),
	apellido VARCHAR(50),
	dni INT UNIQUE,
	cuil CHAR (13),
	emailPer VARCHAR(60),
	emailEmp VARCHAR(60),
	direccion VARCHAR(100),
	idSucursal INT,
	idTurno INT,
	idCargo INT,
	activo INT DEFAULT 1,

	CONSTRAINT FK_Sucursal FOREIGN KEY (idSucursal) REFERENCES sucursales.Sucursal(id),
	CONSTRAINT FK_Turno FOREIGN KEY (idTurno) REFERENCES recursosHumanos.TurnoTrabajo(id),
	CONSTRAINT FK_Cargo FOREIGN KEY (idCargo) REFERENCES recursosHumanos.CargoTrabajo(id))

	--CREATE NONCLUSTERED INDEX Idx_legajo ON recursosHumanos.Empleado(legajo);
END
GO

--- TABLAS PERTENECIENTES AL SCHEMA 'CLIENTES'

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA = 'clientes' AND TABLE_NAME = 'TipoCliente')
BEGIN
	CREATE TABLE clientes.TipoCliente(
	id INT IDENTITY (1,1) PRIMARY KEY,
	tipo VARCHAR(20) UNIQUE)
END
GO

--- TABLAS PERTENECIENTES AL SCHEMA 'CATALOGOS'

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA = 'catalogos' AND TABLE_NAME = 'LineaCategoria')
BEGIN
	CREATE TABLE catalogos.LineaCategoria(
	id INT IDENTITY (1,1) PRIMARY KEY,
	linea VARCHAR(20) UNIQUE)
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA = 'catalogos' AND TABLE_NAME = 'CategoriaProducto')
BEGIN
	CREATE TABLE catalogos.CategoriaProducto(
	id INT IDENTITY (1,1) PRIMARY KEY,
	categoria VARCHAR(50) UNIQUE,
	idLineaCategoria INT,
	
	CONSTRAINT FK_LineaCategoria FOREIGN KEY (idLineaCategoria) REFERENCES catalogos.LineaCategoria(id))
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE -- VARIOS CAMBIOS
TABLE_SCHEMA = 'catalogos' AND TABLE_NAME = 'Producto')
BEGIN
	CREATE TABLE catalogos.Producto(
	id INT IDENTITY (1,1) PRIMARY KEY,
	nombre VARCHAR(100),
	precioARS DECIMAL(9,2),
	precioUSD DECIMAL(9,2),
	precioRef DECIMAL(9,2),
	unidadRef VARCHAR(10),
	fecha SMALLDATETIME,
	proveedor VARCHAR(50),
	cantXUn VARCHAR(20),
	idCategoria INT,
	activo INT DEFAULT 1,

	CONSTRAINT UNIQUE_Producto UNIQUE(nombre,precioARS,precioUSD),
	CONSTRAINT FK_Categoria FOREIGN KEY (idCategoria) REFERENCES catalogos.CategoriaProducto(id))
END
GO

--- TABLAS PERTENECIENTES AL SCHEMA 'VENTAS'

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA = 'ventas' AND TABLE_NAME = 'TipoFactura')
BEGIN
	CREATE TABLE ventas.TipoFactura(
	id INT IDENTITY (1,1) PRIMARY KEY,
	tipo CHAR(1))
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA = 'ventas' AND TABLE_NAME = 'Factura')
BEGIN
	CREATE TABLE ventas.Factura(
	id INT IDENTITY(1,1) PRIMARY KEY,
	idFactura CHAR(11) UNIQUE,
	idTipoFactura INT,
	ciudad VARCHAR(60),
	idTipoCliente INT,
	generoCliente CHAR(10) CHECK(generoCliente IN ('Male','Female')),
	legajoEmp INT,
	--monto DECIMAL(16,2), --nuevo
	fecha DATE,
	hora TIME,
	estado char(6) DEFAULT 'Impaga' CHECK(estado IN ('Impaga','Pagada')),

	CONSTRAINT FK_Empleado FOREIGN KEY (legajoEmp) REFERENCES recursosHumanos.Empleado(legajo),
	CONSTRAINT FK_TipoFactura FOREIGN KEY (idTipoFactura) REFERENCES ventas.TipoFactura(id),
	CONSTRAINT FK_TipoCliente FOREIGN KEY (idTipoCliente) REFERENCES clientes.TipoCliente(id))

	CREATE NONCLUSTERED INDEX Idx_idFactura ON ventas.Factura(idFactura);
END
GO

--- COMPROBANTE

/*
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA = 'ventas' AND TABLE_NAME = 'TipoComprobante')
BEGIN
	CREATE TABLE ventas.TipoComprobante(
	id INT IDENTITY (1,1) PRIMARY KEY,
	tipo VARCHAR(20) UNIQUE)

	INSERT INTO ventas.TipoComprobante VALUES ('Factura'),('Nota de credito') ; --NUEVOOOO
END
GO
*/

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA = 'ventas' AND TABLE_NAME = 'MedioDePago')
BEGIN
	CREATE TABLE ventas.MedioDePago(
	id INT IDENTITY (1,1) PRIMARY KEY,
	nombreESP VARCHAR(25) UNIQUE,
	nombreING VARCHAR(25) UNIQUE)
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA = 'ventas' AND TABLE_NAME = 'Comprobante')
BEGIN
	CREATE TABLE ventas.Comprobante(
	id INT IDENTITY (1,1) PRIMARY KEY,
	--idTipo INT,
	idFactura CHAR(11),
	--idMedioPago INT,
	fecha DATE,
	hora TIME,
	--credito DECIMAL(12,2), --nuevo

	CONSTRAINT FK_FacturaAsociada FOREIGN KEY (idFactura) REFERENCES ventas.Factura(idFactura))
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA = 'ventas' AND TABLE_NAME = 'ComprobanteFactura')
BEGIN
	CREATE TABLE ventas.ComprobanteFactura(
	id INT,
	monto DECIMAL(12,2),
	identificadorPago VARCHAR(50),
	idMedioPago INT,
	
	CONSTRAINT FK_ComprobanteFact FOREIGN KEY (id) REFERENCES ventas.Comprobante(id),
	CONSTRAINT PK_ComprobanteFact PRIMARY KEY (id),
	CONSTRAINT FK_MedioDePago FOREIGN KEY (idMedioPago) REFERENCES ventas.MedioDePago(id))
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA = 'ventas' AND TABLE_NAME = 'NotaDeCredito')
BEGIN
	CREATE TABLE ventas.NotaDeCredito(
	id INT,
	credito DECIMAL(12,2),
	tipoProducto VARCHAR(50),
	motivo VARCHAR(50),
	
	CONSTRAINT FK_ComprobanteCred FOREIGN KEY (id) REFERENCES ventas.Comprobante(id),
	CONSTRAINT PK_ComprobanteCred PRIMARY KEY (id))
END
GO

--- RELACION ENTRE FACTURA Y PRODUCTO INCLUIDA TAMBIEN EN SCHEMA 'VENTAS'

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA = 'ventas' AND TABLE_NAME = 'ListaProducto')
BEGIN
	CREATE TABLE ventas.ListaProducto(
	idFactura CHAR(11),
	idProducto INT,
	cantidad INT,
	subtotal DECIMAL(14,2), --nuevo
	
	CONSTRAINT PK_FacturaYProducto PRIMARY KEY (idFactura,idProducto),
	CONSTRAINT UNIQUE_FacturaProductoCantidad UNIQUE (idFactura,idProducto,cantidad),
	CONSTRAINT FK_Factura FOREIGN KEY (idFactura) REFERENCES ventas.Factura(idFactura),
	CONSTRAINT FK_Producto FOREIGN KEY (idProducto) REFERENCES catalogos.Producto(id))
END
GO

/*
use master
*/
