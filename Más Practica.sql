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

CREATE PROCEDURE SP_REPORTE_EJERCICIO_4(@IDUSUARIO BIGINT)
AS
BEGIN 
Select DP.Apellidos, U.Nombreusuario, A.Nombre, A.Extension From DatosPersonales DP
Inner Join Usuarios U ON U.ID = DP.ID
Inner Join Archivos A ON A.IDUsuario = U.ID
Where U.ID = @IDUSUARIO
END





