# Azure Data Integration Mini Project

A cloud-based ETL pipeline using Azure Data Factory to ingest CSV files from Azure Blob Storage, apply transformations, and load into Azure SQL Database — with scheduled pipeline execution and monitoring.

---

## Architecture

```
┌────────────────────┐
│   CSV Source Files │
│   (Local / SFTP)   │
└────────┬───────────┘
         │  Upload
         ▼
┌────────────────────┐
│  Azure Blob        │
│  Storage           │
│  Container: raw    │
└────────┬───────────┘
         │  ADF Trigger (scheduled / event)
         ▼
┌────────────────────────────────────┐
│   Azure Data Factory               │
│                                    │
│  ┌──────────────────────────────┐  │
│  │ Pipeline: IngestRentData     │  │
│  │  1. Copy Activity (CSV→SQL)  │  │
│  │  2. Data Flow (Transform)    │  │
│  │  3. Stored Proc (Validate)   │  │
│  └──────────────────────────────┘  │
└────────┬───────────────────────────┘
         │
         ▼
┌────────────────────┐
│  Azure SQL         │
│  Database          │
│  stg.Properties    │
│  stg.Rent          │
│  dbo.Properties    │
│  dbo.Rent          │
└────────┬───────────┘
         │  DirectQuery / Import
         ▼
┌────────────────────┐
│  Power BI          │
│  Dashboard         │
└────────────────────┘
```

---

## Project Structure

```
6-azure-data-integration
├── README.md
├── data-factory
│   ├── pipeline-definition.json    # ADF pipeline ARM template
│   ├── linked-services.json        # Connection definitions
│   ├── datasets.json               # Source & sink datasets
│   └── triggers.json               # Schedule triggers
├── sql
│   ├── create-tables.sql           # Azure SQL schema
│   ├── staging.sql                 # Staging procedures
│   └── views.sql                   # Reporting views
├── sample-data
│   └── rent-data.csv
└── security
    └── key-vault-setup.md
```

---

## Azure Services Used

| Service | Purpose |
|---------|---------|
| Azure Blob Storage | Raw file landing zone |
| Azure Data Factory | Orchestration & transformation |
| Azure SQL Database | Serving layer |
| Azure Key Vault | Secrets management |
| Azure Monitor | Pipeline alerts |

---

## ADF Pipeline Steps

### Pipeline: `pl_IngestRentData`

1. **Get Metadata** — Check file exists in Blob container
2. **If Condition** — Only proceed if file found
3. **Copy Activity** — CSV (Blob) → stg.Rent (Azure SQL)
   - Source: DelimitedText dataset pointing to `raw/` container
   - Sink: Azure SQL staging table
   - Mapping: column-by-column with type conversion
4. **Data Flow** — Cleansing transformations
   - Filter: Remove rows where RentAmount ≤ 0
   - Derived Column: Add LoadDate, SourceFile, BatchID
   - Aggregate: Validate row counts
5. **Stored Procedure Activity** — Execute `usp_ValidateAndLoad`
6. **Move File** — Archive CSV from `raw/` to `processed/`
7. **Send Notification** — Email on success or failure

---

## Transformation Logic (Data Flow)

```
Source (Blob CSV)
    │
    ├── Filter: RentAmount > 0 AND RentDate IS NOT NULL
    │
    ├── Derived Column:
    │     LoadDate   = currentTimestamp()
    │     SourceFile = $FileName
    │     BatchID    = uuid()
    │
    ├── Select: Explicit column mapping (no SELECT *)
    │
    └── Sink (Azure SQL stg.Rent)
```

---

## Schedule Trigger

```json
{
  "name": "trigger_DailyRentLoad",
  "type": "ScheduleTrigger",
  "recurrence": {
    "frequency": "Day",
    "interval": 1,
    "startTime": "2025-01-01T06:00:00",
    "timeZone": "GMT Standard Time"
  }
}
```

---

## Security Setup

- Connection strings stored in **Azure Key Vault**
- ADF Managed Identity used (no stored credentials)
- RBAC roles assigned:
  - ADF → Storage Blob Data Reader
  - ADF → SQL DB Contributor
- Data encrypted at rest and in transit (TLS 1.2+)

---

## Skills Demonstrated
- Azure Data Factory pipeline design
- Linked services and dataset configuration
- Data Flow transformations
- Azure Blob Storage integration
- Azure SQL Database
- Key Vault secrets management
- Scheduled pipeline triggers
- Cloud ETL architecture
