Use ModeloParcial2
go
/*
1)
Hacer un trigger que al cargar un crédito verifique que el importe del mismo 
sumado a los importes de los créditos que 
actualmente solicitó esa persona no supere al triple de la declaración de ganancias. 
Sólo deben tenerse en cuenta en la sumatoria los créditos que no se encuentren cancelados. 
De no poder otorgar el crédito aclararlo con un mensaje.

*/
Drop Trigger TR_Nuevo_Credito
go

--CON INSTEAD OF
Create Trigger TR_Nuevo_Credito ON Creditos
instead of insert --CUANDO ES INSTEAD OF, SE VA A EJECUTAR PRIMERO LO QUE ESTA DENTRO DEL TRIGGER Y NO SE VA A EJECUTAR LA ACCION
as
begin
	declare @IDBanco bigint
	declare @DNI varchar(10)
	declare @Fecha date
	declare @Plazo smallint
    declare @Importe money
	declare @DeclaracionGanancias money
	declare @SumatoriaCreditos money
    declare @Cancelado bit
    
    Select @IDBanco = IDBanco, @DNI = DNI, @Fecha = Fecha, @Plazo = Plazo, @Importe = Importe, @Cancelado = Cancelado from inserted
	Select @DeclaracionGanancias = DeclaracionGanancias From Personas Where DNI = @DNI
	Select @SumatoriaCreditos = isnull(Sum(Importe), 0) from Creditos where DNI = @DNI And Cancelado = 0
	--EL ISNULL ES POR SI ES LA PRIMERA VEZ QUE REALIZA UN CREDITO

    if ( @SumatoriaCreditos+@Importe < 3*@DeclaracionGanancias) 
	begin 
        Insert into Creditos(IDBanco, DNI, Fecha, Importe, Plazo, Cancelado)
	    Values (@IDBanco, @DNI, @Fecha, @Importe, @Plazo, @Cancelado)   
    end
    else begin
    RAISERROR('No se puede otorgar el credito', 16, 1)
    end
end


Insert into Creditos(IDBanco, DNI, Fecha, Importe, Plazo, Cancelado)
Values (1, '4444', GETDATE(), 50000, 10, 0)

--CON AFTER
Create Trigger TR_Nuevo_Credito ON Creditos
After Insert
Begin
	Begin Try

	End Try
	Begin Catch

	End Catch

End

Select * From Creditos
go

/*
2)
Hacer un trigger que al eliminar un crédito realice la cancelación del mismo
*/

Create Trigger TR_Eliminar_Credito ON Creditos
instead of delete
as
begin
	declare @ID bigint
    declare @Cancelado bit
    
    Select @ID = ID, @Cancelado = Cancelado from deleted

    if (@Cancelado = 0) 
	begin 
        Update Creditos Set Cancelado = 1 Where ID = @ID   
    end
    else begin
    RAISERROR('El crédito ya fue eliminado', 16, 1)
    end
end

Select * From Creditos

Delete From Creditos Where ID = 6

/*
3)
Hacer un trigger que no permita otorgar créditos con un plazo de 20 o más 
años a personas cuya declaración de ganancias sea menor al promedio 
de declaración de ganancias.
*/
Drop Trigger TR_Nuevo_Credito
go

Create Trigger TR_Nuevo_Credito ON Creditos
instead of insert
as
begin

	declare @DNI varchar(10)
	declare @Plazo smallint
	declare @DeclaracionGanancias money
	declare @PromedioGanancias money
    
    Select  @DNI = DNI, @Plazo = Plazo from inserted
	Select @DeclaracionGanancias = DeclaracionGanancias From Personas Where DNI = @DNI
    
	if(@Plazo >= 20) begin
	     Select @PromedioGanancias = isnull(AVG(DeclaracionGanancias), 0) from Personas

		 if (@PromedioGanancias >= @DeclaracionGanancias) 
		 begin 
         Insert into Creditos(IDBanco, DNI, Fecha, Importe, Plazo, Cancelado)
	     Select IDBanco, DNI, Fecha, Importe, Plazo, Cancelado From Inserted
		 end
		 else begin
		 RAISERROR('No se puede otorgar el credito, la Declaración de Ganancias del usuario es menor al Promedio', 16, 1)
		 end
    end
    else begin
    Insert into Creditos(IDBanco, DNI, Fecha, Importe, Plazo, Cancelado)
	Select IDBanco, DNI, Fecha, Importe, Plazo, Cancelado From Inserted
    end
end

Insert into Creditos(IDBanco, DNI, Fecha, Importe, Plazo, Cancelado)
Values (1, '1111', getdate(), 500000000000, 100, 0)

Select AVG(DeclaracionGanancias) from Personas

/*
4)
Hacer un procedimiento almacenado que reciba dos fechas y liste todos los créditos 
otorgados entre esas fechas. Debe listar el apellido y nombre del solicitante, 
el nombre del banco, el tipo de banco, la fecha del crédito y el importe solicitado.
*/
go
Create Procedure SP_Punto_4(
@Inicio date,
@Fin date
)
as
begin 
	Select P.Apellidos, P.Nombres, B.Nombre, B.Tipo, C.Fecha, C.Importe
	From Personas P
	Inner Join Creditos C ON P.DNI = C.DNI
	Inner Join Bancos B ON B.ID = C.IDBanco
	Where C.Fecha Between @Inicio and @Fin
end

Set DateFormat 'DMY'
Exec SP_Punto_4 '05/01/2021', '25/01/2021'