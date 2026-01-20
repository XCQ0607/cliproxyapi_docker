FROM debian:bullseye-slim

# 安装必要依赖
# curl/wget: 下载文件
# ca-certificates: HTTPS 支持
# tar: 解压
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    ca-certificates \
    tar \
    && rm -rf /var/lib/apt/lists/*

# 设置工作目录
WORKDIR /app

# 构建参数
ARG REPO_OWNER="router-for-me"
ARG REPO_NAME="CLIProxyAPI"

# 下载并安装 CLIProxyAPI
RUN echo "Detecting architecture..." && \
    ARCH=$(uname -m) && \
    case "$ARCH" in \
        x86_64|amd64) OS_ARCH="linux_amd64" ;; \
        arm64|aarch64) OS_ARCH="linux_arm64" ;; \
        *) echo "Unsupported architecture: $ARCH"; exit 1 ;; \
    esac && \
    echo "Fetching latest version tag..." && \
    # 使用 curl -I 获取重定向头 (Location)，这种方式在各种 curl 版本中最稳健
    # grep -i location: 不区分大小写匹配 Location 头
    # awk '{print $2}': 打印第二个字段（即 URL）
    # tr -d '\r': 删除可能存在的 Windows 回车符
    LATEST_URL=$(curl -Is "https://github.com/${REPO_OWNER}/${REPO_NAME}/releases/latest" | grep -i "^location:" | awk '{print $2}' | tr -d '\r') && \
    if [ -z "$LATEST_URL" ]; then \
        echo "Error: Failed to get redirect URL from GitHub"; \
        exit 1; \
    fi && \
    # 从 URL 中提取版本号 (例如 .../tag/v6.7.15 -> v6.7.15)
    VERSION=$(echo "$LATEST_URL" | grep -o "v[0-9]*\.[0-9]*\.[0-9]*" | head -n 1) && \
    if [ -z "$VERSION" ]; then \
        echo "Error: Failed to extract version from URL: $LATEST_URL"; \
        exit 1; \
    fi && \
    echo "Detected latest version: $VERSION" && \
    # 构造下载链接
    CLEAN_VERSION=$(echo "$VERSION" | sed 's/^v//') && \
    DOWNLOAD_URL="https://github.com/${REPO_OWNER}/${REPO_NAME}/releases/download/${VERSION}/CLIProxyAPI_${CLEAN_VERSION}_${OS_ARCH}.tar.gz" && \
    echo "Downloading from $DOWNLOAD_URL..." && \
    curl -L -o cliproxy.tar.gz "$DOWNLOAD_URL" && \
    # 解压到临时目录
    mkdir -p /tmp/cliproxy && \
    tar -xzf cliproxy.tar.gz -C /tmp/cliproxy && \
    rm cliproxy.tar.gz && \
    # 查找并移动二进制文件
    BINARY_PATH=$(find /tmp/cliproxy -name "cli-proxy-api" -type f | head -n 1) && \
    if [ -z "$BINARY_PATH" ]; then echo "Binary not found after extraction"; exit 1; fi && \
    mv "$BINARY_PATH" /app/cli-proxy-api && \
    chmod +x /app/cli-proxy-api && \
    # 清理临时目录
    rm -rf /tmp/cliproxy && \
    echo "Installation complete."

# 复制启动脚本
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# 暴露端口
EXPOSE 8317

# 设置数据卷 (用于持久化 Token 和 Config)
VOLUME ["/app"]

# 设置入口点
ENTRYPOINT ["docker-entrypoint.sh"]
