param name string

param acrName string

param roleDefinitionId string

param principalId string

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-07-01' existing = {
    name: acrName
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
    name: name
    scope: containerRegistry
    properties: {
        roleDefinitionId: roleDefinitionId
        principalId: principalId
        principalType: 'ServicePrincipal'
    }
}
