-- ============================================================
-- create-tables.sql
-- Azure SQL Database — schema for Azure Data Integration project
-- ============================================================

-- Schemas
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'stg')  EXEC('CREATE SCHEMA stg');
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'etl')  EXEC('CREATE SCHEMA etl');
GO

-- Staging tables
CREATE TABLE stg.Properties (
    PropertyID      NVARCHAR(50),
    PropertyName    NVARCHAR(200),
    Town            NVARCHAR(100),
    PostCode        NVARCHAR(20),
    PropertyType    NVARCHAR(50),
    Bedrooms        NVARCHAR(10),
    IsVoid          NVARCHAR(10),
    SourceFile      NVARCHAR(500),
    LoadDate        DATETIME2 DEFAULT GETDATE(),
    BatchID         NVARCHAR(100)
);

CREATE TABLE stg.Rent (
    PropertyID      NVARCHAR(50),
    TenantID        NVARCHAR(50),
    RentAmount      NVARCHAR(30),
    RentDate        NVARCHAR(30),
    PaymentMethod   NVARCHAR(50),
    SourceFile      NVARCHAR(500),
    LoadDate        DATETIME2 DEFAULT GETDATE(),
    BatchID         NVARCHAR(100)
);

-- Production tables
CREATE TABLE dbo.Properties (
    PropertyID      INT           PRIMARY KEY,
    PropertyName    NVARCHAR(200) NOT NULL,
    Town            NVARCHAR(100),
    PostCode        NVARCHAR(20),
    PropertyType    NVARCHAR(50),
    Bedrooms        TINYINT,
    IsVoid          BIT           DEFAULT 0,
    LoadDate        DATETIME2     DEFAULT GETDATE()
);

CREATE TABLE dbo.Rent (
    RentID          INT           IDENTITY(1,1) PRIMARY KEY,
    PropertyID      INT           NOT NULL REFERENCES dbo.Properties(PropertyID),
    TenantID        INT,
    RentAmount      DECIMAL(10,2) NOT NULL,
    RentDate        DATE          NOT NULL,
    PaymentMethod   NVARCHAR(50),
    LoadDate        DATETIME2     DEFAULT GETDATE(),
    BatchID         NVARCHAR(100)
);

CREATE INDEX IX_Rent_PropertyID ON dbo.Rent (PropertyID);
CREATE INDEX IX_Rent_RentDate   ON dbo.Rent (RentDate);
GO
