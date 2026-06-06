# -----------------------------------------------------------------------------
# Environment Setup Script
#
# Creates a project-local virtual environment, installs dependencies,
# and registers a repository-specific Jupyter kernel.
# -----------------------------------------------------------------------------

$ErrorActionPreference = "Stop"

# -----------------------------------------------------------------------------
# Locate Project Root
# -----------------------------------------------------------------------------

$current = $PSScriptRoot
$ProjectRoot = $null

$RootMarkers = @(
    ".git",
    "pyproject.toml",
    "requirements.txt",
    ".gitignore"
)

while ($true) {
    foreach ($marker in $RootMarkers) {
        if (Test-Path (Join-Path $current $marker)) {
            $ProjectRoot = $current
            break
        }
    }

    if ($ProjectRoot) {
        break
    }

    $parent = Split-Path $current -Parent

    if ($parent -eq $current) {
        throw "Project root not found. Add .git, pyproject.toml, requirements.txt, or .gitignore to the project root."
    }

    $current = $parent
}

Set-Location $ProjectRoot

# -----------------------------------------------------------------------------
# Validate Python Installation
# -----------------------------------------------------------------------------

if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    throw "Python is not available on PATH."
}

# -----------------------------------------------------------------------------
# Configure Environment Paths
# -----------------------------------------------------------------------------

$ProjectName = Split-Path $ProjectRoot -Leaf

$VenvPath = Join-Path $ProjectRoot ".venv"
$PythonPath = Join-Path $VenvPath "Scripts\python.exe"
$PipPath = Join-Path $VenvPath "Scripts\pip.exe"

$KernelName = "$ProjectName-venv"
$KernelDisplayName = "Python ($ProjectName)"

Write-Host "Project root: $ProjectRoot"
Write-Host "Project name: $ProjectName"

# -----------------------------------------------------------------------------
# Create Virtual Environment
# -----------------------------------------------------------------------------

if (Test-Path $VenvPath) {
    Write-Host "Virtual environment already exists."
}
else {
    python -m venv .venv
    Write-Host "Virtual environment created."
}

# -----------------------------------------------------------------------------
# Install Dependencies
# -----------------------------------------------------------------------------

& $PythonPath -m pip install --upgrade pip

if (Test-Path "requirements.txt") {
    & $PipPath install -r requirements.txt
    Write-Host "Dependencies installed from requirements.txt."
}
else {
    Write-Host "requirements.txt not found. Skipping dependency installation."
}

# -----------------------------------------------------------------------------
# Register Jupyter Kernel
# -----------------------------------------------------------------------------

& $PipPath install ipykernel

& $PythonPath -m ipykernel install `
    --user `
    --name $KernelName `
    --display-name $KernelDisplayName

# -----------------------------------------------------------------------------
# Display Summary
# -----------------------------------------------------------------------------

Write-Host ""
Write-Host "Setup completed."
Write-Host ""
Write-Host "Virtual environment:"
Write-Host $VenvPath
Write-Host ""
Write-Host "Activate it using:"
Write-Host ".\.venv\Scripts\Activate.ps1"
Write-Host ""
Write-Host "Jupyter kernel registered as:"
Write-Host $KernelDisplayName