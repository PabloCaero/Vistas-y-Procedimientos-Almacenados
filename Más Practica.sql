Use Larabox
go

/*VISTAS Y PROCEDIMIENTOS ALMACENADOS*/

/*1) REPORTE POR CADA NOMBRE DE USUARIO, TODAS LAS SUSCRIPCIONES QUE REGISTRA Y EL TOTAL ABONADO POR ELLAS*/
Create View VW_Reporte_1 AS
Select U.Nombreusuario, TC.Nombre, 
isnull((Select SUM(Importe) From Pagos Where IDSuscripcion = S.ID), 0) as TotalPagado
From Usuarios U
Inner Join Suscripciones S On S.IDUsuario = U.ID
Inner Join TiposCuenta TC ON TC.ID = S.IDTipoCuenta

Select * From VW_REPORTE_EJERCICIO_1

/*2) MODIFICACION DEL VW_REPORTE_EJERCICIO_1 PARA QUE AGREGUE APELLIDO Y NOMBRE DEL USUARIO Y PARA CADA SUSCRIPCION CUANTOS DIAS LLEVA SUSCRIPTO*/
Alter View VW_Reporte_1 AS
Select DP.Apellidos, DP.Nombres, U.Nombreusuario, TC.Nombre, 
isnull((Select SUM(Importe) From Pagos Where IDSuscripcion = S.ID), 0) as TotalPagado
From Usuarios U
Inner Join DatosPersonales DP ON DP.ID = U.ID
Inner Join Suscripciones S On S.IDUsuario = U.ID
Inner Join TiposCuenta TC ON TC.ID = S.IDTipoCuenta

Select * From Usuarios