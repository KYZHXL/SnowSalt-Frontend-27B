#Requires -Version 7.0
# Copyright 2026 SnowSalt. SPDX-License-Identifier: Apache-2.0
$ErrorActionPreference='Stop'
$url='https://github.com/ggml-org/llama.cpp/releases/download/b12110/llama-b12110-bin-win-vulkan-x64.zip'
$expected='9732a5e48887ca54d0bfe4af4324dc85fd56cd8cda19b52df3542fa6ebe6874f'
$zip=Join-Path $PSScriptRoot 'runtime.zip'
$destination=Join-Path $PSScriptRoot '8GB-启动包/runtime'
if (Test-Path -LiteralPath (Join-Path $destination 'llama-server.exe')) {Write-Host '运行时已安装。'; exit 0}
Invoke-WebRequest -Uri $url -OutFile $zip
if ((Get-FileHash -LiteralPath $zip -Algorithm SHA256).Hash.ToLowerInvariant() -ne $expected) {throw '运行时校验失败。'}
Expand-Archive -LiteralPath $zip -DestinationPath $destination -Force
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'licenses/LLAMA_CPP_LICENSE.txt') -Destination $destination
Write-Host '运行时安装完成。'
