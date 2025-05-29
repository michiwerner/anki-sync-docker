# Azure Container App Deployment (Bicep)

This directory contains Bicep files to deploy the Anki Sync Docker project as an [Azure Container App](https://learn.microsoft.com/en-us/azure/container-apps/overview).

## Prerequisites
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) (2.37.0+)
- [Bicep CLI](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/install) (or use `az bicep`)
- An Azure subscription and resource group
- A [GitHub Container Registry (GHCR)](https://ghcr.io/) username and a [Personal Access Token](https://github.com/settings/tokens) with `read:packages` scope for private images

## Files
- `main.bicep`: Main Bicep template for deploying the Container App, environment, storage, and Log Analytics workspace
- `parameters.example.json`: Example parameters file for deployment
- `bicepconfig.json`: Bicep configuration to suppress expected warnings

## Features
- **Container Apps Environment** with optional VNet integration
- **Azure Files storage** for persistent data with proper mount configuration
- **Log Analytics workspace** for monitoring and logging
- **Container registry authentication** with secure secret management
- **Auto-scaling** configuration (0-1 replicas with HTTP scaling rules)
- **Latest API versions** for all resources (2023-05-01, 2023-01-01, 2022-10-01)

## Usage

1. **Customize Parameters**
   - Copy `parameters.example.json` to `parameters.prod.json` (or any name you prefer)
   - Edit the values, especially `containerImage`, `registryUsername`, and `registryPassword`
   - Optionally set `vnetSubnetResourceId` for VNet integration
   - Customize `storageAccountName` and `fileShareName` if needed
   - By default, the deployment uses the public image `ghcr.io/ankicommunity/anki-sync-server:latest` which auto-updates when the `latest` tag is updated.
   - For the public image, you do not need to set `registryUsername` or `registryPassword` (leave them empty).
   - If you wish to use a private image, set `containerImage`, `registryUsername`, and `registryPassword` accordingly.

2. **Deploy with Azure CLI**
   ```sh
   az deployment group create \
     --resource-group <your-resource-group> \
     --template-file main.bicep \
     --parameters @parameters.prod.json
   ```

   Replace `<your-resource-group>` with your Azure resource group name.

3. **Access the App**
   - The output will include the FQDN of your deployed Container App.

## Configuration Options

### Storage Configuration
- The deployment creates an Azure Storage account with an Azure Files share
- Data is persisted in the `/data` directory within the container
- Storage is configured with read-write access mode
- The file share uses "Transaction Optimized" access tier for cost efficiency

### Networking
- By default, the Container App is accessible from the internet
- To enable VNet integration, provide a `vnetSubnetResourceId` parameter
- The deployment automatically handles public/private configuration

### Scaling
- Minimum replicas: 0 (can scale to zero for cost savings)
- Maximum replicas: 1 (single instance for Anki sync to prevent conflicts)
- HTTP-based scaling with concurrency of 1 request

## Security Features
- Storage account configured with:
  - Minimum TLS 1.2
  - HTTPS traffic only
  - Public blob access disabled
- Container registry secrets stored securely
- Resource-specific naming to avoid conflicts

## Troubleshooting

### Bicep Warnings
The `bicepconfig.json` file suppresses expected warnings about secure values for Log Analytics and Storage Account keys. These warnings are expected behavior when integrating these services with Container Apps.

### Deployment Validation
Before deploying, you can validate your template:
```sh
az deployment group validate \
  --resource-group <your-resource-group> \
  --template-file main.bicep \
  --parameters @parameters.prod.json
```

## Notes
- By default, the deployment uses the public image `ghcr.io/ankicommunity/anki-sync-server:latest` which will always pull the latest version when the tag is updated on GHCR.
- No registry credentials are required for the public image. For private images, provide your GHCR username and a Personal Access Token with `read:packages` scope.
- The deployment creates a new Log Analytics workspace and Container Apps environment.
- The Container App is exposed publicly on the specified port (default: 27701).
- All resources use the latest stable API versions for improved functionality and security.
- Storage account names must be globally unique and follow Azure naming conventions. 