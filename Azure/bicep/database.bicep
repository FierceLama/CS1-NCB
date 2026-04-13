// SQL server toevoegen
resource sqlServer 'Microsoft.Sql/servers@2023-05-01-preview' = {
  name: 'finn-sql-server'
  location: 'northeurope'
  properties: {
    administratorLogin: 'sqladmin'
    administratorLoginPassword: '@@rdaPPel23!'
  }
}

// SQL database toevoegen aan de server
resource sqlDatabase 'Microsoft.Sql/servers/databases@2023-05-01-preview' = {
  parent: sqlServer
  name: 'finn-sql-database'
  location: 'northeurope'
  sku: {
    name: 'Basic'
    tier: 'Basic'
    capacity: 5
  }
}

// Firewall regel om Azure-services toegang te geven (optioneel maar handig)
resource allowAzureServices 'Microsoft.Sql/servers/firewallRules@2023-05-01-preview' = {
  parent: sqlServer
  name: 'AllowAllAzureIps'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}
