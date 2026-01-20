# CLIProxyAPI Docker 部署版

[English](README.md) | 中文

本项目是 [router-for-me/CLIProxyAPI](https://github.com/router-for-me/CLIProxyAPI) 的 Docker 封装版本。

**核心目标**：简化部署流程，通过**环境变量**快速配置 `config.yaml`，无需手动编辑配置文件，同时针对 Hugging Face Space 等容器环境进行了优化。

## 🚀 快速开始

### Docker 运行

```bash
docker run -d \
  --name cliproxy \
  -p 8317:8317 \
  -e CLIPROXY_API_KEYS="sk-key1,sk-key2" \
  -e CLIPROXY_MANAGEMENT_KEY="admin123" \
  xcq0607/cliproxyapi_docker
```

### Hugging Face Space 部署

如果您在 Hugging Face Space (Docker SDK) 上部署，只需在 Settings -> Variables 中添加环境变量即可。

特别功能：设置 `HF_SAVE` 变量可自动保活。

## ⚙️ 环境变量配置

本项目支持通过环境变量覆盖 `config.yaml` 中的核心配置。

### 核心配置

| 环境变量 | 默认值 | 说明 |
|----------|--------|------|
| `CLIPROXY_PORT` | `8317` | 服务监听端口 |
| `CLIPROXY_API_KEYS` | (随机生成) | 客户端连接用的 API Key，多个 Key 用逗号 `,` 分隔。例如 `sk-key1,sk-key2` |
| `CLIPROXY_MANAGEMENT_KEY` | `admin` | 管理界面 (`/management.html`) 的访问密码 |
| `CLIPROXY_MANAGEMENT_ENABLED` | `true` | 是否开启管理界面 |
| `HF_SAVE` | (空) | **Hugging Face 保活专用**。填入 `username/space_name` (例如 `myuser/myspace`)，容器会自动每 5 分钟访问一次 `https://myuser-myspace.hf.space/` 以防止休眠。 |

### 高级配置

| 环境变量 | 默认值 | 对应 config.yaml 字段 | 说明 |
|----------|--------|-----------------------|------|
| `CLIPROXY_PROXY_URL` | (空) | `proxy-url` | 上游代理地址，支持 socks5/http/https。例如 `socks5://user:pass@1.2.3.4:1080` |
| `CLIPROXY_DEBUG` | `false` | `debug` | 是否开启调试日志 |
| `CLIPROXY_ROUTING_STRATEGY` | `round-robin` | `routing.strategy` | 负载均衡策略，可选 `round-robin` (轮询) 或 `fill-first` |
| `CLIPROXY_WS_AUTH` | `false` | `ws-auth` | WebSocket API 是否需要鉴权 |
| `CLIPROXY_COMMERCIAL_MODE` | `false` | `commercial-mode` | 是否开启商业模式（禁用部分高开销中间件） |
| `CLIPROXY_ADDITIONAL_CONFIG` | (空) | (追加内容) | **高级用法**：在此变量中填入原始 YAML 字符串，它会被直接追加到 `config.yaml` 末尾。用于配置复杂的 `gemini-api-key` 或 `oauth-model-alias` 等列表项。 |

## 📚 原项目介绍与用法

> 以下内容引用自原项目 [CLIProxyAPI](https://github.com/router-for-me/CLIProxyAPI)，本项目仅为其 Docker 封装。

**CLIProxyAPI** 是一个为 CLI 提供 OpenAI/Gemini/Claude/Codex 兼容 API 接口的代理服务器。它允许你使用本地或多账户的 CLI 方式，通过任何与 OpenAI/Gemini/Claude 兼容的客户端访问这些模型。

### 核心特性
*   **多模型聚合**：支持 Gemini, Claude, OpenAI (Codex), Qwen, iFlow。
*   **OAuth 自动化**：解决复杂的 OAuth 登录与 Token 刷新问题。
*   **接口标准化**：将所有上游接口转换为标准 OpenAI 格式 (`sk-...`)，适配 VSCode 插件、沉浸式翻译等工具。

### 常见操作

在 Docker 容器内，您依然可以使用原项目的 CLI 命令（需进入容器）：

```bash
# 进入容器
docker exec -it cliproxy /bin/bash

# 登录 Gemini (生成 Token)
./cli-proxy-api --login --no-browser

# 登录 Claude
./cli-proxy-api --claude-login --no-browser

# 查看状态
./cli-proxy-api status
```

*注意：由于 Docker 容器无浏览器，请务必加上 `--no-browser` 参数，根据终端打印的 URL 在本机浏览器完成登录。*

更多详细文档请参考原仓库：[router-for-me/CLIProxyAPI](https://github.com/router-for-me/CLIProxyAPI)
