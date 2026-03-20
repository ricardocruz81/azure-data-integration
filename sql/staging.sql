-- ============================================================
-- staging.sql
-- Validate staging data and promote to production
-- ============================================================
CREATE OR ALTER PROCEDURE etl.usp_ValidateAndLoadRent
    @BatchID NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    -- Insert valid rows into production
    INSERT INTO dbo.Rent (PropertyID, TenantID, RentAmount, RentDate, PaymentMethod, BatchID)
    SELECT
        TRY_CAST(PropertyID   AS INT),
        TRY_CAST(TenantID     AS INT),
        TRY_CAST(RentAmount   AS DECIMAL(10,2)),
        TRY_CAST(RentDate     AS DATE),
        PaymentMethod,
        BatchID
    FROM stg.Rent
    WHERE BatchID = @BatchID
      AND TRY_CAST(PropertyID  AS INT)          IS NOT NULL
      AND TRY_CAST(RentAmount  AS DECIMAL(10,2)) IS NOT NULL
      AND TRY_CAST(RentDate    AS DATE)          IS NOT NULL
      AND TRY_CAST(RentAmount  AS DECIMAL(10,2)) > 0;

    PRINT 'Rows loaded: ' + CAST(@@ROWCOUNT AS NVARCHAR);
END;
GO

-- ============================================================
-- views.sql
-- ============================================================
CREATE OR ALTER VIEW dbo.vw_RentSummary AS
SELECT
    p.PropertyID,
    p.PropertyName,
    p.Town,
    YEAR(r.RentDate)         AS RentYear,
    SUM(r.RentAmount)        AS AnnualIncome,
    AVG(r.RentAmount)        AS AvgMonthlyRent,
    MAX(r.RentAmount)        AS CurrentRent,
    COUNT(r.RentID)          AS PaymentsCount
FROM dbo.Properties p
INNER JOIN dbo.Rent r ON p.PropertyID = r.PropertyID
GROUP BY p.PropertyID, p.PropertyName, p.Town, YEAR(r.RentDate);
GO

CREATE OR ALTER VIEW dbo.vw_LatestBatchStatus AS
SELECT
    BatchID,
    MIN(LoadDate)  AS BatchStarted,
    MAX(LoadDate)  AS BatchCompleted,
    COUNT(*)       AS RowsLoaded
FROM dbo.Rent
GROUP BY BatchID;
GO
