# Terraform with VSphere on Windows Guide

## Overview
This guide covers setting up and managing a secure Terraform environment for VMware VSphere on Windows 11, including credential management and VM deployment.

## Prerequisites
- Windows 11
- Terraform installed
- VMware VSphere environment
- Git (optional)
- HashiCorp Vault (optional)

## Credential Management

### Option 1: Environment Variables
Using PowerShell:
```powershell
$env:VSPHERE_USER="username"
$env:VSPHERE_PASSWORD="password"
$env:VSPHERE_SERVER="server"
```

### Option 2: Windows Credential Manager
```powershell
# Store credentials
cmdkey /generic:VSphere /user:username /pass:password

# Create automation script (credentials.ps1)
$credentials = Get-StoredCredential -Target "VSphere"
$env:VSPHERE_USER = $credentials.Username
$env:VSPHERE_PASSWORD = $credentials.GetNetworkCredential().Password
$env:VSPHERE_SERVER = "vsphere-server"
```

### Option 3: HashiCorp Vault Integration
```hcl
# Configure Vault provider
provider "vault" {
  address = "http://vault.example.com:8200"
}

# Fetch credentials from Vault
data "vault_generic_secret" "vsphere_credentials" {
  path = "secret/vsphere"
}

# Use in VSphere provider
provider "vsphere" {
  user           = data.vault_generic_secret.vsphere_credentials.data["user"]
  password       = data.vault_generic_secret.vsphere_credentials.data["password"]
  vsphere_server = data.vault_generic_secret.vsphere_credentials.data["server"]
}
```

## Project Structure
```
├── main.tf
├── variables.tf
├── terraform.tfvars (gitignored)
├── outputs.tf
├── modules/
│   ├── windows_vm/
│   └── linux_vm/
└── .gitignore
```

## Git Security
Create `.gitignore`:
```gitignore
# Terraform
*.tfvars
*.tfstate
*.tfstate.backup
.terraform/

# Credentials
credentials.ps1
.env
```

## Best Practices
1. **Sensitive Variables**
   - Mark variables containing credentials as sensitive
   - Use separate tfvars files for different environments

2. **State Management**
   - Use remote state storage (Azure, AWS, or HashiCorp)
   - Enable state encryption

3. **Version Control**
   - Commit only template tfvars files
   - Use branches for environment separation
   - Implement PR reviews for infrastructure changes

4. **CI/CD Integration**
   - Store credentials in Jenkins Credential Store or GitLab/GitHub encrypted variables
   - Implement terraform plan in PR checks
   - Use workspaces for environment isolation

## Basic Terraform Configuration

### variables.tf
```hcl
variable "vsphere_credentials" {
  type = object({
    user     = string
    password = string
    server   = string
  })
  sensitive = true
}

variable "vm_config" {
  type = object({
    name        = string
    cpu         = number
    memory      = number
    disk_size   = number
    template    = string
    datacenter  = string
    datastore   = string
    network     = string
    folder      = string
  })
}
```

### main.tf
```hcl
provider "vsphere" {
  user           = var.vsphere_credentials.user
  password       = var.vsphere_credentials.password
  vsphere_server = var.vsphere_credentials.server
}

# Data sources
data "vsphere_datacenter" "dc" {
  name = var.vm_config.datacenter
}

data "vsphere_datastore" "datastore" {
  name          = var.vm_config.datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = var.vm_config.network
  datacenter_id = data.vsphere_datacenter.dc.id
}

# VM Resource
resource "vsphere_virtual_machine" "vm" {
  name             = var.vm_config.name
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id
  num_cpus         = var.vm_config.cpu
  memory           = var.vm_config.memory
  folder           = var.vm_config.folder
  
  network_interface {
    network_id = data.vsphere_network.network.id
  }
  
  disk {
    label            = "disk0"
    size             = var.vm_config.disk_size
    thin_provisioned = true
  }
}
```

## Usage
1. Initialize Terraform:
```bash
terraform init
```

2. Set credentials using one of the methods above

3. Create terraform.tfvars with your configuration

4. Plan and apply:
```bash
terraform plan
terraform apply
```

## Security Considerations
- Rotate credentials regularly
- Use least privilege accounts
- Enable version control protection rules
- Implement infrastructure changes through CI/CD
- Regular security audits

## Next Steps
- Implement modular VM deployments
- Set up CI/CD pipelines
- Configure monitoring and logging
- Implement infrastructure testing