# Azure Key Vault Setup Guide

Secrets management for the Azure Data Integration pipeline.  
**No connection strings or passwords are stored directly in ADF linked services.**

---

## Setup Steps

### 1. Create Key Vault
```bash
az keyvault create \
  --name kv-property-pipeline \
  --resource-group rg-property-data \
  --location uksouth
```

### 2. Add Secrets
```bash
# Azure SQL connection string
az keyvault secret set \
  --vault-name kv-property-pipeline \
  --name "azure-sql-connection-string" \
  --value "Server=tcp:<server>.database.windows.net;Database=PropertyDB;Authentication=Active Directory Managed Identity"

# Blob Storage connection string
az keyvault secret set \
  --vault-name kv-property-pipeline \
  --name "blob-storage-connection-string" \
  --value "DefaultEndpointsProtocol=https;AccountName=<storage>;AccountKey=<key>"
```

### 3. Grant ADF Managed Identity Access
```bash
# Get ADF Managed Identity Object ID from Azure Portal → ADF → Properties
az keyvault set-policy \
  --name kv-property-pipeline \
  --object-id <adf-managed-identity-object-id> \
  --secret-permissions get list
```

### 4. Grant ADF Access to SQL Database
```sql
-- Run in Azure SQL Database
CREATE USER [adf-property-pipeline] FROM EXTERNAL PROVIDER;
ALTER ROLE db_datareader ADD MEMBER [adf-property-pipeline];
ALTER ROLE db_datawriter ADD MEMBER [adf-property-pipeline];
GRANT EXECUTE ON SCHEMA::etl TO [adf-property-pipeline];
```

---

## Security Checklist

- [ ] No passwords in ADF linked services
- [ ] ADF uses Managed Identity (not service principal with secret)
- [ ] Key Vault firewall restricts to Azure services only
- [ ] SQL login uses Azure AD (not SQL authentication)
- [ ] Blob Storage uses HTTPS only
- [ ] Network Security Group restricts ADF outbound
- [ ] Audit logs enabled on Key Vault

---

## Role Assignments Summary

| Resource | ADF Permission | Role |
|----------|---------------|------|
| Key Vault | Get/List secrets | Key Vault Secrets User |
| Blob Storage | Read files | Storage Blob Data Reader |
| Azure SQL | Read/Write data | db_datareader + db_datawriter |
