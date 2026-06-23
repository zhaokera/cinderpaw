#!/bin/bash
# 启动 DashScope 图片代理
# 用法: bash tools/start-proxy.sh [start|stop|status|restart]

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROXY_SCRIPT="$SCRIPT_DIR/dashscope-proxy.py"
PID_FILE="$SCRIPT_DIR/.proxy.pid"
PORT=9191

start() {
    if [ -f "$PID_FILE" ]; then
        local pid=$(cat "$PID_FILE")
        if kill -0 "$pid" 2>/dev/null; then
            echo "代理已在运行 (PID: $pid)"
            return 0
        else
            rm -f "$PID_FILE"
        fi
    fi

    echo "启动 DashScope 图片代理..."
    python3 "$PROXY_SCRIPT" --port "$PORT" &
    sleep 1

    if [ -f "$PID_FILE" ]; then
        local pid=$(cat "$PID_FILE")
        if kill -0 "$pid" 2>/dev/null; then
            echo "✅ 代理已启动 (PID: $pid, 端口: $PORT)"
            echo ""
            echo "下一步: 修改 ~/.claude/settings.json 中的 ANTHROPIC_BASE_URL:"
            echo "  \"ANTHROPIC_BASE_URL\": \"http://localhost:$PORT\""
            return 0
        fi
    fi
    echo "❌ 启动失败"
    return 1
}

stop() {
    if [ -f "$PID_FILE" ]; then
        local pid=$(cat "$PID_FILE")
        if kill -0 "$pid" 2>/dev/null; then
            kill "$pid"
            echo "✅ 代理已停止 (PID: $pid)"
        else
            echo "代理进程不存在"
        fi
        rm -f "$PID_FILE"
    else
        echo "没有找到 PID 文件，代理可能未运行"
    fi
}

status() {
    if [ -f "$PID_FILE" ]; then
        local pid=$(cat "$PID_FILE")
        if kill -0 "$pid" 2>/dev/null; then
            echo "✅ 代理运行中 (PID: $pid, 端口: $PORT)"
            curl -s "http://localhost:$PORT/health" 2>/dev/null && echo "" || echo "(无法连接)"
            return 0
        fi
    fi
    echo "❌ 代理未运行"
    return 1
}

case "${1:-start}" in
    start)   start ;;
    stop)    stop ;;
    restart) stop; sleep 1; start ;;
    status)  status ;;
    *)       echo "用法: $0 {start|stop|restart|status}" ;;
esac
