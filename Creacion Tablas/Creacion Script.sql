/* GRUPO 13
BASE DE DATOS APLICADA

ORTEGA MARCO ANTONIO - 44108566

Luego de decidirse por un motor de base de datos relacional, lleg� el momento de generar la
base de datos.
Deber� instalar el DMBS y documentar el proceso. No incluya capturas de pantalla. Detalle
las configuraciones aplicadas (ubicaci�n de archivos, memoria asignada, seguridad, puertos,
etc.) en un documento como el que le entregar�a al DBA.
Cree la base de datos, entidades y relaciones. Incluya restricciones y claves. Deber� entregar
un archivo .sql con el script completo de creaci�n (debe funcionar si se lo ejecuta �tal cual� es
entregado). Incluya comentarios para indicar qu� hace cada m�dulo de c�digo.
Genere store procedures para manejar la inserci�n, modificado, borrado (si corresponde,
tambi�n debe decidir si determinadas entidades solo admitir�n borrado l�gico) de cada tabla.
Los nombres de los store procedures NO deben comenzar con �SP�.
Genere esquemas para organizar de forma l�gica los componentes del sistema y aplique esto
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
	legajo INT PRIMARY KEY,
	nombre VARCHAR(50),
	apellido VARCHAR(50),
	dni INT UNIQUE,
	cuil CHAR (13),
	emailPer VARCHAR(60) UNIQUE,
	emailEmp VARCHAR(60) UNIQUE,
	direccion VARCHAR(100),
	idSucursal INT,
	idTurno INT,
	idCargo INT,
	activo INT DEFAULT 1,

	CONSTRAINT FK_Sucursal FOREIGN KEY (idSucursal) REFERENCES sucursales.Sucursal(id),
	CONSTRAINT FK_Turno FOREIGN KEY (idTurno) REFERENCES recursosHumanos.TurnoTrabajo(id),
	CONSTRAINT FK_Cargo FOREIGN KEY (idCargo) REFERENCES recursosHumanos.CargoTrabajo(id))
END
GO

--- TABLAS PERTENECIENTES AL SCHEMA 'CLIENTES'

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA = 'clientes' AND TABLE_NAME = 'TipoCliente')
BEGIN
	CREATE TABLE clientes.TipoCliente(
	id INT IDENTITY (1,1) PRIMARY KEY,
	tipo CHAR(10) UNIQUE)
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA = 'clientes' AND TABLE_NAME = 'Cliente')
BEGIN
	CREATE TABLE clientes.Cliente(
	id INT IDENTITY (1,1) PRIMARY KEY,
	ciudad VARCHAR(60),
	genero CHAR(10) CHECK(genero IN ('Male','Female')),
	idTipo INT,

	CONSTRAINT FK_Tipo FOREIGN KEY (idTipo) REFERENCES clientes.TipoCliente(id))
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

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA = 'catalogos' AND TABLE_NAME = 'Producto')
BEGIN
	CREATE TABLE catalogos.Producto(
	id INT IDENTITY (1,1) PRIMARY KEY,
	idProducto INT UNIQUE,
	nombre VARCHAR(100),
	precio DECIMAL(9,2),
	precioUSD DECIMAL(9,2),
	precioRef DECIMAL(9,2),
	unidadRef VARCHAR(10),
	fecha SMALLDATETIME,
	proveedor VARCHAR(50),
	cantXUn VARCHAR(20),
	idCategoria INT,

	CONSTRAINT UNIQUE_Producto UNIQUE(idProducto,nombre,precio),
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
	idFactura CHAR(11) PRIMARY KEY NONCLUSTERED,
	idCliente INT,
	legajoEmp INT,
	hora TIME,
	fecha DATE,
	idTipo INT,
	estado char(6) DEFAULT 'Impaga' CHECK(estado IN ('Impaga','Pagada')),

	CONSTRAINT FK_Cliente FOREIGN KEY (idCliente) REFERENCES clientes.Cliente(id),
	CONSTRAINT FK_Empleado FOREIGN KEY (legajoEmp) REFERENCES recursosHumanos.Empleado(legajo),
	CONSTRAINT FK_TipoFactura FOREIGN KEY (idTipo) REFERENCES ventas.TipoFactura(id))
END
GO

--- COMPROBANTE

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA = 'ventas' AND TABLE_NAME = 'TipoComprobante')
BEGIN
	CREATE TABLE ventas.TipoComprobante(
	id INT IDENTITY (1,1) PRIMARY KEY,
	tipo VARCHAR(20) UNIQUE)
END
GO

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
	idTipo INT,
	idFactura CHAR(11),
	idMedioPago INT,

	CONSTRAINT FK_TipoComprobante FOREIGN KEY (idTipo) REFERENCES ventas.TipoComprobante(id),
	CONSTRAINT FK_FacturaAsociada FOREIGN KEY (idFactura) REFERENCES ventas.Factura(idFactura),
	CONSTRAINT FK_MedioDePago FOREIGN KEY (idMedioPago) REFERENCES ventas.MedioDePago(id))
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
	
	CONSTRAINT PK_FacturaYProducto PRIMARY KEY (idFactura,idProducto),
	CONSTRAINT FK_Factura FOREIGN KEY (idFactura) REFERENCES ventas.Factura(idFactura),
	CONSTRAINT FK_Producto FOREIGN KEY (idProducto) REFERENCES catalogos.Producto(id))
END
GO

/*

*/