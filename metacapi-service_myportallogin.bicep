param buildNumber string

param imageServiceContainer string

param location string = resourceGroup().location

var containerAppName = 'dev-service-metacapi'

var revisionName = replace(buildNumber, '.', '-')

var keyVaultURL = 'https://azadskeyvault21.vault.azure.net/secrets'

resource containerAppManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
    name: '${containerAppName}-identity'
    location: location
}

// This is the Key Vault Secret User role
var keyVaultSecretUserRoleId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4633458b-17de-408a-b874-0445c86b69e6')

module kvRoleAssignment 'modules/kv-role-assignment.bicep' = {
    name: 'kvRoleAssignment'
    scope: resourceGroup('87c6de1a-6350-4afd-93a5-af7e39fd0ff5', 'az-resourcegrp1')
    params: {
        name: guid(containerAppManagedIdentity.id, keyVaultSecretUserRoleId)
        keyVaultName: 'azadskeyvault21'
        roleDefinitionId: keyVaultSecretUserRoleId
        principalId: containerAppManagedIdentity.properties.principalId
    }
}

// ACR Pull Role
var acrPullRoleId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d')

module acrRoleAssignment 'modules/acr-role-assignment.bicep' = {
    name: 'acrRoleAssignment'
    scope: resourceGroup('az-resourcegrp1')
    params: {
        name: guid(containerAppManagedIdentity.id, acrPullRoleId)
        acrName: 'adamscontainerregistry1'
        roleDefinitionId: acrPullRoleId
        principalId: containerAppManagedIdentity.properties.principalId
    }
}

resource containerAppEnv 'Microsoft.App/managedEnvironments@2022-03-01' existing = {
    name: 'container-managedEnvironment-azresourcegrp1'
    scope: resourceGroup('az-resourcegrp1')
}

resource containerAppService 'Microsoft.App/containerApps@2024-10-02-preview' = {
    name: containerAppName
    location: location
    identity: {
        type: 'SystemAssigned, UserAssigned'
        userAssignedIdentities:{
            '${containerAppManagedIdentity.id}': {}
        }
    }
    properties: {
        environmentId: containerAppEnv.id
        configuration: {
            registries: [
                {
                    server: 'adamscontainerregistry1.azurecr.io'
                    identity: containerAppManagedIdentity.id
                }
            ]
            secrets: [
                {
                    name: 'hottersftphost'
                    keyVaultUrl: '${keyVaultURL}/metacapi-service-HOTTERSFTPHOST'
                    identity: containerAppManagedIdentity.id
                }
                {
                    name: 'hottersftpusername'
                    keyVaultUrl: '${keyVaultURL}/metacapi-service-HOTTERSFTPUSERNAME'
                    identity: containerAppManagedIdentity.id
                }
                {
                    name: 'hottersftppassword'
                    keyVaultUrl: '${keyVaultURL}/metacapi-service-HOTTERSFTPPASSWORD'
                    identity: containerAppManagedIdentity.id
                }
            ]
        }
        template: {
            revisionSuffix: revisionName
            volumes: [
                {
                    name: 'adam-private'
                    storageType: 'AzureFile'
                    storageName: 'adam-private-mount'
                }
            ]
            containers: [
                {
                    image: imageServiceContainer
                    name: 'metacapi-service'
                    resources: {
                        cpu: json('0.25')
                        memory: '0.5Gi'
                    }
                    env: [
                        {
                            name:'AppSettings__DefaultDBConnectionString'
                            value:'db=woolly6;user=hank;password:hankmarving'
                        }
                        {
                            name: 'DOTNET_ENVIRONMENT'
                            value: 'Development'
                        }
                        {
                            name: 'AppSettings__LOGFILEPATH'
                            value: '/wt-private/logs/meta-capi'
                        }
                        {
                            name: 'AppSettings__HotterSftpHost'
                            secretRef: 'hottersftphost'
                        }
                        {
                            name: 'AppSettings__HotterSftpUsername'
                            secretRef: 'hottersftpusername'
                        }
                        {
                            name: 'AppSettings__HotterSftpPassword'
                            secretRef: 'hottersftppassword'
                        }
                        {
                            name: 'HotterFtpFilesDownloadDirectory'
                            value: '/hotter-ftpfiles-download'
                        }
                        {
                            name: 'HotterFilesRemoteDirectory'
                            value: '/'
                        }
                    ]
                    volumeMounts: [
                        {
                            mountPath: '/adam-private'
                            volumeName: 'adam-private'
                        }
                    ]
                    probes: []
                }
            ]
            scale: {
                minReplicas: 1
                maxReplicas: 1
            }
        }
    }
}
