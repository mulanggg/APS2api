#!/bin/bash
set -e

# 确保配置与状态目录存在
mkdir -p /app/config/state

# 自动注入规则同意凭据（填入官方规则哈希，彻底解决 EOF 崩溃退出）
RULE_HASH="36800adeec862126"
echo "$RULE_HASH" > /app/config/state/agreed-rules-docker.txt
echo -e "$(date -u +'%Y-%m-%dT%H:%M:%SZ')\t$RULE_HASH" > /app/config/state/.rules_agreed

# 若未检测到配置文件，初始化默认配置
if [ ! -f "$VPROXY_CONFIG" ]; then
    echo "[Entrypoint] 未检测到 config.json，正在初始化默认配置..."
    cp /app/config.example.json "$VPROXY_CONFIG"
fi

# 适配 Render 动态分配的端口
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

# 启动服务
echo "[Entrypoint] 规则已确认通过，启动 Vertex AI Proxy 服务..."
exec /app/vproxy
