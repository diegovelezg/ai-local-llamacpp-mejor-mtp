#!/bin/bash
# Qwen3.5-4B-MTP-GGUF UD-Q8_K_XL - Config óptima
# Unsloth Dynamic 2.0 - máxima precisión para 4B
# 8192 - 65536
#     --ctx-size 262144 \
#     --cache-type-k q8_0 \
#     --cache-type-v q8_0 \

# Limitar consumo de GPU a 150W
sudo nvidia-smi -pl 150

SERVER="$HOME/llama.cpp/build/bin/llama-server"
PORT="${1:-8080}"

$SERVER \
    -hf unsloth/Qwen3.5-2B-MTP-GGUF:UD-Q4_K_XL \
    --no-mmproj \
    --port $PORT \
    --parallel 1 \
    --reasoning off \
    --temp 1.0 \
    --top-k 20 \
    --top-p 0.95 \
    --min-p 0.0 \
    --repeat-penalty 1.0 \
    --presence-penalty 1.5 \
    --n-gpu-layers 99 \
    --no-mmap \
    --mlock \
    -c 65536 \
    --cache-type-k q8_0 \
    --cache-type-v q8_0 \
    --flash-attn on \
    --spec-type draft-mtp \
    --spec-draft-n-max 2 \
    --no-context-shift
