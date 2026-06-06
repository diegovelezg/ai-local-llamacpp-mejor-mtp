#!/bin/bash

# Stress test para encontrar límite de contexto
PORT=8080
BASE_URL="http://localhost:$PORT/v1"

# Tamaños de prueba en tokens (aprox)
SIZES=(1000 2000 4000 8000 12000 16000 20000 24000 28000 32000)

echo "🧪 Stress Test - Límite de Contexto"
echo "===================================="
echo ""

for size in "${SIZES[@]}"; do
    echo "📝 Probando con ~$size tokens..."

    # Generar texto repetitivo (~4 chars = 1 token aprox)
    TEXT=$(printf "Hola mundo. " $((size / 3)))

    RESPONSE=$(curl -s "$BASE_URL/chat/completions" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer EMPTY" \
        -d "{
            \"model\": \"Qwen3.5\",
            \"messages\": [{\"role\": \"user\", \"content\": \"$TEXT\"}],
            \"max_tokens\": 100,
            \"stream\": false
        }" 2>&1)

    if echo "$RESPONSE" | grep -q "error"; then
        echo "❌ FAIL en $size tokens"
        echo "$RESPONSE" | grep -o '"error":"[^"]*"' | head -1
        echo ""
        echo "🛑 Límite encontrado: ~$((size / 2)) tokens"
        break
    else
        echo "✅ OK - $size tokens funcionó"

        # Chequear VRAM después de cada prueba
        VRAM=$(nvidia-smi --query-gpu=memory.used --format=csv,noheader,nounits | head -1)
        echo "   VRAM: ${VRAM} MiB"
        echo ""
    fi

    sleep 1
done

echo ""
echo "📊 VRAM final:"
nvidia-smi --query-gpu=memory.used,memory.free --format=csv
