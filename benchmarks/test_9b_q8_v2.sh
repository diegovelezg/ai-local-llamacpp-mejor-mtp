#!/bin/bash
# Benchmark Qwen3.5-9B-MTP-GGUF Q8_0 con llama-server b9543
# Fixed: lee timings.predicted_per_second (API nueva)

# USO: ./test_9b_q8_v2.sh [MIN] [MAX]
# Ejemplo: ./test_9b_q8_v2.sh 1 8  ← prueba del 1 al 8

SERVER="$HOME/llama.cpp/build/bin/llama-server"
MODEL="$HOME/llama.cpp/models/Qwen3.5-9B-Q8_0.gguf"
OUTPUT_DIR="benchmarks/results/Qwen3.5-9B-Q8_0"
mkdir -p "$OUTPUT_DIR"

PORT=18090
PROMPT="Explain briefly what is speculative decoding in AI."

MIN_N="${1:-1}"
MAX_N="${2:-6}"

echo "=========================================="
echo "BENCHMARK: Qwen3.5-9B-Q8_0 (b9543)"
echo "Prueba: spec-draft-n-max [$MIN_N .. $MAX_N]"
echo "=========================================="
echo ""

declare -A RESULTS

for n in $(seq $MIN_N $MAX_N); do
    echo "----------------------------------------"
    echo "Test: spec-draft-n-max = $n"
    echo "----------------------------------------"

    $SERVER \
        -m "$MODEL" \
        -ngl 999 \
        -fa on \
        -ctk q8_0 \
        -ctv q8_0 \
        -kvu \
        -cram 8192 \
        -c 8192 \
        -np 1 \
        --spec-type draft-mtp \
        --spec-draft-n-max $n \
        --reasoning on \
        --port $PORT \
        > /tmp/llama_bench_n${n}.log 2>&1 &

    SERVER_PID=$!
    sleep 12

    RESPONSE=$(curl -s http://localhost:$PORT/v1/chat/completions \
        -H "Content-Type: application/json" \
        -d "{
            \"model\": \"any\",
            \"messages\": [{\"role\": \"user\", \"content\": \"$PROMPT\"}],
            \"max_tokens\": 256
        }")

    kill $SERVER_PID 2>/dev/null
    wait $SERVER_PID 2>/dev/null

    TPS=$(echo "$RESPONSE" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    t = d.get('timings', {})
    print(f\"{t.get('predicted_per_second', 0):.2f}\")
except:
    print('0.00')
" 2>/dev/null)

    ACCEPT=$(grep -oE "draft acceptance = [0-9.]+" /tmp/llama_bench_n${n}.log | tail -1 | awk '{print $4}')

    if [ -z "$TPS" ] || [ "$TPS" = "0.00" ]; then
        echo "Result: ERROR"
        RESULTS[$n]="ERROR"
    else
        echo "Result: $TPS t/s | acceptance: $ACCEPT"
        RESULTS[$n]="$TPS | acc=$ACCEPT"
    fi
    echo ""
    sleep 2
done

echo "=========================================="
echo "RESULTADOS b9543:"
echo "=========================================="
BEST_TPS=0
BEST_N=0
for n in $(seq $MIN_N $MAX_N); do
    r="${RESULTS[$n]}"
    if [ "$r" != "ERROR" ]; then
        TPS=$(echo "$r" | awk '{print $1}')
        printf "n-max=%-2s | %10s t/s | %s\n" "$n" "$TPS" "$(echo $r | cut -d'|' -f2)"
        IS_BEST=$(awk "BEGIN {print ($TPS > $BEST_TPS)}")
        if [ "$IS_BEST" = "1" ]; then
            BEST_TPS=$TPS
            BEST_N=$n
        fi
    else
        printf "n-max=%-2s | ERROR\n" "$n"
    fi
done
echo ""
echo "GANADOR: spec-draft-n-max = $BEST_N → $BEST_TPS t/s"

{
    echo "# Benchmark Qwen3.5-9B-Q8_0 con llama.cpp b9543"
    echo "# Date: $(date)"
    echo "# GPU: RTX 5060 Ti 16GB | CUDA 13.3"
    echo "# Config: ngl=999, fa=on, ctk=q8_0, ctv=q8_0, kvu=on, cram=8192, c=8192, np=1"
    echo "# Prompt: '$PROMPT'"
    echo "# max_tokens: 256"
    echo ""
    for n in $(seq $MIN_N $MAX_N); do
        r="${RESULTS[$n]}"
        if [ "$r" != "ERROR" ]; then
            TPS=$(echo "$r" | awk '{print $1}')
            ACC=$(echo "$r" | grep -oE "acc=[0-9.]+" | cut -d= -f2)
            printf "n-max=%-2s | %10s t/s | acceptance=%s\n" "$n" "$TPS" "$ACC"
        else
            printf "n-max=%-2s | ERROR\n" "$n"
        fi
    done
} | tee "$OUTPUT_DIR/results_b9543.txt"
