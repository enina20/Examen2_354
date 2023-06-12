USE master;
GO
DROP TABLE IF EXISTS nombre;
DROP TABLE IF EXISTS suma;

DECLARE @cadena1 VARCHAR(20),
		@cadena2 VARCHAR(20),
		@longitud_cadena1 INT,
		@letra VARCHAR(1),
		@sql NVARCHAR(MAX),
		@contador INT,
		@variable INT,
		@var varchar(2),
		@i INT;

-- Asignar las cadenas de texto a comparar
SET @cadena1 = 'Edson';
SET @cadena2 = 'Edson';

-- Obtener la longitud de la cadena más larga
SET @longitud_cadena1 = CASE WHEN LEN(@cadena1) >= LEN(@cadena2) THEN LEN(@cadena1) ELSE LEN(@cadena2) END;

-- Crear tabla con columnas basadas en las letras de la cadena más larga
SET @sql = 'CREATE TABLE nombre (';
SET @contador = 1;
WHILE @contador <= @longitud_cadena1
BEGIN
	SET @letra = CASE WHEN @contador <= LEN(@cadena1) THEN SUBSTRING(@cadena1, @contador, 1) ELSE SUBSTRING(@cadena2, @contador, 1) END;
	SET @sql += QUOTENAME(@letra + CAST(@contador AS VARCHAR)) + ' INT,';
	SET @contador += 1;
END;
SET @sql = LEFT(@sql, LEN(@sql) - 1) + ')';
EXEC sp_executesql @sql;

-- Insertar valores en la tabla basados en las letras de la otra cadena
SET @contador = 1;
WHILE @contador <= LEN(@cadena2)
BEGIN
	SET @letra = SUBSTRING(@cadena2, @contador, 1);
	SET @sql = 'INSERT INTO nombre (' + QUOTENAME(@letra + CAST(@contador AS VARCHAR)) + ') VALUES (1)';
	EXEC sp_executesql @sql;
	SET @contador += 1;
END;

-- Contador de la cantidad de columnas
CREATE TABLE suma (datos INT);
set @variable=(select count(column_name) 
				from information_schema.columns
				where table_name='nombre');
SET @i = 1;
WHILE @i <= @variable
BEGIN
	set @var =(select column_name from INFORMATION_SCHEMA.COLUMNS where table_name='nombre' and ORDINAL_POSITION=@i); 

	SET @sql = 'SELECT cast(sum('+@var+') as int) FROM nombre';
	INSERT INTO suma (datos) EXEC sp_executesql @sql;
	SET @i += 1;
END;

-- Comparación de cadenas
IF EXISTS (SELECT * FROM suma WHERE datos IS NULL)
	PRINT 'No son iguales.';
ELSE
	PRINT 'Son iguales.';