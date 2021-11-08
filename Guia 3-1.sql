Use Larabox
go

/*VISTAS Y PROCEDIMIENTOS ALMACENADOS*/

/*1) REPORTE POR CADA NOMBRE DE USUARIO, TODAS LAS SUSCRIPCIONES
     QUE REGISTRA Y EL TOTAL ABONADO POR ELLAS*/

Create View VW_Reporte_1 AS
Select U.Nombreusuario, TC.Nombre, 
isnull((Select SUM(Importe) From Pagos Where IDSuscripcion = S.ID), 0) as TotalPagado
From Usuarios U
Inner Join Suscripciones S On S.IDUsuario = U.ID
Inner Join TiposCuenta TC ON TC.ID = S.IDTipoCuenta
go
Select * From VW_REPORTE_EJERCICIO_1

/*2) MODIFICACION DEL VW_REPORTE_EJERCICIO_1 PARA QUE AGREGUE APELLIDO Y 
     NOMBRE DEL USUARIO Y PARA CADA SUSCRIPCION CUANTOS DIAS LLEVA SUSCRIPTO*/

Alter View VW_REPORTE_EJERCICIO_1 AS
Select DP.Apellidos, DP.Nombres, U.Nombreusuario, TC.Nombre, 
(Select SUM(Importe) From Pagos Where IDSuscripcion = S.ID) as TotalPagado,
DATEDIFF(DAY, S.Inicio, ISNULL(S.Fin, GETDATE())) as DiasSuscriptos
From Usuarios U
Inner Join DatosPersonales DP ON DP.ID = U.ID
Inner Join Suscripciones S On S.IDUsuario = U.ID
Inner Join TiposCuenta TC ON TC.ID = S.IDTipoCuenta

Select * From VW_REPORTE_EJERCICIO_1

/*3) LISTAR TODOS LOS ARCHIVOS CUYO TAMAÑO SEA MAYOR AL TAMAÑO
     PROMEDIO DE LOS ARCHIVOS CON EXTENSION 'XLS'*/

Create View VW_REPORTE_EJERCICIO_2 as
Select A.Nombre From Archivos A
Where (Select AVG(Tamaño) From Archivos Where Extension = 'XLS') < A.Tamaño

/*4) HACER UN REPORTE MEDIANTE UN PROCEDIMEINTO ALMACENADO QUE RECIBA UN IDUSUARIO
	 Y MUESTRE EL APELLIDO Y NOMBRE DEL USUARIO, NOMBRE Y EXTENSION DE ARCHIVO*/
go

CREATE PROCEDURE SP_REPORTE_EJERCICIO_4(@IDUSUARIO BIGINT)
AS
BEGIN 
Select DP.Apellidos, U.Nombreusuario, A.Nombre, A.Extension From DatosPersonales DP
Inner Join Usuarios U ON U.ID = DP.ID
Inner Join Archivos A ON A.IDUsuario = U.ID
Where U.ID = @IDUSUARIO
END

EXEC SP_REPORTE_EJERCICIO_4 2   

/*5) Modificar el reporte (4) para que incluya el tamaño de cada archivo
	 y que porcentaje de la cuota máximo contratada por el usuario corresponde
     dicha cuota sobre el total */

Select * From Archivos
Select * From DatosPersonales
Select * From Suscripciones
Select * From TiposCuenta

ALTER PROCEDURE SP_REPORTE_EJERCICIO_4(@IDUSUARIO BIGINT)
AS
BEGIN 
Select DP.Apellidos, U.Nombreusuario, A.Nombre, A.Extension, TC.Nombre, A.Tamaño/1024 as TamañoMB,
(((A.Tamaño/1024) * 100)/TC.Cuota) as Porcentaje
From DatosPersonales DP
Inner Join Usuarios U ON U.ID = DP.ID
Inner Join Archivos A ON A.IDUsuario = U.ID
Inner Join Suscripciones S ON S.IDUsuario = U.ID
Inner Join TiposCuenta TC ON TC.ID = S.IDTipoCuenta
Where U.ID = @IDUSUARIO
END

Exec SP_REPORTE_EJERCICIO_4 2

/*6) Hacer un procedimiento almacenado que se llamado TiposCuenta_InsertaroModificar que reciba el ID,
	 el nombre, la cuota y el costo. Si el ID recibido es 0, debe insertar el nuevo regustro. 
	 Si el ID recibido es distinto a cero debe modificarlo. En ningún caso debe permitir que haya
	 más de un tipo de cuenta con la misma cuota.*/
go

ALTER PROCEDURE TiposCuenta_InsertaroModificar(@ID BIGINT, @NOMBRE VARCHAR(150), @CUOTA INT, @COSTO MONEY)
AS
BEGIN 
	BEGIN TRY
	    IF(@CUOTA <> ALL(Select Cuota From TiposCuenta))BEGIN
			IF(@ID = 0) BEGIN
				INSERT INTO TiposCuenta(Nombre, Cuota, Costo) VALUES(@NOMBRE, @CUOTA, @COSTO)
			END
			ELSE BEGIN
				UPDATE TiposCuenta SET Nombre = @NOMBRE, Cuota = @CUOTA, Costo = @COSTO WHERE ID = @ID
			END
		END
		ELSE BEGIN
			RAISERROR('NO SE PUDO AGREGAR O MODIFICAR EL REGISTRO', 16, 10)
		END
	END TRY
	BEGIN CATCH
		RAISERROR('NO SE PUDO AGREGAR O MODIFICAR EL REGISTRO', 16, 10)
	END CATCH
END

EXEC TiposCuenta_InsertaroModificar 0, Avenger, 50000, 650
EXEC TiposCuenta_InsertaroModificar 4, Avenger, 50000, -650

Select * From TiposCuenta
EXEC TiposCuenta_InsertaroModificar 0, Prueba, 500, 650

/*8) Hacer un procedimiento almacenado llamado SuscribirUsuario que reciba el IDUsuario 
	 y el ID del tipo de cuenta a suscribir. El procedimiento debe finalizar una suscripcion 
	 anterior (si corresponde) con la fecha del sistema, la cual será tambien la misma para
	 la fecha de inicio de la nueva suscripcion.*/

Select * From Suscripciones
GO

ALTER Procedure SuscribirUsuario(@IDUSUARIO INT, @IDTIPOCUENTA INT) AS
BEGIN
	BEGIN TRY
		IF((Select Fin From Suscripciones Where IDUsuario = @IDUSUARIO AND Fin is NULL) is NULL) BEGIN
			UPDATE Suscripciones SET Fin = GETDATE() WHERE IDUsuario = @IDUSUARIO AND Fin is NULL
			INSERT INTO Suscripciones(IDUsuario, IDTipoCuenta, Inicio) VALUES(@IDUSUARIO, @IDTIPOCUENTA, GETDATE())
		END
		ELSE BEGIN
			INSERT INTO Suscripciones(IDUsuario, IDTipoCuenta, Inicio) VALUES(@IDUSUARIO, @IDTIPOCUENTA, GETDATE())
		END
	END TRY	
	BEGIN CATCH
		RAISERROR('NO SE PUDO AGREGAR LA SUSCRIPCION', 16, 10)
	END CATCH
END

Select * From Suscripciones
Exec SuscribirUsuario 1, 4

Delete From Suscripciones Where ID=29

/*7) Hacer un procedimiento almacenado llamado SubirArchivo que reciba los parametros 
     necesarios para agregar un nuevo archivo. Solo podra registrarse si el
	 usuario dispone de cuota suficiente para registrar ese archivo junto con
	 sus archivos actuales. */

select * from archivos
go

Create View VW_Cuota_Disponible AS
Select A.IDUsuario, TC.Cuota, (SUM(A.Tamaño)/1024) as EspacioUtilizadoMB From Archivos A
Inner Join Suscripciones S ON S.IDUsuario = A.IDUsuario
Inner Join TiposCuenta TC ON S.IDTipoCuenta = TC.ID
Where S.Fin is Null
Group By A.IDUsuario, TC.Cuota


Alter Procedure SubirArchivo(@IDUSUARIO INT, @NOMBRE VARCHAR(100), @EXTENSION VARCHAR(8), @TAMAÑO BIGINT) AS
BEGIN
	BEGIN TRY
		IF((Select (Cuota-EspacioUtilizadoMB) as Disponible From VW_Cuota_Disponible Where IDUsuario = @IDUSUARIO)>=0)BEGIN
			Insert Into Archivos(IDUsuario, Nombre, Extension, Tamaño, Creacion, Modificacion, Estado) 
			VALUES(@IDUSUARIO, @NOMBRE, @EXTENSION, @TAMAÑO, getDate(), getDate(), 1)
		END
		ELSE BEGIN
			RAISERROR('NO SE PUDO AGREGAR EL ARCHIVO, ESPACIO INSUFICIENTE', 16, 10)
		END
	END TRY	
	BEGIN CATCH
		RAISERROR('NO SE PUDO AGREGAR EL ARCHIVO', 16, 10)
	END CATCH
END

Select * From VW_Cuota_Disponible
Select * From Archivos
EXEC SubirArchivo 1, 'Archivo de Prueba', 'jpeg', 500 



