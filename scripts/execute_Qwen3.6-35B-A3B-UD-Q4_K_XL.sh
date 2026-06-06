#!/bin/bash
# https://unsloth.ai/docs/models/qwen3.6
# Qwen3.6-35B-A3B-MTP-GGUF UD-Q4_K_XL - Config óptima
# MoE (Mixture of Experts) 35B - requiere offload de expertos

SERVER="$HOME/llama.cpp/build/bin/llama-server"
PORT="${1:-8080}"

$SERVER \
    -hf unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL \
    -ngl 25 \
    --n-cpu-moe 5 \
    --ctx-size 65536 \
    --ctx-checkpoints 4\
    --cache-type-k q8_0 \
    --cache-type-v q8_0 \
    -cram 8192 \
    --flash-attn on \
    --spec-type draft-mtp \
    --spec-draft-n-max 1 \
    --no-mmproj \
