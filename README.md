# SnowSalt Frontend 27B · LoRA

面向网页与前端代码生成的小规模 LoRA 实验。**本项目只提供 LoRA、启动与合并脚本，不上传或重新分发 27B 底座。**

准确底座是 [DavidAU/Qwen3.8-27B-TURBO-Fable-Cold-Fusion-735-882-Heretic-Uncensored-NM-DAU](https://huggingface.co/DavidAU/Qwen3.8-27B-TURBO-Fable-Cold-Fusion-735-882-Heretic-Uncensored-NM-DAU)，祖先为 Qwen/Qwen3.8-27B。**不能拿任意 Qwen 27B、原版 Qwen 或其他 Uncensored 衍生模型替代。**

发布资产已公开发布在 [GitHub Release v0.1.0-preview](https://github.com/KYZHXL/SnowSalt-Frontend-27B/releases/tag/v0.1.0-preview)。训练输出来源条款仍待核对，详见 [发布检查](RELEASE_REVIEW.md)；仅发布 LoRA 不会自动解决该问题。

## 提供的文件

| 文件 | 大小 | 用途 |
|---|---:|---|
| `frontend-lora-peft.zip` | 约 319MB 压缩前 | 含 PEFT adapter、配置和许可，用于 HF 合并或加载 |
| `lora-round2.gguf` | 159.42MB | llama.cpp 直接加载，无需合并 |
| `SnowSalt-Frontend-27B-LoRA-launcher.zip` | 约 52MB | Windows Vulkan 运行时、脚本和说明，不含底座或 LoRA |
| `SHA256SUMS.txt` | 很小 | 发布资产校验 |

两份 LoRA 是同一轮训练的不同格式，按使用方式选择，不要同时应用两遍。

## 方式一：下载 BF16 底座并合并

建议在有 **96GB 系统内存**的机器上操作；CPU BF16 加载本身约需 54GB，64GB 总内存可能紧张。底座和合并结果合计预留约 120GB 磁盘空间。8GB 显卡不是合并所需显存，脚本使用 CPU。

Python 3.11/3.12 环境中执行：

```powershell
python -m venv .venv
.\.venv\Scripts\python.exe -m pip install -r requirements-merge.txt
.\.venv\Scripts\python.exe download_base.py --output base-model --workers 4
```

解压 `frontend-lora-peft.zip`，让项目目录中出现 `adapter/adapter_config.json` 和 `adapter/adapter_model.safetensors`，然后：

```powershell
.\.venv\Scripts\python.exe merge_lora.py --base base-model --adapter adapter --output merged-hf
```

Linux 下把 Python 路径换为 `.venv/bin/python`，其余参数相同。Windows 也提供 `合并LoRA.ps1` 包装脚本。`--check-only` 只检查输入，不加载大模型。

合并脚本使用 PEFT `merge_and_unload(safe_merge=True)`，输出文本 HF Safetensors 模型和 tokenizer；不改原底座或原 LoRA。输出目录必须为空。它接受 **BF16 HF 权重目录，不接受 Q4/Q8 GGUF**。

若需要 Q4 GGUF，可在支持 qwen35 的 llama.cpp 源码环境中继续转换：

```text
python convert_hf_to_gguf.py /path/to/merged-hf --outfile merged-BF16.gguf --outtype bf16
llama-quantize merged-BF16.gguf merged-Q4_K_M.gguf Q4_K_M
```

转换还会占用额外磁盘。不要把“先量化再动态应用 LoRA”与“先合并再量化”声称为逐位相同结果。

## 方式二：8GB 显卡直接加载 Q4＋LoRA

这条路径不要求在本机合并 27B BF16。使用匹配底座的 Q4 GGUF 和 `lora-round2.gguf`，由 llama.cpp 动态应用 LoRA。

上游模型卡链接的对应 [DavidAU GGUF 发布页](https://huggingface.co/DavidAU/Qwen3.8-27B-TURBO-Fable-Cold-Fusion-735-882-Heretic-Uncensored-NEO-CODER-MAX-MTP-GGUF/tree/main) 提供 Q4_K_M 文件，可自行下载；作者的量化版本与本项目此前自行转换的 Q4 不保证逐位一致，尚未在此第三方 Q4 上完成端到端验证。

1. 下载匹配底座的 Q4 GGUF，放到项目根目录并命名为 `base-Q4_K_M.gguf`；同时放置 `lora-round2.gguf`。
2. 使用完整启动包；如果下载的是仓库源码，先执行 `pwsh -File ./安装运行时.ps1`。
3. 双击 `8GB-启动包/启动8GB.cmd`，加载完成后打开 **http://127.0.0.1:8087**。

默认 GPU 20 层、4096 上下文；显存不足时用 `显存紧张用这个.cmd`（16 层、2048 上下文）。推荐 **32GB 或更多系统内存**。这是 GPU＋内存混合推理，不是全部塞进 8GB 显存；未在实体 8GB 显卡做完整生成实测。

也可以显式指定文件：

```powershell
pwsh -File ./8GB-启动包/启动8GB.ps1 -Model D:/models/base.gguf -Adapter ./lora-round2.gguf
```

## 来源、许可与实验范围

- 直接底座和 Qwen 祖先均声明 Apache-2.0。本仓库脚本采用 Apache-2.0，保留 [LICENSE](LICENSE) 和 [NOTICE](NOTICE)。
- llama.cpp 运行时采用 MIT，自带 OpenMP 许可证保留。
- 它是小样本前端实验，不是从零训练或官方 Qwen 模型。
- 不以少量精选示例声称通用能力全面提升；详见 [模型说明](MODEL_CARD.md)。

## LoRA 校验

```text
49e2a6d9f4a262c2992126e62bfd62be9394b962bbb83ec47a0dff47ba71b990  adapter_model.safetensors
e5ffa103dccd82f853f2e6b32f89e89a7a11b830f4adbbdba2b639232b568275  lora-round2.gguf
```

