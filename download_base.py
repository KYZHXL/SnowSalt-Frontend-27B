"""Download the specific HF base used by this adapter; supports HF cache resume."""
# Copyright 2026 SnowSalt. SPDX-License-Identifier: Apache-2.0
import argparse

REPO = 'DavidAU/Qwen3.8-27B-TURBO-Fable-Cold-Fusion-735-882-Heretic-Uncensored-NM-DAU'
REVISION = 'fd6a26869dc5775b3c81ce65468af634dd300b02'

def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--output', default='base-model')
    p.add_argument('--workers', type=int, default=4)
    args = p.parse_args()
    from huggingface_hub import snapshot_download
    path = snapshot_download(
        repo_id=REPO, revision=REVISION, local_dir=args.output,
        max_workers=args.workers,
        allow_patterns=['*.safetensors', '*.json', '*.jinja', 'vocab.*', 'merges.txt',
                        'tokenizer.*', '*.model', 'README.md', 'LICENSE*', 'NOTICE*'],
    )
    print('Base downloaded:', path)

if __name__ == '__main__':
    main()
