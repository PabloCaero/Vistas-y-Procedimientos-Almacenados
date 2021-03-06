Use Larabox
go
/*VISTAS*/
--OBTENER UN LISTADO DE USUARIOS QUE INDIQUE
--SU APELLIDO Y NOMBRE Y CANTIDAD DE ARCHIVOS QUE TIENE
CREATE VIEW VW_LISTADOUSUARIOS AS
SELECT DAT.Apellidos, DAT.Nombres,
(Select COUNT(ID) From Archivos WHERE IDUsuario = DAT.ID) as CantidadArchivos 
FROM DatosPersonales DAT

ALTER VIEW VW_LISTADOUSUARIOS AS
SELECT DAT.Apellidos, DAT.Nombres, DAT.Telefono,
(Select COUNT(ID) From Archivos WHERE IDUsuario = DAT.ID) as CantidadArchivos 
FROM DatosPersonales DAT

SELECT * FROM VW_LISTADOUSUARIOS 

DROP VIEW VW_LISTADOUSUARIOS

/*VARIABLES*/
--ASI SE DECLARAN

SET @NOMBRE = 'PABLO'
SET @EDAD = 27
--MUESTRA LAS VARIABLES COMO UN MENSAJE
PRINT @NOMBRE
PRINT @EDAD
--MUESTRA VARIABLES COMO UNA TABLA
SELECT @NOMBRE AS NOMBRE, @EDAD AS EDAD

--EJEMPLO
/*PREGUNTAR POR QUE MUESTRA SOLO UNA VARIABLE*/

Use Larabox
DECLARE @NOMBRE VARCHAR(30)
DECLARE @EDAD INT
DECLARE @APELLIDO VARCHAR(30)
DECLARE @TELEFONO VARCHAR(30)
DECLARE @CANTARCHIVOS INT
SELECT @NOMBRE = Nombres, @APELLIDO = Apellidos, @CANTARCHIVOS = CantidadArchivos, @TELEFONO = Telefono FROM VW_LISTADOUSUARIOS

SELECT @NOMBRE, @EDAD, @APELLIDO, @TELEFONO, @CANTARCHIVOS 

--EJEMPLO DE DECISION SIMPLE
DECLARE @ORDER BIT /*ALMACENA T O F*/
SET @ORDER = 0
IF @ORDER = 1 BEGIN /*COMIENZA EL LADO VERDADERO CON BEGIN*/
      SELECT * FROM DatosPersonales ORDER BY Apellidos ASC
END /*FINALIZA EL LADO VERDADERO*/
ELSE BEGIN /*COMIENZA EL LADO FALSO*/
      SELECT * FROM DatosPersonales ORDER BY Apellidos DESC
END /*FINALIZA EL LADO FALSO*/

--FUNCIONES GLOBALES (VARIABLES GLOBALES)
--@@ROWCOUNT, @@ERROR, @@IDENTITY
/*@@ROWCOUNT: SE ENCARGA DE DEVOLVER LA CANTIDAD DE FILAS QUE FUERON AFECTADAS POR LA CONSULTA ANTERIOR*/
SELECT * FROM DatosPersonales
SELECT @@ROWCOUNT

/*@@IDENTITY: SE ENCARGA DE OBETENER EL ULTIMO ID AUTOGENERADO POR LA BASE DE DATOS*/
INSERT INTO FormasPago(NOMBRE)VALUES ('MONEDERO UALA')
SELECT @@IDENTITY

SELECT * FROM FormasPago

/*@@ERROR: SE ENCARGA DE MOSTRAR EL CODIGO DE ERROR GENERADO EN LA CONSULTA ANTERIOR*/
INSERT INTO FormasPago(NOMBRE) VALUES('MERCADOPAGO000000000000000000000000000000000000000000000000000000000000000000000000000000' 5)

SELECT @@ERROR

Select * From FormasPago

/*BLOQUE TRY-CATCH*/

BEGIN TRY
 DECLARE @VAL INT
 SET @VAL = 1/0
END TRY
BEGIN CATCH
 PRINT ERROR_MESSAGE()
 RAISERROR('ERROR AL DIVIDIR, NO SE PUEDE DIVIDIR POR CERO', 16, 10) WITH LOG /*MUESTRA EL LOG DEL ERROR EN LA CARPETA DE LA BASE DE DATOS*/
END CATCH

/*PROCEDIMIENTOS ALMACENADOS*/
CREATE PROCEDURE SP_OBTENER_DATOS_USUARIOS
AS
BEGIN 
SELECT * FROM DatosPersonales
END

EXEC SP_OBTENER_DATOS_USUARIOS

DROP PROCEDURE SP_OBTENER_DATOS_USUARIOS
/*CREAR PROCEDIMIENTO*/
CREATE PROCEDURE SP_AGREGAR_FORMA_PAGO(@NOMBRE VARCHAR(30)) AS
BEGIN
	INSERT INTO FormasPago(Nombre) VALUES(@NOMBRE)
END

EXEC SP_AGREGAR_FORMA_PAGO 'ETHERIUM'

SELECT * FROM FormasPago

/*MODIFICAR PROCEDIMIENTO*/
ALTER PROCEDURE SP_AGREGAR_FORMA_PAGO(@NOMBRE VARCHAR(30)) AS
BEGIN
	IF @NOMBRE = 'MERCADOPAGO' BEGIN
		RAISERROR('MERCADOPAGO YA FUE AGREGADO', 16, 1)
	END
	ELSE BEGIN
        INSERT INTO FormasPago(Nombre) VALUES(@NOMBRE)
	END
END

EXEC SP_AGREGAR_FORMA_PAGO 'MERCADOPAGO'


/*TRANSACCIONES*/



/*TRIGGER*/
--ANTE UN EVENTO SE EJECTUA DE MANERA DESATENDIDA - EJEMPLO EJERCICIO 1
/*
Tabla: Suscripci?n
Accion: Insert
Tipo Trigger: Indistinto
*/

Use Larabox
go
ALTER TRIGGER TR_NUEVA_SUSCRIPCION ON Suscripciones
Instead of Insert /*SI DENTRO DEL TRIGGER ESCRIBO UNA CONSULTA DE ACCION, NO SE VUELVE A DISPARAR. SOLO EN ESTE TIPO DE TRIGGER*/
As
Begin
	Declare @IDUsuario BIGINT
	Declare @IDTipoCuenta BIGINT
	Declare @IDTipoCuentaVigente BIGINT
	Declare @TipoCuentaRepetido BIT
	Select @IDUsuario = IDUsuario, @IDTipoCuenta = IDTipoCuenta From inserted
	Set @TipoCuentaRepetido = 0

	if (select count(*) from Suscripciones Where IDUsuario = @IDUsuario and Fin is null) > 0 begin
	Select @IDTipoCuentaVigente = @IDTipoCuenta From Suscripciones
	Where IDUsuario = @IDUsuario and Fin is Null

		if @IDTipoCuenta = @IDTipoCuentaVigente begin
		Set @TipoCuentaRepetido = 1
		RAISERROR('NO PUEDE SER EL MISMO TIPO DE CUENTA', 16, 1)
		End

	End

	If @TipoCuentaRepetido = 0 Begin
	Insert Into Suscripciones(IDUsuario, IDTipoCuenta, Inicio, Fin)
	Select IDUsuario, IDTipoCuenta, Inicio, Fin From Inserted
	End

End

Delete From Suscripciones Where ID = 29


Insert Into Suscripciones(IDUsuario, IDTipoCuenta, Inicio, Fin)
Values(1, 3, GetDate(), Null)

Select * From Suscripciones

/*PREGUNTA DE FINAL*/
/*LA CLAVE FORANEA DEFIENDE LA INTEGRIDAD REFERENCIAL*/
Use Larabox
Go
Create Trigger TR_Borrar_Suscripcion ON Suscripciones
Instead Of Delete /*NO BORRA EL REGISTRO, QUEDA EN LA TABLA TEMPORAL*/
as
Begin
	Begin Try
		Begin Transaction

		Declare @IDSuscripcion BIGINT
		Select @IDSuscripcion = ID From Deleted
		--Borrar los pagos de esa suscripcion
		Delete From Pagos Where IDSuscripcion = @IDSuscripcion
		--Borrar la suscripcion
		Delete From Suscripciones Where ID = @IDSuscripcion

		Commit Transaction
	End Try
	Begin Catch
		Rollback Transaction /*ABORTA TODO, ALGO FALL?. VUELVE LA BDD A UN ESTADO CONSISTENTE*/

	End Catch
End

Select * From Suscripciones S
Inner Join Pagos P ON P.IDSuscripcion = S.ID
Where S.ID = 2

Delete From Suscripciones Where ID = 2

Select * From Suscripciones Where ID = 2
Select * From Pagos Where IDSuscripcion = 2