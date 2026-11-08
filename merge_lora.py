"""Merge the frontend PEFT adapter into the original BF16 HF base, on CPU."""
# Copyright 2026 SnowSalt. SPDX-License-Identifier: Apache-2.0
import argparse
import hashlib
import json
from pathlib import Path

BASE_ID = 'DavidAU/Qwen3.8-27B-TURBO-Fable-Cold-Fusion-735-882-Heretic-Uncensored-NM-DAU'
ADAPTER_SHA = '49e2a6d9f4a262c2992126e62bfd62be9394b962bbb83ec47a0dff47ba71b990'
CONFIG_SHA = '56ef632a7c37c40046addbcd09ceeab88c26722a7c385e7d5604a2eb4c55c96d'

def sha256(path):
    h = hashlib.sha256()
    with path.open('rb') as f:
        for block in iter(lambda: f.read(8 * 1024**2), b''):
            h.update(block)
    return h.hexdigest()

def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--base', type=Path, required=True, help='Original BF16 HF directory, not a GGUF')
    p.add_argument('--adapter', type=Path, default=Path('adapter'))
    p.add_argument('--output', type=Path, default=Path('merged-hf'))
    p.add_argument('--check-only', action='store_true', help='Check inputs without loading 27B weights')
    a = p.parse_args()
    cfg = json.loads((a.adapter / 'adapter_config.json').read_text(encoding='utf-8-sig'))
    if cfg.get('base_model_name_or_path') != BASE_ID:
        raise SystemExit('Unexpected adapter/base identity')
    if sha256(a.adapter / 'adapter_model.safetensors') != ADAPTER_SHA:
        raise SystemExit('Adapter SHA256 mismatch')
    if sha256(a.base / 'config.json') != CONFIG_SHA:
        raise SystemExit('Base config differs from the verified training config; use download_base.py')
    if a.output.exists() and any(a.output.iterdir()):
        raise SystemExit('Output directory is not empty; choose a new directory')
    print('Input checks passed. CPU BF16 merge: allow roughly 64GB+ RAM; 96GB recommended.', flush=True)
    if a.check_only:
        return

    import torch
    from safetensors import safe_open
    from transformers import AutoModelForCausalLM, AutoTokenizer
    from peft import PeftModel

    model = AutoModelForCausalLM.from_pretrained(
        str(a.base), dtype=torch.bfloat16, device_map='cpu',
        low_cpu_mem_usage=True, local_files_only=True, trust_remote_code=False,
    )
    # Training attached PEFT to the full CausalLM, not to an inner language_model.
    modules = set(dict(model.named_modules()))
    with safe_open(str(a.adapter / 'adapter_model.safetensors'), framework='pt', device='cpu') as f:
        targets = {k.removeprefix('base_model.model.').split('.lora_')[0] for k in f.keys()}
    missing = sorted(targets - modules)
    if missing:
        raise RuntimeError('Base/adapter module layout mismatch: ' + ', '.join(missing[:8]))
    model = PeftModel.from_pretrained(model, str(a.adapter), is_trainable=False, local_files_only=True)
    print('Merging LoRA...', flush=True)
    model = model.merge_and_unload(safe_merge=True)
    model.config.use_cache = True
    a.output.mkdir(parents=True, exist_ok=True)
    model.save_pretrained(str(a.output), safe_serialization=True, max_shard_size='5GB')
    tokenizer = AutoTokenizer.from_pretrained(str(a.base), local_files_only=True, trust_remote_code=False)
    tokenizer.save_pretrained(str(a.output))
    receipt = dict(base=BASE_ID, adapter_sha256=ADAPTER_SHA, dtype='bfloat16',
                   method='PEFT merge_and_unload(safe_merge=True)', text_only=True)
    (a.output / 'merge_receipt.json').write_text(json.dumps(receipt, indent=2)+'\n', encoding='utf-8')
    print('Merged HF model saved:', a.output)

if __name__ == '__main__':
    main()
