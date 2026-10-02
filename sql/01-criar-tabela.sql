IF OBJECT_ID('dbo.cadastro', 'U') IS NULL
BEGIN

    CREATE TABLE dbo.cadastro (
        id INT IDENTITY(1,1) PRIMARY KEY,
        nome NVARCHAR(150) NOT NULL,
        cpf VARCHAR(14) NOT NULL,
        telefone VARCHAR(20) NOT NULL
    );

END;
GO