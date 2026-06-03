$RepoRoot = Split-Path $PSScriptRoot -Parent
Set-Location $RepoRoot

python -m venv .venv

.venv\Scripts\python.exe -m pip install --upgrade pip

if (Test-Path "requirements.txt") {
    .venv\Scripts\pip.exe install -r requirements.txt
    Write-Host "Dependencies installed from requirements.txt"
}
else {
    Write-Host "requirements.txt not found. Virtual environment created."
}

Write-Host ""
Write-Host "Setup completed."
Write-Host "Activate the virtual environment using the following command:"
Write-Host ".\.venv\Scripts\Activate.ps1"