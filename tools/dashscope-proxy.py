#!/usr/bin/env python3
"""
DashScope Image Proxy for Claude Code

拦截 Claude Code → DashScope 的请求，将 image content block 转换为文本描述，
解决 DashScope 不支持 image block 导致的 400 错误。

用法:
  python3 tools/dashscope-proxy.py [--port 9191]

然后将 ANTHROPIC_BASE_URL 设置为 http://localhost:9191
"""

import argparse
import json
import sys
import signal
from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.request import Request, urlopen
from urllib.error import HTTPError, URLError
import ssl
import os

_config = {
    "upstream_url": "https://dashscope.aliyuncs.com/apps/anthropic",
    "listen_port": 9191,
}
PID_FILE = os.path.join(os.path.dirname(os.path.abspath(__file__)), ".proxy.pid")


def clean_content_blocks(content):
    """递归清理 content blocks，将 image 类型替换为文本描述"""
    if isinstance(content, str):
        return content
    if not isinstance(content, list):
        return content

    cleaned = []
    for block in content:
        if not isinstance(block, dict):
            cleaned.append(block)
            continue

        block_type = block.get("type", "")

        if block_type == "image":
            # 将 image block 替换为文本描述
            source = block.get("source", {})
            media_type = source.get("media_type", "unknown")
            data = source.get("data", "")
            data_len = len(data) if isinstance(data, str) else 0

            cleaned.append({
                "type": "text",
                "text": f"[图片: {media_type}, {data_len} bytes base64 数据, 已被代理省略]"
            })

        elif block_type == "tool_result":
            # tool_result 的 content 也可能包含 image blocks
            inner = block.get("content")
            if isinstance(inner, list):
                block = dict(block)
                block["content"] = clean_content_blocks(inner)
            cleaned.append(block)

        else:
            cleaned.append(block)

    return cleaned


def clean_messages(body_bytes):
    """清洗请求体中的 messages，移除 image blocks"""
    try:
        body = json.loads(body_bytes)
    except (json.JSONDecodeError, UnicodeDecodeError):
        return body_bytes

    if "messages" in body and isinstance(body["messages"], list):
        for msg in body["messages"]:
            if isinstance(msg, dict) and "content" in msg:
                msg["content"] = clean_content_blocks(msg["content"])

    # system prompt 也可能有（一般不会，但安全起见）
    if "system" in body:
        body["system"] = clean_content_blocks(body["system"]) if isinstance(body["system"], list) else body["system"]

    return json.dumps(body).encode("utf-8")


class ProxyHandler(BaseHTTPRequestHandler):
    """HTTP 代理处理器"""

    def log_message(self, format, *args):
        """简化日志输出"""
        print(f"[proxy] {args[0]}" if args else "", file=sys.stderr)

    def _get_upstream_url(self):
        """构建上游 URL"""
        return _config["upstream_url"] + self.path

    def _forward_response(self, resp):
        """将上游响应转发给客户端"""
        self.send_response(resp.status)

        # 复制所有响应头
        content_type = None
        for key, value in resp.getheaders():
            if key.lower() == "transfer-encoding":
                continue  # 跳过 transfer-encoding，由我们自己处理
            if key.lower() == "content-type":
                content_type = value
            self.send_header(key, value)
        self.end_headers()

        # 读取并转发响应体
        if content_type and "text/event-stream" in content_type:
            # SSE streaming: 逐行转发
            try:
                while True:
                    line = resp.readline()
                    if not line:
                        break
                    self.wfile.write(line)
                    self.wfile.flush()
            except (BrokenPipeError, ConnectionResetError):
                pass
        else:
            # 普通响应: 一次性转发
            try:
                data = resp.read()
                self.wfile.write(data)
            except (BrokenPipeError, ConnectionResetError):
                pass

    def do_POST(self):
        """处理 POST 请求（API 调用）"""
        content_length = int(self.headers.get("Content-Length", 0))
        body = self.rfile.read(content_length) if content_length > 0 else b""

        # 清洗 image blocks
        cleaned_body = clean_messages(body)

        # 构建上游请求
        upstream_url = self._get_upstream_url()
        req = Request(upstream_url, data=cleaned_body, method="POST")

        # 复制请求头
        for key, value in self.headers.items():
            if key.lower() in ("host", "content-length", "transfer-encoding"):
                continue
            req.add_header(key, value)

        # 更新 Content-Length
        req.add_header("Content-Length", str(len(cleaned_body)))

        # 发送到上游
        ctx = ssl.create_default_context()
        try:
            resp = urlopen(req, context=ctx, timeout=300)
            self._forward_response(resp)
        except HTTPError as e:
            self._forward_response(e)
        except URLError as e:
            self.send_error(502, f"Upstream error: {e.reason}")
        except Exception as e:
            self.send_error(500, f"Proxy error: {str(e)}")

    def do_GET(self):
        """处理 GET 请求（健康检查等）"""
        if self.path == "/health":
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps({"status": "ok", "upstream": UPSTREAM_URL}).encode())
            return

        # 其他 GET 请求透传
        upstream_url = self._get_upstream_url()
        req = Request(upstream_url, method="GET")
        for key, value in self.headers.items():
            if key.lower() in ("host",):
                continue
            req.add_header(key, value)

        ctx = ssl.create_default_context()
        try:
            resp = urlopen(req, context=ctx, timeout=30)
            self._forward_response(resp)
        except HTTPError as e:
            self._forward_response(e)
        except Exception as e:
            self.send_error(502, f"Upstream error: {str(e)}")

    def do_OPTIONS(self):
        """处理 OPTIONS 预检请求"""
        self.send_response(200)
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "POST, GET, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "*")
        self.end_headers()


def write_pid():
    """写入 PID 文件"""
    with open(PID_FILE, "w") as f:
        f.write(str(os.getpid()))


def cleanup(signum=None, frame=None):
    """清理并退出"""
    if os.path.exists(PID_FILE):
        os.remove(PID_FILE)
    print("[proxy] 已停止", file=sys.stderr)
    sys.exit(0)


def main():
    parser = argparse.ArgumentParser(description="DashScope Image Proxy")
    parser.add_argument("--port", type=int, default=_config["listen_port"], help=f"监听端口 (默认: {_config['listen_port']})")
    parser.add_argument("--upstream", type=str, default=_config["upstream_url"], help=f"上游 URL (默认: {_config['upstream_url']})")
    args = parser.parse_args()

    _config["upstream_url"] = args.upstream
    _config["listen_port"] = args.port

    signal.signal(signal.SIGTERM, cleanup)
    signal.signal(signal.SIGINT, cleanup)

    server = HTTPServer(("127.0.0.1", _config["listen_port"]), ProxyHandler)
    write_pid()

    print(f"[proxy] DashScope 图片代理已启动", file=sys.stderr)
    print(f"[proxy] 监听: http://127.0.0.1:{_config['listen_port']}", file=sys.stderr)
    print(f"[proxy] 上游: {_config['upstream_url']}", file=sys.stderr)
    print(f"[proxy] PID: {os.getpid()}", file=sys.stderr)
    print(f"[proxy] 停止: kill $(cat {PID_FILE})", file=sys.stderr)

    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        cleanup()


if __name__ == "__main__":
    main()
