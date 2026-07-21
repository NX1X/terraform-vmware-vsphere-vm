# Prompt for vSphere credentials
$vsphere_username = Read-Host -Prompt "Enter vSphere Username"
$vsphere_password = Read-Host -Prompt "Enter vSphere Password" -AsSecureString

# Convert the secure string password to plain text for use with cmdkey
$plain_password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(
    [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($vsphere_password)
)

# Store the credentials securely
cmdkey /generic:VSphere /user:$vsphere_username /pass:$plain_password

# Clear the plain text password from memory for security
[System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($vsphere_password))
