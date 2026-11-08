# v0.1.0-preview · Frontend LoRA

状态：已公开发布，tag `v0.1.0-preview`。

本次仅提供前端 LoRA 和工具，不包含 27B 底座或合并权重。

- PEFT adapter（约319MB原始权重）与 GGUF adapter（约159MB）。
- 准确底座下载脚本，支持 Hugging Face 缓存续传。
- CPU BF16 合并脚本，输出 HF Safetensors。
- Windows 8GB GPU＋系统内存混合启动包，支持 Q4 底座＋独立 LoRA。
- 许可、来源、SHA256与安装说明齐备，敏感路径与凭据已排除。

模型底座：DavidAU/Qwen3.8-27B-TURBO-Fable-Cold-Fusion-735-882-Heretic-Uncensored-NM-DAU。
不能用普通 Qwen3.8-27B 或其他同尺寸模型随意替代。
合并脚本完成接口/输入检查，未在此次打包中额外执行完整27B合并；8GB物理显卡亦未端到端实测。
