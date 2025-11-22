CREATE TABLE dbo.Dim_Cliente (
    ClienteSK INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    ClienteID_Origen INT NOT NULL,
    AnioNacimiento INT,
    Educacion VARCHAR(100),
    EstadoCivil VARCHAR(100),
    Ingreso DECIMAL(18,2),
    FlagQueja INT NOT NULL DEFAULT 0,
    FechaAlta DATE
);
CREATE NONCLUSTERED INDEX IX_Dim_Cliente_BK ON dbo.Dim_Cliente(ClienteID_Origen);

CREATE TABLE dbo.Dim_Fecha (
    FechaSK INT NOT NULL PRIMARY KEY,
    FechaCompleta DATE NOT NULL,
    Anio INT NOT NULL,
    Trimestre INT NOT NULL,
    Mes INT NOT NULL,
    NombreMes VARCHAR(50) NOT NULL,
    DiaDeSemana VARCHAR(50) NOT NULL
);
GO

DECLARE @StartDate DATE = '20100101';
DECLARE @EndDate DATE = '20251231';

SET LANGUAGE Spanish;

WITH DateSequence AS (
    SELECT @StartDate AS Fecha
    UNION ALL
    SELECT DATEADD(DAY, 1, Fecha)
    FROM DateSequence
    WHERE Fecha < @EndDate
)
INSERT INTO dbo.Dim_Fecha (
    FechaSK,
    FechaCompleta,
    Anio,
    Trimestre,
    Mes,
    NombreMes,
    DiaDeSemana
)
SELECT
    ROW_NUMBER() OVER(ORDER BY Fecha) AS FechaSK,
    Fecha AS FechaCompleta,
    YEAR(Fecha) AS Anio,
    DATEPART(QUARTER, Fecha) AS Trimestre,
    MONTH(Fecha) AS Mes,
    DATENAME(MONTH, Fecha) AS NombreMes,
    DATENAME(WEEKDAY, Fecha) AS DiaDeSemana
FROM DateSequence
OPTION (MAXRECURSION 0);
GO

CREATE TABLE dbo.Dim_CategoriaProducto (
    CategoriaProductoSK INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    NombreCategoria VARCHAR(100) NOT NULL
);

CREATE TABLE dbo.Dim_CanalCompra (
    CanalCompraSK INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    NombreCanal VARCHAR(100) NOT NULL
);

CREATE TABLE dbo.Dim_Campana (
    CampanaSK INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    NombreCampana VARCHAR(100) NOT NULL,
    CostoCampana DECIMAL(18,2) NOT NULL DEFAULT 0
);

CREATE TABLE dbo.Fact_Gasto (
    FactGastoSK INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    ClienteSK INT NOT NULL,
    FechaGastoSK INT NOT NULL,
    CategoriaProductoSK INT NOT NULL,
    Monto DECIMAL(18,2) NOT NULL,

    CONSTRAINT FK_Fact_Gasto_Dim_Cliente FOREIGN KEY (ClienteSK) REFERENCES dbo.Dim_Cliente(ClienteSK),
    CONSTRAINT FK_Fact_Gasto_Dim_Fecha FOREIGN KEY (FechaGastoSK) REFERENCES dbo.Dim_Fecha(FechaSK),
    CONSTRAINT FK_Fact_Gasto_Dim_CategoriaProducto FOREIGN KEY (CategoriaProductoSK) REFERENCES dbo.Dim_CategoriaProducto(CategoriaProductoSK)
);

CREATE TABLE dbo.Fact_Compras (
    FactComprasSK INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    ClienteSK INT NOT NULL,
    FechaCompraSK INT NOT NULL,
    CanalCompraSK INT NOT NULL,
    NumeroDeCompras INT NOT NULL,

    CONSTRAINT FK_Fact_Compras_Dim_Cliente FOREIGN KEY (ClienteSK) REFERENCES dbo.Dim_Cliente(ClienteSK),
    CONSTRAINT FK_Fact_Compras_Dim_Fecha FOREIGN KEY (FechaCompraSK) REFERENCES dbo.Dim_Fecha(FechaSK),
    CONSTRAINT FK_Fact_Compras_Dim_CanalCompra FOREIGN KEY (CanalCompraSK) REFERENCES dbo.Dim_CanalCompra(CanalCompraSK)
);

CREATE TABLE dbo.Fact_RespuestasCampana (
    FactRespuestasSK INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    ClienteSK INT NOT NULL,
    FechaRespuestaSK INT NOT NULL,
    CampanaSK INT NOT NULL,
    Respuesta INT NOT NULL,

    CONSTRAINT FK_Fact_Respuestas_Dim_Cliente FOREIGN KEY (ClienteSK) REFERENCES dbo.Dim_Cliente(ClienteSK),
    CONSTRAINT FK_Fact_Respuestas_Dim_Fecha FOREIGN KEY (FechaRespuestaSK) REFERENCES dbo.Dim_Fecha(FechaSK),
    CONSTRAINT FK_Fact_Respuestas_Dim_Campana FOREIGN KEY (CampanaSK) REFERENCES dbo.Dim_Campana(CampanaSK)
);