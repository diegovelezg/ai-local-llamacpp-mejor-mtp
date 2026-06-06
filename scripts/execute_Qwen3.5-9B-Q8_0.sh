#!/bin/bash
# Qwen3.5-9B-MTP-GGUF Q8_0 - Config óptima
# Benchmark ganador: spec-draft-n-max=2 → 40,430 t/s

SERVER="$HOME/llama.cpp/build/bin/llama-server"
PORT="${1:-8080}"

$SERVER \
    -hf unsloth/Qwen3.5-9B-MTP-GGUF:Q8_0 \
    --n-gpu-layers 999 \
    --flash-attn on \
    --spec-type draft-mtp \
    --spec-draft-n-max 3 \
    --reasoning on \
    --parallel 1 \
    --port $PORT \
    --no-mmproj
