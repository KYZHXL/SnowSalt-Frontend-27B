# 模型说明

## 来源与修改

- 发布名：SnowSalt Frontend 27B LoRA，实验预览。
- 直接训练底座：`DavidAU/Qwen3.8-27B-TURBO-Fable-Cold-Fusion-735-882-Heretic-Uncensored-NM-DAU`。
- 上游标注祖先：`Qwen/Qwen3.8-27B`；GGUF 架构标记为 `qwen35`。
- 本次修改：前端任务 LoRA 第二轮训练、合并 BF16 权重、Q4_K_M 量化、Windows 混合运行脚本。
- 已保存上游当前模型卡和查询快照。快照 revision 仅表示许可证检查时的版本；历史训练配置没有固定 revision，不能将其冒称训练时的精确提交。

## 训练记录

| 项 | 第二轮记录 |
|---|---:|
| 训练样本 | 170 |
| 输入 tokens | 503,217 |
| 监督 labels | 474,965 |
| 验证样本 | 23 |
| 验证输入 tokens | 75,016 |
| 最大序列长度 | 4096 |
| 训练样本达到截断长度 | 11 |
| LoRA rank / alpha | 16 / 32 |
| LoRA dropout | 0 |
| 优化器更新步数 | 42 |

目标模块：q_proj、k_proj、v_proj、o_proj、gate_proj、up_proj、down_proj。该表是数据清单和训练记录，不代表训练使用了公开认证基准，也不代表全部输入 tokens 都参与损失。

样本是前端代码任务；此仓库不分发训练原文、账户记录或原始运行日志。

## 发布格式

本次仅发布第二轮 PEFT LoRA（FP32 Safetensors）和转换后的 F16 GGUF LoRA，不发布底座或合并Q4。PEFT配置中的本机路径已替换为公开底座ID。既有Q4导出记录只用于追溯，此次不是重新合并整模型。

## 运行与验证范围

权重已从训练机下载，源和目的 SHA256 一致。官方 llama.cpp b12110 Vulkan Windows x64 下载包 SHA256 已验证；启动参数、设备枚举与 PowerShell CheckOnly 已验证。未在物理 8GB GPU 上进行完整模型生成测试。

默认 20 层权重约 4.41GiB 是权重估算，不是完整显存占用；实际还包括缓存、计算缓冲与显示占用。默认上下文 4096，回退 2048。运行时关闭 reasoning，不承诺该选项能提升输出质量。

这是小样本前端实验，未证实在小说、推理、工具调用等任务上有提升。当前发布不包含视觉投影，也不声称保留上游完整多模态功能。演示应展示实际输入、完整输出和运行设置，不把精选个例当总体胜率。


公开GGUF LoRA删除了导出器写入的本机repo_url与tags，更新了名称和公开描述；512个tensor逐个SHA与原始导出完全一致。公开文件SHA：e5ffa103dccd82f853f2e6b32f89e89a7a11b830f4adbbdba2b639232b568275。
