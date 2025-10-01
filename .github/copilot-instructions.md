# GitHub Copilot Instructions

## Repository Overview

This repository contains an example full-stack application deployment on Azure Cloud using Terraform. It demonstrates how to build and deploy a containerized application (API + frontend) on Azure Linux Web Apps with infrastructure as code.

## Tech Stack

- **Infrastructure**: Terraform (>= 1.0)
  - Azure Provider (>= 3.86.0)
  - Docker Provider (3.6.2)
- **Cloud Platform**: Microsoft Azure
  - Azure Container Registry (ACR)
  - Azure App Service (Linux Web Apps)
  - Azure Application Insights
  - Azure Service Plan
- **Containerization**: Docker and Docker Compose
- **Languages**: HCL (Terraform), Go (API), HTML/CSS/JS (Web)

## Project Structure

```
.
├── main.tf                    # Root Terraform configuration
├── modules/
│   ├── base/                 # Base infrastructure (resource group, ACR, service plan)
│   └── app/                  # Application module (web apps, containers)
├── src/
│   ├── api/                  # API service (Go)
│   ├── web/                  # Web frontend
│   └── cli/                  # CLI tools
├── tests/                    # Test scripts
├── Makefile                  # Build and deployment automation
└── compose.yml              # Local Docker Compose configuration
```

## Development Guidelines

### Code Style

- **Terraform**:
  - Use 2-space indentation (as per `.editorconfig`)
  - Run `terraform fmt -recursive` before committing
  - Use meaningful variable and resource names
  - Follow Azure CAF (Cloud Adoption Framework) naming conventions
  - Add comments for security check skips (checkov)

- **General**:
  - Use UTF-8 encoding
  - Use LF line endings
  - Trim trailing whitespace
  - Ensure files end with a newline

### Terraform Module Structure

The project uses a modular Terraform structure:

1. **Base Module** (`modules/base/`): Creates foundational Azure resources
   - Resource Group
   - Container Registry
   - App Service Plan
   - Application Insights

2. **App Module** (`modules/app/`): Deploys containerized applications
   - Builds and pushes Docker images
   - Creates Azure Linux Web Apps
   - Configures managed identity and ACR pull access
   - Handles app settings and authentication

### Building and Testing

#### Local Development

```bash
# Format Terraform files
make fmt

# Initialize Terraform (first time)
make init

# Validate configuration
make validate

# Plan changes
make plan

# Run Docker Compose locally
make compose

# Run CI tests
make ci

# Clean up
make clean
```

#### Required Environment Variables

For Azure deployment, set these environment variables:
- `ARM_CLIENT_ID`: Azure service principal client ID
- `ARM_CLIENT_SECRET`: Azure service principal secret
- `ARM_SUBSCRIPTION_ID`: Azure subscription ID
- `ARM_TENANT_ID`: Azure tenant ID

### Key Conventions

1. **Resource Naming**:
   - Use the `terraform-azurerm-naming` module for CAF-compliant names
   - Resources use pattern: `{name}-{type}` (e.g., `myapp-rg`, `myapp-plan`)
   - ACR names are alphanumeric only (e.g., `myappreg`)

2. **Docker Images**:
   - Images are built and pushed to Azure Container Registry
   - Naming: `{registry}.azurecr.io/{service}:latest`
   - Services: `api` and `web`

3. **App Settings**:
   - API runs on port 8080
   - Web runs on port 80
   - Application Insights is enabled for both services

4. **Security**:
   - Web apps use system-assigned managed identities
   - ACR pull permissions are granted via role assignment
   - HTTPS is enforced (`https_only = true`)
   - Minimum TLS version is 1.3

### Testing

- Terraform configurations are validated in CI using reusable workflows
- Docker Compose CI tests build and verify all services
- Security scanning with Checkov is integrated
- Test script: `tests/test.sh`

### Deployment Flow

1. Terraform creates base infrastructure (resource group, ACR, service plan)
2. Docker images are built for API and web services
3. Images are pushed to Azure Container Registry
4. Azure Web Apps are created with container configuration
5. Managed identities are assigned ACR pull permissions
6. Application Insights is configured for monitoring

## Common Tasks

### Adding a New Service

1. Create a new directory under `src/` with a Dockerfile
2. Add a new module instantiation in `main.tf`
3. Configure app settings and dependencies
4. Update Docker Compose files if needed for local testing

### Modifying Infrastructure

1. Make changes to Terraform files
2. Run `terraform fmt -recursive`
3. Run `terraform validate`
4. Test with `terraform plan`
5. Review changes before applying

### Updating Dependencies

- Terraform providers are pinned to specific versions in `required_providers`
- The naming module uses a specific commit hash for stability
- Update versions carefully and test thoroughly

## CI/CD

- **Terraform CI**: Validates, formats, and plans Terraform changes
- **Docker Compose CI**: Builds and tests all services in isolation
- **Security**: Code scanning with upload-sarif permissions

## Additional Resources

- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure Linux Web Apps](https://learn.microsoft.com/en-us/azure/app-service/)
- [Azure Container Registry](https://learn.microsoft.com/en-us/azure/container-registry/)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)

## Notes for Copilot

- When suggesting changes to Terraform code, always maintain module structure
- Ensure Azure resource naming follows CAF conventions
- Be mindful of checkov security skip comments - they're intentional for demo purposes
- Consider both local (Docker Compose) and cloud (Azure) deployment scenarios
- Preserve the existing authentication patterns (managed identity + role assignments)
- Maintain consistency with the existing 2-space indentation style
