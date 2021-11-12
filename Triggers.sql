--A)
CREATE TRIGGER TR_NUEVOPRESTAMO ON PRESTAMOS
INSTEAD OF INSERT
AS
BEGIN
	BEGIN TRY
		DECLARE @IDSOCIO BIGINT
		DECLARE @BANDERA BIT
		SET @BANDERA = 1

		SELECT @IDSOCIO = IDSOCIO FROM INSERTED

		SELECT @CANTIDAD = COUNT(*) FROM PRESTAMOS
		WHERE FDEVOLUCION IS NULL AND IDSOCIO = @IDSOCIO

		IF @CANTIDAD = 0
		BEGIN
			INSERT INTO PRESTAMOS(IDSOCIO, IDLIBRO, FPRESTAMO, FDEVOLUCION, COSTO)
			SELECT IDSOCIO, IDLIBRO, FPRESTAMO FROM INSERTED
		END
		ELSE
		BEGIN
			RAISERROR('EL SOCIO AUN NO DEVOLVIO EL LIBRO', 16, 10)
		END
	END TRY
	BEGIN CATCH

	END CATCH



END



--B)
CREATE PROCEDURE PR_PRESTAMOSORDENADOS(@IDSOCIO BIGINT) AS
BEGIN
	BEGIN TRY
		--¿Ordenado por Fecha de Prestamo o Fecha de Devolucion?
		Select L.Titulo, P.FPrestamo From Prestamos P
		Inner Join Libros L ON L.ID = P.IDLibro
		Where P.IDSocio = @IDSOCIO and P.FDevolucion is not NULL
		Order By P.FPrestamo Desc

	END TRY
	BEGIN CATCH
		RAISERROR('OCURRIO UN ERROR', 16, 1)
	END CATCH
END

--C)
GO
CREATE PROCEDURE Devolver_Libro(@IDLibro BIGINT, @FDevolucion DATE) AS
BEGIN	
	Declare @Costo MONEY
	Declare @Dias INT
	
	--VERIFICAR SI EL LIBRO ESTABA PRESTADO
	IF((SELECT COUNT(*) FROM PRESTAMOS WHERE IDLIBRO= @IDLibro and FDEVOLUCION IS NULL)=1) BEGIN

		Select @DIAS = DATEDIFF(DAY, FPrestamo, FDevolucion) as Dias From Prestamos 
		Where IDLibro = @IDLibro AND FDEVOLUCION IS NULL

		Select @Costo = Precio From Libros Where ID=@IDLibro

		IF(@Dias >= 7) BEGIN
			Set @Costo = @Costo*0.2
		END
		ELSE BEGIN
			Set @Costo = @Costo*0.1
		END

		UPDATE Prestamos SET Costo = @Costo, FDevolucion = @FDevolucion 
		WHERE IDLibro = @IDLibro AND FDevolucion IS NULL

	END
	ELSE BEGIN
		RAISERROR('EL LIBRO ESTA PRESTADO', 16, 1)
	END
END

--D)
Select Distinct S.* From Socios S
Inner Join Prestamos P ON P.IDSocio = S.ID
Inner Join Libros L ON L.ID = P.IDLibro
Where L.Bestseller = 1

