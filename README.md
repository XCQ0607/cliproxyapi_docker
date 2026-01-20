# CLIProxyAPI Docker Edition

[中文](README_CN.md) | English

This project is a Docker wrapper for [router-for-me/CLIProxyAPI](https://github.com/router-for-me/CLIProxyAPI).

**Core Goal**: Simplify the deployment process by enabling quick configuration of `config.yaml` via **environment variables**, eliminating the need for manual file editing, while optimizing for container environments like Hugging Face Spaces.

## 🚀 Quick Start

### Docker Run

```bash
docker run -d \
  --name cliproxy \
  -p 8317:8317 \
  -e CLIPROXY_API_KEYS="sk-key1,sk-key2" \
  -e CLIPROXY_MANAGEMENT_KEY="admin123" \
  xcq0607/cliproxyapi_docker
```

### Hugging Face Space Deployment

If you are deploying on Hugging Face Space (Docker SDK), simply add environment variables in Settings -> Variables.

Special Feature: Set the `HF_SAVE` variable to automatically keep the space alive.

## ⚙️ Environment Variable Configuration

This project supports overriding core configurations in `config.yaml` via environment variables.

### Core Configuration

| Environment Variable | Default Value | Description |
|----------------------|---------------|-------------|
| `CLIPROXY_PORT` | `8317` | Service listening port |
| `CLIPROXY_API_KEYS` | (Randomly Generated) | API Keys for client connections, comma-separated `,`. E.g., `sk-key1,sk-key2` |
| `CLIPROXY_MANAGEMENT_KEY` | `admin` | Access password for the management interface (`/management.html`) |
| `CLIPROXY_MANAGEMENT_ENABLED` | `true` | Whether to enable the management interface |
| `HF_SAVE` | (Empty) | **Hugging Face Keepalive**. Enter `username/space_name` (e.g., `myuser/myspace`), and the container will ping `https://myuser-myspace.hf.space/` every 5 minutes to prevent sleep. |

### Advanced Configuration

| Environment Variable | Default Value | Config Field | Description |
|----------------------|---------------|--------------|-------------|
| `CLIPROXY_PROXY_URL` | (Empty) | `proxy-url` | Upstream proxy address, supports socks5/http/https. E.g., `socks5://user:pass@1.2.3.4:1080` |
| `CLIPROXY_DEBUG` | `false` | `debug` | Whether to enable debug logging |
| `CLIPROXY_ROUTING_STRATEGY` | `round-robin` | `routing.strategy` | Load balancing strategy, `round-robin` or `fill-first` |
| `CLIPROXY_WS_AUTH` | `false` | `ws-auth` | Whether WebSocket API requires authentication |
| `CLIPROXY_COMMERCIAL_MODE` | `false` | `commercial-mode` | Whether to enable commercial mode (disables some high-overhead middleware) |
| `CLIPROXY_ADDITIONAL_CONFIG` | (Empty) | (Appended Content) | **Advanced Usage**: Enter raw YAML string here, which will be appended to the end of `config.yaml`. Used for configuring complex lists like `gemini-api-key` or `oauth-model-alias`. |

## 📚 Original Project Introduction & Usage

> The following content is referenced from the original project [CLIProxyAPI](https://github.com/router-for-me/CLIProxyAPI). This project is solely a Docker wrapper for it.

**CLIProxyAPI** is a proxy server that provides OpenAI/Gemini/Claude/Codex compatible API endpoints for CLI tools. It allows you to access these models using local or multi-account CLI methods via any client compatible with OpenAI/Gemini/Claude.

### Core Features
*   **Multi-Model Aggregation**: Supports Gemini, Claude, OpenAI (Codex), Qwen, iFlow.
*   **OAuth Automation**: Solves complex OAuth login and Token refresh issues.
*   **Interface Standardization**: Converts all upstream interfaces to standard OpenAI format (`sk-...`), adapting to tools like VSCode plugins, immersive translation, etc.

### Common Operations

Inside the Docker container, you can still use the original project's CLI commands (requires entering the container):

```bash
# Enter container
docker exec -it cliproxy /bin/bash

# Login to Gemini (Generate Token)
./cli-proxy-api --login --no-browser

# Login to Claude
./cli-proxy-api --claude-login --no-browser

# Check status
./cli-proxy-api status
```

*Note: Since the Docker container has no browser, be sure to add the `--no-browser` parameter and complete the login in your local browser using the URL printed in the terminal.*

For more detailed documentation, please refer to the original repository: [router-for-me/CLIProxyAPI](https://github.com/router-for-me/CLIProxyAPI)
