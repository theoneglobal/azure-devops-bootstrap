# Azure Terraform Bootstrap

[![Terraform CI](https://github.com/theoneglobal/azure-devops-bootstrap/workflows/Terraform%20CI/badge.svg)](https://github.com/theoneglobal/azure-devops-bootstrap/actions)
[![Terraform Version](https://img.shields.io/badge/terraform-%3E%3D1.5.0-blue)](https://www.terraform.io/)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

This Terraform configuration sets up persistent storage in Azure for managing Terraform state. It provisions the following resources:
- An Azure Resource Group to organize the infrastructure.
- A Storage Account (Standard tier, Locally Redundant Storage) to store Terraform state files securely.
- A private Blob Container within the storage account for state file storage.

The configuration is designed as a standalone deployment, ideal for bootstrapping a secure storage backend for Terraform projects in Azure.

## Features
- Secure storage account with HTTPS-only traffic, TLS 1.2, and disabled public access.
- Lifecycle rule to prevent accidental deletion of the storage account.
- Tagging for resource organization and cost tracking.
- Automated validation and security scanning via GitHub Actions.
- Example variables file (`terraform.tfvars.example`) for quick setup.

## Prerequisites
To use this configuration, you need:
- **Terraform** >= 1.5.0
  - **Windows**: Install via Chocolatey: `choco install terraform -y`
  - **Mac**: Install via Homebrew: `brew install terraform`
  - **Linux**: Install via tfenv or download from [HashiCorp](https://www.terraform.io/downloads.html)
- **Azure CLI** (`az`) installed
  - **Windows**: `choco install azure-cli -y`
  - **Mac**: `brew install azure-cli`
  - **Linux**: Follow [Azure CLI installation](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-linux)
- An **Azure subscription**.
- **Git** to clone the repository
  - **Windows**: `choco install git -y`
  - **Mac**: `brew install git`
  - **Linux**: `sudo apt-get install git` (Ubuntu) or equivalent.

## Getting Started
Follow these steps to deploy the configuration on Windows, Mac, or Linux:

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/theoneglobal/azure-devops-bootstrap.git
   cd azure-devops-bootstrap
   ```

2. **Authenticate with Azure CLI**:
   Log in to Azure:
   ```bash
   az login
   ```
   - A browser window will open for authentication. Follow the prompts to sign in.
   - If you have multiple subscriptions, list them:
     ```bash
     az account list --output table
     ```
   - Set the desired subscription:
     ```bash
     az account set --subscription "your-subscription-name-or-id"
     ```
     Replace `your-subscription-name-or-id` with the subscription name or ID from the list.

3. **Configure Variables**:
   Copy the example variables file and edit it to match your environment:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```
   Example `terraform.tfvars` (edit in a text editor like VS Code):
   ```hcl
   resource_group_name  = "rg-terraform-bootstrap"
   location             = "westeurope"
   storage_account_name = "tfbootstrapstore123"
   container_name       = "tfstate"
   ```
   - Ensure `storage_account_name` is globally unique (3-24 lowercase alphanumeric characters).
   - Use Azure region codes (e.g., `westeurope`, `eastus`) for `location`.

4. **Initialize Terraform**:
   ```bash
   terraform init
   ```

5. **Review the Plan**:
   ```bash
   terraform plan -var-file=terraform.tfvars
   ```

6. **Apply the Configuration**:
   ```bash
   terraform apply -var-file=terraform.tfvars
   ```
   Confirm by typing `yes` when prompted.

7. **Verify Outputs**:
   After applying, Terraform will output:
   - `storage_account_name`: Name of the created storage account.
   - `resource_group_name`: Name of the resource group.
   - `container_name`: Name of the blob container.
   - `subscription_id`: Azure subscription ID.

## Using the Storage for Terraform State
Once deployed, configure your Terraform projects to use the created storage account as a remote backend. Example backend configuration:
```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-bootstrap"
    storage_account_name = "tfbootstrapstore123"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}
```
Obtain the storage account key using Azure CLI:
```bash
az storage account keys list --resource-group rg-terraform-bootstrap --account-name tfbootstrapstore123 --query '[0].value' --output tsv
```
Set the key as an environment variable or pass it to Terraform when initializing the backend.

## Cleaning Up
To destroy the resources:
```bash
terraform destroy -var-file=terraform.tfvars
```
**Note**: The storage account has a `prevent_destroy` lifecycle rule to avoid accidental deletion. To destroy it, temporarily modify `main.tf` to set `prevent_destroy = false` in the `lifecycle` block of the `azurerm_storage_account` resource.

## Automation and Quality Checks
This repository includes automated checks via GitHub Actions to ensure quality and security:
- **Terraform Format**: Enforces consistent code style (`terraform fmt`).
- **Terraform Validate**: Checks configuration syntax.
- **TFLint**: Enforces Azure best practices.
- **Checkov**: Scans for security misconfigurations (e.g., public blob access).
- **Terratest**: Validates resource creation in a test Azure environment.
- **Dependabot**: Keeps Terraform provider and GitHub Actions up-to-date.

See the [GitHub Actions workflow](.github/workflows/terraform.yml) for details.

## Inputs
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| container_name | Blob container name for Terraform state | `string` | `"tfstate"` | no |
| location | Azure Region | `string` | `"West Europe"` | no |
| resource_group_name | Name of the Azure Resource Group | `string` | n/a | yes |
| storage_account_name | Globally unique name for the Azure Storage Account (3-24 lowercase letters/digits) | `string` | n/a | yes |

## Outputs
| Name | Description |
|------|-------------|
| container_name | Name of the blob container |
| resource_group_name | Name of the resource group |
| storage_account_name | Name of the storage account |
| subscription_id | Azure subscription ID |

## Contributing
Contributions are welcome! Please:
1. Fork the repository.
2. Create a feature branch (`git checkout -b feature/your-feature`).
3. Commit changes (`git commit -m "Add your feature"`).
4. Push to the branch (`git push origin feature/your-feature`).
5. Open a pull request.

Report issues or suggest improvements via [GitHub Issues](https://github.com/theoneglobal/azure-devops-bootstrap/issues).
