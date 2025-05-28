# Azure Container App Deployment (Bicep)

This directory contains Bicep files to deploy the Anki Sync Docker project as an [Azure Container App](https://learn.microsoft.com/en-us/azure/container-apps/overview).

## Prerequisites
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) (2.37.0+)
- [Bicep CLI](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/install) (or use `az bicep`)
- An Azure subscription and resource group
- A [GitHub Container Registry (GHCR)](https://ghcr.io/) username and a [Personal Access Token](https://github.com/settings/tokens) with `read:packages` scope for private images

## Files
- `main.bicep`: Main Bicep template for deploying the Container App, environment, and Log Analytics workspace
- `parameters.example.json`: Example parameters file for deployment

## Usage

1. **Customize Parameters**
   - Copy `parameters.example.json` to `parameters.prod.json` (or any name you prefer)
   - Edit the values, especially `containerImage`, `registryUsername`, and `registryPassword`

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

## Notes
- The deployment creates a new Log Analytics workspace and Container Apps environment.
- The Container App is exposed publicly on the specified port (default: 27701).
- For private images, ensure your GHCR token has the correct permissions. 