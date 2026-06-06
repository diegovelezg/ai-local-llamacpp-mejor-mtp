#!/bin/bash
# Qwen3.5-27B-MTP-GGUF Q3_K_M - Config óptima
# Modelo más grande con cuantización ligera para mejor calidad
# --ctx-size 8192 | 16384 | 32768 | 65536 | 131072 |
#     --cache-type-k q5_0 \ --cache-type-v q5_0 \

SERVER="$HOME/llama.cpp/build/bin/llama-server"
PORT="${1:-8080}"

$SERVER \
    -hf unsloth/Qwen3.5-27B-MTP-GGUF:Q3_K_M \
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
    --ctx-size 8192 \
    --cache-type-k q4_0 \
    --cache-type-v q4_0 \
    --flash-attn on \
    --spec-type draft-mtp \
    --spec-draft-n-max 2 \
