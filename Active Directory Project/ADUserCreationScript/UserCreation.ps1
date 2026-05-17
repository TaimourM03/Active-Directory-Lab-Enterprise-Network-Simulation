$usuarios = Import-Csv -Path "users.csv"

foreach ($usuario in $usuarios) {

    # Split full name
    $partesNombre = $usuario.User -split ' ', 3
    $nombre = $partesNombre[0]

    $apellidos = if ($partesNombre.Count -gt 1) {
        $partesNombre[1..($partesNombre.Count-1)] -join ' '
    } else {
        $null
    }

    # Generate SamAccountName (simple safe version)
    if ($apellidos) {
        $samAccountName = ($nombre + "." + ($partesNombre[1] -replace " ", "")).ToLower()
    } else {
        $samAccountName = $nombre.ToLower()
    }

    # Clean invalid characters
    $samAccountName = $samAccountName -replace "[^a-z0-9\.]", ""

    # Check if user exists
    if (Get-ADUser -Filter "SamAccountName -eq '$samAccountName'" -ErrorAction SilentlyContinue) {
        Write-Warning "El usuario $samAccountName ya existe. Se omitirá."
        continue
    }

    # DYNAMIC OU (THIS IS THE FIX)
    $ouPath = "OU=Users,OU=$($usuario.Department),DC=taicorp,DC=local"

    # Create user
    New-ADUser `
        -Name $usuario.User `
        -GivenName $nombre `
        -Surname $apellidos `
        -DisplayName $usuario.User `
        -SamAccountName $samAccountName `
        -UserPrincipalName "$samAccountName@taicorp.local" `
        -Path $ouPath `
        -AccountPassword (ConvertTo-SecureString "temp123!" -AsPlainText -Force) `
        -Enabled $true `
        -ChangePasswordAtLogon $true `
        -Office $usuario.Department

    Write-Host "Created user: $samAccountName"

    # Group name
    $groupName = "GRP_$($usuario.Department)"

    # Add to group (RBAC)
    $adUser = Get-ADUser -Identity $samAccountName   
    Add-ADGroupMember -Identity $groupName -Members $adUser
    Write-Host "Added $samAccountName to $groupName"

}