Use Larabox
go
--1) Hacer un reporte utilizando una vista que informe por cada usuario el nombre de usuario,
--	 el tipo de cuenta de todas las suscripciones que registra y cuanto lleva abonado por ellas.

Create View VW_REPORTE_EJERCICIO_1 As
Select U.Nombreusuario, TC.Nombre, 
(Select SUM(Importe) From Pagos Where IDSuscripcion = S.ID) as TotalAbonado 
From Usuarios U
Inner Join Suscripciones S ON S.IDUsuario = U.ID
Inner Join TiposCuenta TC ON TC.ID = S.IDTipoCuenta

Select * From VW_REPORTE_EJERCICIO_1
