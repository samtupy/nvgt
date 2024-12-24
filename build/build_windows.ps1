if ($args -contains "-it") {
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        winget install --id Git.Git -e
    }
    if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
        winget install --id Python.Python -e
    }
    if (-not (Get-Command cl -ErrorAction SilentlyContinue)) {
        winget install --id Microsoft.VisualStudio.2022.BuildTools -e
    }
}
if ($args -contains "-ci") {
    Set-Location ..
} else {
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        winget install --id Git.Git -e
    }
    git clone https://github.com/samtupy/nvgt
    Set-Location -Path "nvgt"
}
$windevPath = "windev"
if (-not (Test-Path $windevPath) -or (Get-ChildItem $windevPath -Recurse | Measure-Object).Count -eq 0) {
    $windevZipUrl = "https://nvgt.gg/windev.zip"
    $zipFile = "$env:TEMP\windev.zip"
    Invoke-WebRequest -Uri $windevZipUrl -OutFile $zipFile
    New-Item -ItemType Directory -Path $windevPath -Force
    Expand-Archive -Path $zipFile -DestinationPath $windevPath -Force
}
python -m pip install scons
scons -s
