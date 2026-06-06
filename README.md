# llama.cpp MTP Optimization

Benchmark y optimización de modelos GGUF con MTP (Multi-Token Prediction).

**Hardware:** RTX 5060 Ti 16GB

## Estructura

```
project/
├── scripts/       # Scripts de ejecución (config óptima)
├── benchmarks/    # Scripts de benchmarking
└── README.md
```

## Modelos en llama.cpp

Los modelos se almacenan en: `/home/diegovelezg/llama.cpp/models/`

## Próximos pasos

1. Descargar modelos a probar
2. Crear benchmarks
3. Crear scripts de ejecución
4. Documentar resultados


llama-server.exe ^

:: =========================================================
:: MODELO
:: =========================================================

:: Modelo principal desde Hugging Face
:: Descarga y cachea automáticamente el GGUF
-hf unsloth/Qwen3.5-9B-MTP-GGUF:Qwen3.5-9B-Q8_0.gguf ^

:: Archivo multimodal projector (visión)
:: Convierte embeddings visuales -> embeddings del LLM
-hf-file mmproj-F16.gguf ^


:: =========================================================
:: GPU / MEMORIA
:: =========================================================

:: Envía todas las capas posibles a GPU
-ngl 99 ^

:: Activa Flash Attention
:: Menos VRAM + más velocidad
-fa on ^

:: KV cache para KEYS en q8_0
:: Reduce VRAM
-ctk q8_0 ^

:: KV cache para VALUES en q8_0
:: Reduce VRAM
-ctv q8_0 ^

:: KV cache unificada/optimizada
:: Mejor manejo de contexto grande
-kvu ^

:: RAM auxiliar reservada para contexto/KV cache
:: 8192 MB = 8 GB
-cram 8192 ^


:: =========================================================
:: CONTEXTO
:: =========================================================

:: Tamaño máximo de contexto (8k tokens)
-c 8192 ^

:: Número de slots/contextos paralelos
-np 1 ^


:: =========================================================
:: VISIÓN
:: =========================================================

:: Tokens visuales mínimos por imagen
:: Más alto = más detalle visual + más VRAM/cómputo
--image-min-tokens 1024 ^


:: =========================================================
:: SPECULATIVE DECODING / MTP
:: =========================================================

:: Speculative decoding usando MTP
:: Genera varios tokens adelantados
--spec-type draft-mtp ^

:: Máximo de draft/speculative tokens por iteración
:: Más alto puede acelerar más
--spec-draft-n-max 6 ^


:: =========================================================
:: REASONING
:: =========================================================

:: Activa reasoning mode del modelo
--reasoning on
