#!/bin/bash
# Benchmark Qwen3.5-9B-MTP-GGUF Q8_0 con llama-server
# Prueba lineal de --spec-draft-n-max en un rango configurable

# USO: ./test_9b_q8.sh [MIN] [MAX]
# Ejemplo: ./test_9b_q8.sh 1 10  ← prueba del 1 al 10

SERVER="$HOME/llama.cpp/build/bin/llama-server"
MODEL="$HOME/llama.cpp/models/Qwen3.5-9B-Q8_0.gguf"
OUTPUT_DIR="benchmarks/results/Qwen3.5-9B-Q8_0"
mkdir -p "$OUTPUT_DIR"

PORT=8080
PROMPT="Explain briefly what is speculative decoding in AI."

MIN_N="${1:-1}"
MAX_N="${2:-5}"

echo "=========================================="
echo "BENCHMARK: Qwen3.5-9B-Q8_0 (llama-server)"
echo "Prueba: spec-draft-n-max [$MIN_N .. $MAX_N]"
echo "=========================================="
echo ""

RESULTS=()
PREV_TPS=0
BEST_TPS=0
BEST_N=0

for n in $(seq $MIN_N $MAX_N); do
    echo "----------------------------------------"
    echo "Test: spec-draft-n-max = $n"
    echo "----------------------------------------"

    # Iniciar servidor
    $SERVER \
        -m "$MODEL" \
        -ngl 99 \
        -fa on \
        -ctk q8_0 \
        -ctv q8_0 \
        -kvu \
        -cram 8192 \
        -c 8192 \
        -np 1 \
        --image-min-tokens 1024 \
        --spec-type draft-mtp \
        --spec-draft-n-max $n \
        --reasoning on \
        --port $PORT \
        > /dev/null 2>&1 &

    SERVER_PID=$!

    # Esperar que el servidor inicie
    sleep 10

    # Hacer petición y medir tiempo
    START_TIME=$(date +%s.%N)

    RESPONSE=$(curl -s http://localhost:$PORT/v1/chat/completions \
        -H "Content-Type: application/json" \
        -d "{
            \"model\": \"$MODEL\",
            \"messages\": [{\"role\": \"user\", \"content\": \"$PROMPT\"}],
            \"max_tokens\": 128
        }")

    END_TIME=$(date +%s.%N)

    # Matar servidor
    kill $SERVER_PID 2>/dev/null
    wait $SERVER_PID 2>/dev/null

    # Extraer t/s de la respuesta
    TPS=$(echo "$RESPONSE" | grep -oP '"tokens_per_second":\s*[0-9.]+' | grep -oP '[0-9.]+' | head -1)

    # Si no hay tps en response, calcular manualmente
    if [ -z "$TPS" ]; then
        ELAPSED=$(awk "BEGIN {print $END_TIME - $START_TIME}")
        TPS=$(awk "BEGIN {printf \"%.2f\", 128 / $ELAPSED}")
    fi

    if [ -z "$TPS" ] || [ "$TPS" = "0" ]; then
        echo "Result: ERROR"
        RESULTS+=("$n|ERROR")
        break
    fi

    echo "Result: $TPS t/s"
    RESULTS+=("$n|$TPS")

    # Actualizar mejor
    if (( $(awk "BEGIN {print ($TPS > $BEST_TPS)}") )); then
        BEST_TPS=$TPS
        BEST_N=$n
    fi

    # Parar si baja (opcional - comentar si no quieres)
    # if [ -n "$PREV_TPS" ] && (( $(awk "BEGIN {print ($TPS < $PREV_TPS)}") )); then
    #     echo ""
    #     echo "⚠️  Velocidad descendió. Parando."
    #     break
    # fi

    PREV_TPS=$TPS
    echo ""
    sleep 2
done

echo "=========================================="
echo "GANADOR: spec-draft-n-max = $BEST_N"
echo "Velocidad: $BEST_TPS t/s"
echo "=========================================="
echo ""

for line in "${RESULTS[@]}"; do
    n=$(echo "$line" | cut -d'|' -f1)
    tps=$(echo "$line" | cut -d'|' -f2)
    printf "n-max=%-2s | %10s t/s\n" "$n" "$tps"
done | tee "$OUTPUT_DIR/results.txt"
