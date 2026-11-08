# 发布检查 · 2026-11-08

当前范围：仅 LoRA、启动脚本和合并工具。不上传底座或已合并权重。

## 已核对

- 训练适配器的直接底座为 DavidAU/Qwen3.8-27B-TURBO-Fable-Cold-Fusion-735-882-Heretic-Uncensored-NM-DAU，祖先为 Qwen/Qwen3.8-27B。
- 两者公开声明 Apache-2.0；Qwen LICENSE 全文与 DavidAU 模型卡已保留，并附 NOTICE 与修改说明。
- DavidAU检查快照fd6a26869dc5775b3c81ce65468af634dd300b02的config.json与训练机文件SHA一致。这个快照用于可复现下载，不冒称已核验全部训练权重与历史revision逐字节一致。
- PEFT和原始GGUF LoRA从训练机下载后SHA256一致。公开GGUF随后移除了含本机路径的两个元数据字段，并验证512个tensor载荷逐个SHA不变；最终文件哈希以Release清单为准。公开adapter_config中的本机路径已替换为公开底座ID。
- 原模型分卷上传已取消，Draft中的未完成分卷已删除；公开Git历史没有底座/模型分卷或凭据。
- llama.cpp运行时MIT和自带OpenMP许可证保留。合并/下载脚本及文档采用Apache-2.0。

## 验证边界

脚本完成语法、接口、输入SHA检查；此次不重复进行昂贵的整27B合并。原有导出流水线曾完成该LoRA的BF16 GGUF合并和Q4量化，但不等于新HF合并脚本已做同规模端到端验证。8GB硬件推理和作者另发的NEO Q4＋本LoRA组合仍未实测。

许可证来源：[Qwen LICENSE](https://huggingface.co/Qwen/Qwen3.8-27B/blob/main/LICENSE)、[DavidAU模型卡](https://huggingface.co/DavidAU/Qwen3.8-27B-TURBO-Fable-Cold-Fusion-735-882-Heretic-Uncensored-NM-DAU)、[Apache-2.0](https://www.apache.org/licenses/LICENSE-2.0)。



