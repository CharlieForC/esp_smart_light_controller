# Build helper for the local ESP-IDF v5.5.5 environment (Espressif IDE install)
#
# Usage:
#   .\build.ps1            - configure + build firmware
#   .\build.ps1 -flash      - build and flash to the configured port (COM3)
#   .\build.ps1 -monitor    - open the serial monitor
#   .\build.ps1 -clean      - full clean + rebuild
param(
    [switch]$Flash,
    [switch]$Monitor,
    [switch]$Clean
)

$ErrorActionPreference = 'Stop'

# Activate the Espressif IDE v5.5.5 environment (sets IDF_PATH, tools, python)
. 'C:\Espressif\tools\Microsoft.v5.5.5.PowerShell_profile.ps1' *> $null

# Project-specific external component paths
$env:HOMEKIT_PATH = 'D:\ESP32\esp-homekit-sdk'
$env:RMAKER_PATH  = 'D:\ESP32\rainmaker'

if ($Clean) {
    Write-Host '==> Cleaning previous build...' -ForegroundColor Cyan
    idf.py fullclean
}

Write-Host '==> Building esp_smart_light_controller (esp32c3)...' -ForegroundColor Cyan
idf.py build

if ($Flash) {
    Write-Host '==> Flashing to device...' -ForegroundColor Cyan
    idf.py -p COM3 flash
}

if ($Monitor) {
    Write-Host '==> Opening serial monitor...' -ForegroundColor Cyan
    idf.py -p COM3 monitor
}

Write-Host '==> Done. Firmware: build\esp_smart_light_controller.bin' -ForegroundColor Green
