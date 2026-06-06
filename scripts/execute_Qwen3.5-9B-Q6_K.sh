#!/bin/bash
# Qwen3.5-9B-MTP-GGUF Q6_K - Config óptima
# Más ligero que Q8_0, menor VRAM

SERVER="$HOME/llama.cpp/build/bin/llama-server"
PORT="${1:-8080}"

$SERVER \
    -hf unsloth/Qwen3.5-9B-MTP-GGUF:Q6_K \
    -ngl 99 \
    -fa on \
    -ctk q8_0 \
    -ctv q8_0 \
    -kvu \
    -cram 131072 \
    -c 262144 \
    -np 1 \
    --image-min-tokens 1024 \
    --spec-type draft-mtp \
    --spec-draft-n-min 0 \
    --spec-draft-n-max 3 \
    --reasoning on \
    --port $PORT

# PARÁMETROS:
# -hf: modelo desde Hugging Face (Q6_K ~7 GB)
# -ngl 99: todas las capas a GPU
# -fa on: Flash Attention
# -ctk/q8_0 -ctv/q8_0: KV cache cuantizada
# -kvu: KV cache unificada
# -cram 8192: RAM auxiliar (8 GB)
# -c 16384: contexto 16k
# -np 1: 1 slot paralelo
# --spec-type draft-mtp: speculative decoding MTP
# --spec-draft-n-max 3: máximo draft tokens
# --reasoning on: modo thinking
