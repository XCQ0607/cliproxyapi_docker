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
    # 使用 GitHub 网页重定向获取最新版本号，避开 API 速率限制
    LATEST_URL=$(curl -Ls -o /dev/null -w %{url_effective} "https://github.com/${REPO_OWNER}/${REPO_NAME}/releases/latest") && \
    VERSION=$(echo "$LATEST_URL" | grep -o "v[0-9]*\.[0-9]*\.[0-9]*" | head -n 1) && \
    if [ -z "$VERSION" ]; then \
        echo "Error: Failed to extract version from URL: $LATEST_URL"; \
        exit 1; \
    fi && \
    echo "Detected latest version: $VERSION" && \
    # 构造下载链接 (GitHub Releases 标准格式)
    # 格式: https://github.com/router-for-me/CLIProxyAPI/releases/download/v6.7.15/CLIProxyAPI_6.7.15_linux_amd64.tar.gz
    # 注意：文件名中的版本号通常不带 'v' 前缀
    CLEAN_VERSION=$(echo "$VERSION" | sed 's/^v//') && \
    DOWNLOAD_URL="https://github.com/${REPO_OWNER}/${REPO_NAME}/releases/download/${VERSION}/CLIProxyAPI_${CLEAN_VERSION}_${OS_ARCH}.tar.gz" && \
    echo "Downloading from $DOWNLOAD_URL..." && \
    curl -L -o cliproxy.tar.gz "$DOWNLOAD_URL" && \
    # 解压
    tar -xzf cliproxy.tar.gz && \
    rm cliproxy.tar.gz && \
    # 整理文件结构
    BINARY_PATH=$(find . -name "cli-proxy-api" -type f | head -n 1) && \
    if [ -z "$BINARY_PATH" ]; then echo "Binary not found after extraction"; exit 1; fi && \
    mv "$BINARY_PATH" ./cli-proxy-api && \
    chmod +x ./cli-proxy-api && \
    # 清理多余文件
    find . -maxdepth 1 ! -name "cli-proxy-api" ! -name "." ! -name ".." -exec rm -rf {} + && \
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
