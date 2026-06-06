#!/bin/bash
# Qwen3.5-9B-MTP-GGUF UD-Q5_K_XL - Config óptima
# Unsloth Dynamic 2.0 - mejor precisión con tamaño reducido
# --ctx-size 65536 | 131072 | 262144 | 524288 (con --rope-scaling yarn \ --rope-factor 4.0 \ porque es ,más del cache nativo)

SERVER="$HOME/llama.cpp/build/bin/llama-server"
PORT="${1:-8080}"

$SERVER \
    -hf unsloth/Qwen3.5-9B-MTP-GGUF:UD-Q5_K_XL \
    --no-mmproj \
    --port $PORT \
    --parallel 1 \
    --reasoning on \
    --temp 1.0 \
    --top-k 20 \
    --top-p 0.95 \
    --min-p 0.0 \
    --repeat-penalty 1.0 \
    --presence-penalty 1.5 \
    --n-gpu-layers 99 \
    --no-mmap \
    --mlock \
    --ctx-size 262144 \
    --cache-type-k q8_0 \
    --cache-type-v q8_0 \
    --flash-attn on \
    --spec-type draft-mtp \
    --spec-draft-n-max 2 \
