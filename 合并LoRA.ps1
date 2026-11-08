#Requires -Version 7.0
# Copyright 2026 SnowSalt. SPDX-License-Identifier: Apache-2.0
param([Parameter(Mandatory)][string]$Base, [string]$Adapter=(Join-Path $PSScriptRoot 'adapter'),
      [string]$Output=(Join-Path $PSScriptRoot 'merged-hf'), [string]$Python='python', [switch]$CheckOnly)
$ErrorActionPreference='Stop'
$arguments=@((Join-Path $PSScriptRoot 'merge_lora.py'),'--base',$Base,'--adapter',$Adapter,'--output',$Output)
if ($CheckOnly) {$arguments+='--check-only'}
& $Python @arguments
if ($LASTEXITCODE -ne 0) {throw "合并未完成，Python退出码：$LASTEXITCODE"}
