$ErrorActionPreference = "Stop"

Write-Host "Starting SSH configuration..."

if(-not (Get-Command ssh -ErrorAction SilentlyContinue)) {
	Write-Error "OpenSSH is not installed, please install OpenSSH client"
		exit 1
}

if(-not (Get-Command ssh-keygen -ErrorAction SilentlyContinue)){
	Write-Error "ssh-keygen is not available, please install OpenSSH client"
		exit 1
}

$SSHDir = Join-Path $HOME ".ssh"
$Key = Join-Path $SSHDir "id_ed25519"
$PublicKey = "$Key.pub"

New-Item -ItemType Directory -Force -Path $SSHDir | Out-Null

if(-not (Test-Path $Key)) {
	Write-Host "No SSH key found, generating new key"
		$Email = Read-Host "Enter your email address:"
		ssh-keygen -t ed25519 -C $Email -f $Key
		if($LASTEXITCODE -ne 0) {
			throw "SSH Key generation failed"
		}
}else {
	Write-Host "SSH key already exists, skipping key generation"
}

try {
	$Agent = Get-Service ssh-agent -ErrorAction Stop
		if($Agent.Status -ne "Running") {
			if($Agent.StartType -eq "Disabled") {
				Write-Warning "ssh-agent is disabled. Enable it in an elevated PowerShell session if needed."
			} else {
				Start-Service ssh-agent
			}
		}

	if((Get-Service ssh-agent).Status -eq "Running") {
		ssh-add $Key

			if($LASTEXITCODE -ne 0) {
				Write-Warning "Could not add the key to ssh-agent."
			}
	}
} catch {
	Write-Warning "Windows ssh-agent is unavailable but you can still use your SSH key directly :)"
}


Write-Host ""
Write-Host "SSH Configuration completed"
Write-Host "Your public SSH key is: "
Get-Content $PublicKey

Write-Host ""
Write-Host "Add this to your GitHub account:"
Write-Host "Go to: https://github.com/settings/keys"
