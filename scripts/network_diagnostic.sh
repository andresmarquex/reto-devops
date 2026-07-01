#!/bin/bash
# network_diagnostic.sh - Automatización de diagnóstico de latencia multiregión

TARGETS=("us-east-1.amazonaws.com" "eu-west-1.amazonaws.com" "sa-east-1.amazonaws.com")
LOG_FILE="network_report_$(date +%Y%m%d_%H%M%S).log"

echo "==================================================" | tee -a "$LOG_FILE"
echo "🚀 INICIANDO DIAGNÓSTICO DE LATENCIA MULTI-REGIÓN" | tee -a "$LOG_FILE"
echo "📅 Fecha: $(date)" | tee -a "$LOG_FILE"
echo "==================================================" | tee -a "$LOG_FILE"

for host in "${TARGETS[@]}"; do
    echo -e "\n🔍 Evaluando conectividad hacia: $host" | tee -a "$LOG_FILE"
    
    # 1. Validar resolución DNS
    if nslookup "$host" > /dev/null 2>&1; then
        echo "✅ Resolución DNS: OK" | tee -a "$LOG_FILE"
    else
        echo "❌ Resolución DNS: FALLIDA" | tee -a "$LOG_FILE"
        continue
    fi

    # 2. Medir Latencia Promedio (Ping)
    PING_RES=$(ping -c 4 "$host" | tail -1 | awk -F '/' '{print $5}')
    if [ -z "$PING_RES" ]; then
        echo "❌ Host inalcanzable por ICMP" | tee -a "$LOG_FILE"
    else
        echo "⚡ Latencia promedio: ${PING_RES} ms" | tee -a "$LOG_FILE"
    fi

    # 3. MTR rápido (3 saltos) para trazabilidad en caso de alta latencia (>150ms)
    echo "🛤️ Trazabilidad de ruta rápida (MTR):" | tee -a "$LOG_FILE"
    mtr -c 3 -r -w "$host" | tail -n +2 | head -n 5 >> "$LOG_FILE"
done

echo -e "\n📊 Reporte guardado con éxito en: $LOG_FILE"