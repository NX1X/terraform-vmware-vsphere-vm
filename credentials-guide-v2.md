Here are three secure ways to handle VSphere credentials in Windows 11:

1. Environment Variables (PowerShell):
```powershell
# Set environment variables
$env:TF_VAR_vsphere_user="your-username"
$env:TF_VAR_vsphere_password="your-password"
$env:TF_VAR_vsphere_server="vsphere-server"

# Verify
echo $env:TF_VAR_vsphere_user
```

2. Using terraform.tfvars (encrypted):
```hcl
# terraform.tfvars
vsphere_user     = "username"
vsphere_password = "password"
vsphere_server   = "server"
```
```gitignore
# .gitignore
*.tfvars
```

3. Using Windows Credential Manager:
```powershell
# store-vsphere-creds.ps1
$vsphere_creds = Get-Credential -Message "Enter VSphere Credentials"
cmdkey /generic:VSphere /user:$vsphere_creds.UserName /pass:$vsphere_creds.GetNetworkCredential().Password

# load-creds.ps1
$creds = cmdkey /generic:VSphere
$env:TF_VAR_vsphere_user = $creds.UserName
$env:TF_VAR_vsphere_password = $creds.Password
```

Modified provider block:
```hcl
provider "vsphere" {
  user           = var.vsphere_user
  password       = var.vsphere_password
  vsphere_server = var.vsphere_server
  allow_unverified_ssl = true
}
```