#Requires -Version 7.0
# Copyright 2026 SnowSalt. SPDX-License-Identifier: Apache-2.0
# Modified for public distribution on 2026-11-08.
param(
    [ValidateRange(0,65)][int]$GpuLayers=20,
    [ValidateRange(512,32768)][int]$Context=4096,
    [string]$Device='',
    [string]$Model=(Join-Path (Split-Path $PSScriptRoot -Parent) 'base-Q4_K_M.gguf'),
    [string]$Adapter=(Join-Path (Split-Path $PSScriptRoot -Parent) 'lora-round2.gguf'),
    [ValidateRange(1024,65535)][int]$Port=8087,
    [switch]$CheckOnly
)
$ErrorActionPreference='Stop'
$binary=Join-Path $PSScriptRoot 'runtime/llama-server.exe'

if (!(Test-Path -LiteralPath $binary)) {throw '缺少 runtime/llama-server.exe，请完整复制启动包。'}
if (!(Test-Path -LiteralPath $model)) {throw '找不到底座GGUF。请放置base-Q4_K_M.gguf，或通过-Model指定。'}
if (!(Test-Path -LiteralPath $Adapter)) {throw '找不到LoRA GGUF，请放置lora-round2.gguf，或通过-Adapter指定。'}
$listing=(& $binary --list-devices 2>&1 | Out-String)
$devices=@([regex]::Matches($listing,'(?m)^\s*(Vulkan\d+):\s*(.+)$') | ForEach-Object {
    [pscustomobject]@{Id=$_.Groups[1].Value;Name=$_.Groups[2].Value}
})
if (!$Device) {
    $preferred=@($devices | Where-Object {$_.Name -match 'NVIDIA|Radeon RX|Arc\(' -and $_.Name -notmatch 'Iris'})
    if (!$preferred.Count) {$preferred=@($devices | Where-Object {$_.Name -notmatch 'Iris|llvmpipe|Microsoft Basic'})}
    if (!$preferred.Count) {$preferred=$devices}
    if (!$preferred.Count) {throw "没有发现Vulkan显卡。请安装显卡官方驱动。`n$listing"}
    $Device=$preferred[0].Id
}
if ($Device -notin $devices.Id) {throw "设备 $Device 不存在。可用设备：`n$listing"}
$arguments=@('-m',$model,'--lora',$Adapter,'--device',$Device,'--n-gpu-layers',"$GpuLayers",'--ctx-size',"$Context",
    '--batch-size','128','--ubatch-size','64','--parallel','1','--fit','off','--no-op-offload',
    '--flash-attn','auto','--reasoning','off','--host','127.0.0.1','--port',"$Port")
Write-Host "模型：27B前端优化（底座＋独立LoRA）"
Write-Host "设备：$Device；GPU层数：$GpuLayers；上下文：$Context"
Write-Host '建议32GB系统内存。显存不足时用16层配置；本配置不对显存使用量作硬限制。'
Write-Host "就绪后浏览器打开 http://127.0.0.1:$Port"
Write-Host '按 Ctrl+C 停止服务。'
if ($CheckOnly) {
    [pscustomobject]@{Executable=$binary;Model=$model;Device=$Device;GpuLayers=$GpuLayers;Context=$Context;Arguments=$arguments} | ConvertTo-Json -Depth 3
    exit 0
}
& $binary @arguments
exit $LASTEXITCODE


