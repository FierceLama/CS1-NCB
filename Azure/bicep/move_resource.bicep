// Resource: Local Network Gateway
resource localNetworkGateways_Finn_LNG_resource 'Microsoft.Network/localNetworkGateways@2025-05-01' = {
  name: 'Finn_LNG'
  location: 'northeurope'
  properties: {
    localNetworkAddressSpace: {
      addressPrefixes: [
        '192.168.0.0/24'
      ]
    }
    gatewayIpAddress: '145.220.73.51'
  }
}

// Resource: Network Security Group
resource networkSecurityGroups_Finn_NSG1_resource 'Microsoft.Network/networkSecurityGroups@2025-05-01' = {
  name: 'Finn-NSG1'
  location: 'northeurope'
  tags: {
    Finn: 'spoke'
  }
  properties: {
    securityRules: []
  }
}

// Resource: Public IP 1
resource publicIPAddresses_Finn_PublicIP_VPN_resource 'Microsoft.Network/publicIPAddresses@2025-05-01' = {
  name: 'Finn_PublicIP_VPN'
  location: 'northeurope'
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  zones: [ '1', '2', '3' ]
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    idleTimeoutInMinutes: 4
  }
}

// Resource: Public IP 2
resource publicIPAddresses_Finn_PublicIP_VPN2_resource 'Microsoft.Network/publicIPAddresses@2025-05-01' = {
  name: 'Finn_PublicIP_VPN2'
  location: 'northeurope'
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  zones: [ '1', '2', '3' ]
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    idleTimeoutInMinutes: 4
  }
}

// Resource: Virtual Network
resource virtualNetworks_VNET_Finn_resource 'Microsoft.Network/virtualNetworks@2025-05-01' = {
  name: 'VNET-Finn'
  location: 'northeurope'
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.50.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'Subnet-Finn-Hub'
        properties: {
          addressPrefix: '10.50.0.0/24'
          networkSecurityGroup: {
            id: networkSecurityGroups_Finn_NSG1_resource.id
          }
        }
      }
      {
        name: 'Subnet-Finn-Spoke'
        properties: {
          addressPrefix: '10.50.10.0/24'
          networkSecurityGroup: {
            id: networkSecurityGroups_Finn_NSG1_resource.id
          }
        }
      }
      {
        name: 'GatewaySubnet'
        properties: {
          addressPrefix: '10.50.20.0/24'
        }
      }
    ]
  }
}

// Helper: Referentie naar GatewaySubnet (nodig voor de Gateway resource)
resource gatewaySubnetRef 'Microsoft.Network/virtualNetworks/subnets@2025-05-01' existing = {
  parent: virtualNetworks_VNET_Finn_resource
  name: 'GatewaySubnet'
}

// Resource: Virtual Network Gateway (VPN)
resource virtualNetworkGateways_Finn_VPNGW_resource 'Microsoft.Network/virtualNetworkGateways@2025-05-01' = {
  name: 'Finn_VPNGW'
  location: 'northeurope'
  properties: {
    ipConfigurations: [
      {
        name: 'default'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIPAddresses_Finn_PublicIP_VPN_resource.id
          }
          subnet: {
            id: gatewaySubnetRef.id
          }
        }
      }
      {
        name: 'activeActive'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIPAddresses_Finn_PublicIP_VPN2_resource.id
          }
          subnet: {
            id: gatewaySubnetRef.id
          }
        }
      }
    ]
    sku: {
      name: 'VpnGw1AZ'
      tier: 'VpnGw1AZ'
    }
    gatewayType: 'Vpn'
    vpnType: 'RouteBased'
    activeActive: true
    vpnGatewayGeneration: 'Generation1'
  }
}

// Resource: VPN Connection
resource connections_Finn_VPNGW_Connection_resource 'Microsoft.Network/connections@2025-05-01' = {
  name: 'Finn_VPNGW_Connection'
  location: 'northeurope'
  properties: {
    virtualNetworkGateway1: {
      id: virtualNetworkGateways_Finn_VPNGW_resource.id
      properties: {}
    }
    localNetworkGateway2: {
      id: localNetworkGateways_Finn_LNG_resource.id
      properties: {}
    }
    connectionType: 'IPsec'
    connectionProtocol: 'IKEv2'
    routingWeight: 0
    authenticationType: 'PSK'
    sharedKey: 'KiesHierEenSterkWachtwoord' // Vergeet dit niet aan te passen!
  }
}
