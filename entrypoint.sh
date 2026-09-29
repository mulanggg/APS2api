#!/bin/bash
set -e

# 1. 确保配置存放目录及状态目录存在
mkdir -p /app/config/state

# 2. 注入规则同意凭据（当前版本的规则哈希为 36800adeec862126）
RULE_HASH="36800adeec862126"
echo "$RULE_HASH" > /app/config/state/agreed-rules-docker.txt
echo -e "$(date -u +'%Y-%m-%dT%H:%M:%SZ')\t$RULE_HASH" > /app/config/state/.rules_agreed

# 3. 若未检测到配置文件，则从系统备用区初始化默认配置
if [ ! -f "$VPROXY_CONFIG" ]; then
    echo "[Entrypoint] 未检测到 config.json，正在初始化默认配置..."
    cp /app/config.example.json "$VPROXY_CONFIG"
fi

# 4. 如果 Render 注入了自定义 PORT，自动同步至 config.json 保证端口连通
if [ -n "$PORT" ] && [ -f "$VPROXY_CONFIG" ]; then
    echo "[Entrypoint] 适配平台指定 PORT=$PORT..."
    sed -i "s/\"port_api\": [0-9]*/\"port_api\": $PORT/" "$VPROXY_CONFIG"
fi

if [ ! -f "$VPROXY_API_KEYS" ]; then
    echo "[Entrypoint] 未检测到 api_keys.txt，正在初始化默认密钥..."
    cp /app/api_keys.example.txt "$VPROXY_API_KEYS"
fi

if [ ! -f "$VPROXY_MODELS" ]; then
    echo "[Entrypoint] 未检测到 models.json，正在初始化模型清单..."
    cp /app/models.json "$VPROXY_MODELS"
fi

# 5. 启动 Vertex AI Proxy 服务
echo "[Entrypoint] 规则已确认，启动 Vertex AI Proxy 服务..."
exec /app/vproxy
