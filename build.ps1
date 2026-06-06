param (
    [switch]$NonInteractive
)

$ErrorActionPreference = "Stop"

Write-Host "Brave Origin Unlocker Build Script" -ForegroundColor Blue

# Check for dotnet command and SDK
$sdkInstalled = $false
try {
    $dotnetExists = Get-Command dotnet -ErrorAction SilentlyContinue
    if ($dotnetExists) {
        $sdks = & dotnet --list-sdks 2>$null
        if ($sdks -and $sdks -match "8\.") {
            $sdkInstalled = $true
        }
    }
} catch {
    $sdkInstalled = $false
}

if (-not $sdkInstalled) {
    Write-Host ".NET 8.0 SDK is required but could not be found." -ForegroundColor Yellow
    
    if ($NonInteractive) {
        Write-Host "Running in non-interactive mode. Please install the .NET 8.0 SDK manually or run this script interactively to auto-install." -ForegroundColor Red
        Write-Host "Install link: https://dotnet.microsoft.com/download/dotnet/8.0" -ForegroundColor Red
        Exit 1
    }

    Write-Host "We can attempt to install the .NET 8.0 SDK for you using winget." -ForegroundColor Yellow
    $choice = Read-Host "Would you like to install .NET 8.0 SDK now? (Y/N)"
    if ($choice -eq 'Y' -or $choice -eq 'y') {
        Write-Host "Installing .NET 8.0 SDK..." -ForegroundColor Cyan
        # Run winget to install the SDK
        Start-Process winget -ArgumentList "install Microsoft.DotNet.SDK.8 --silent --accept-source-agreements --accept-package-agreements" -Wait -NoNewWindow
        
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
        
        # Check installation again
        try {
            $sdks = & dotnet --list-sdks 2>$null
            if ($sdks -and $sdks -match "8\.") {
                $sdkInstalled = $true
                Write-Host ".NET 8.0 SDK installed successfully!" -ForegroundColor Green
            }
        } catch {}
    }
}

if (-not $sdkInstalled) {
    Write-Host "Could not verify .NET 8.0 SDK installation. Please install it manually from: https://dotnet.microsoft.com/download/dotnet/8.0" -ForegroundColor Red
    Exit 1
}

# Run the build
Write-Host "`nStarting build process..." -ForegroundColor Cyan

$rootPath = Get-Location
$publishDir = Join-Path $rootPath "bin\Release\net8.0\win-x64\publish"

Write-Host "Attempting Native AOT compilation (zero dependencies, highly optimized)..." -ForegroundColor Cyan
try {
    & dotnet publish -c Release -r win-x64 /p:PublishAot=true
    $buildSuccess = $LASTEXITCODE -eq 0
} catch {
    $buildSuccess = $false
}

if ($buildSuccess) {
    Write-Host "`n[SUCCESS] Compiled successfully using Native AOT!" -ForegroundColor Green
} else {
    Write-Host "`n[INFO] Native AOT compilation failed or is unsupported on this system (requires C++ build tools)." -ForegroundColor Yellow
    Write-Host "Falling back to Framework-Dependent Single-File build (requires .NET 8.0 Runtime, extremely small size)..." -ForegroundColor Cyan
    
    try {
        & dotnet publish -c Release -r win-x64 /p:PublishAot=false /p:PublishSingleFile=true --self-contained false
        $buildSuccess = $LASTEXITCODE -eq 0
    } catch {
        $buildSuccess = $false
    }
    
    if ($buildSuccess) {
        Write-Host "`n[SUCCESS] Compiled successfully as a framework-dependent single-file executable!" -ForegroundColor Green
    } else {
        Write-Host "`n[ERROR] Build failed." -ForegroundColor Red
        Exit 1
    }
}

# Locate compiled executable
$exeSourcePath = Join-Path $publishDir "BraveOriginUnlocker.exe"
$exeDestPath = Join-Path $rootPath "BraveOriginUnlocker.exe"

if (Test-Path $exeSourcePath) {
    Copy-Item -Path $exeSourcePath -Destination $exeDestPath -Force
    Write-Host "`nBuild complete!" -ForegroundColor Green
    $size = (Get-Item $exeDestPath).Length / 1MB
    Write-Host ("File Size: {0:N2} MB" -f $size) -ForegroundColor Cyan

    # Code signing to reduce antivirus false positives
    Write-Host "`nSigning executable..." -ForegroundColor Cyan
    
    $certName = "BraveOriginUnlocker Code Signing"
    $certStoreLocation = "Cert:\CurrentUser\My"
    $cert = Get-ChildItem $certStoreLocation | Where-Object { $_.Subject -eq "CN=$certName" -and $_.NotAfter -gt (Get-Date) } | Select-Object -First 1
    
    if (-not $cert) {
        Write-Host "Creating self-signed code signing certificate..." -ForegroundColor Cyan
        $cert = New-SelfSignedCertificate -Type CodeSigningCert -Subject "CN=$certName" -CertStoreLocation $certStoreLocation -NotAfter (Get-Date).AddYears(5)
        Write-Host "Certificate created (valid for 5 years)." -ForegroundColor Green
    }
    
    try {
        Set-AuthenticodeSignature -FilePath $exeDestPath -Certificate $cert -TimestampServer "http://timestamp.digicert.com" -ErrorAction Stop | Out-Null
        Write-Host "[SIGNED] Executable signed successfully!" -ForegroundColor Green
    } catch {
        Write-Host "[WARNING] Signing failed: $_" -ForegroundColor Yellow
        Write-Host "The executable will still work but may trigger AV warnings." -ForegroundColor Yellow
    }

    Write-Host "`nExecutable is ready at: .\BraveOriginUnlocker.exe" -ForegroundColor Green
} else {
    Write-Host "`n[ERROR] Could not find compiled executable at: $exeSourcePath" -ForegroundColor Red
    Exit 1
}
