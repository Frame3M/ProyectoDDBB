USE MASTER
GO
---

-- CREANDO LOGINS -----------------------
CREATE LOGIN Supervisor
	WITH PASSWORD = '222333',
	CHECK_POLICY = ON

GO

CREATE LOGIN Trabajador
	WITH PASSWORD = '222333',
	CHECK_POLICY = ON
GO
-----------------------------------------

--
USE G13COM5600
GO
--

-- CREANDO USUARIOS-----------------------
CREATE USER Supervisor00 FOR LOGIN Supervisor
GO

CREATE USER Trabajador00 FOR LOGIN Trabajador
GO
------------------------------------------

-- CREANDO ROLES -------------------------
CREATE ROLE Supervisores
GO

CREATE ROLE Trabajadores
GO
------------------------------------------

-- AÑADIENDO USUARIOS AL ROL -------------
ALTER ROLE Supervisores ADD MEMBER Supervisor00

ALTER ROLE Trabajadores ADD MEMBER Trabajador00
------------------------------------------


-- ASIGNAMOS PERMISOS A LOS ROLES --------

-- SUPERVISOR
GRANT EXECUTE ON OBJECT::ventas.AddNotaDeCredito TO Supervisores
GO
GRANT EXECUTE ON OBJECT::encriptacion.verDatEmpleados TO Supervisores
GO

-- TRABAJADOR
GRANT EXECUTE ON OBJECT::ventas.AddFactura TO Trabajadores
GO
GRANT EXECUTE ON OBJECT::ventas.AddProdLista TO Trabajadores
GO
GRANT EXECUTE ON OBJECT::ventas.AddComprobanteFact TO Trabajadores
GO



