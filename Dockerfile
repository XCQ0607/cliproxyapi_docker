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

# 构建参数 (可以用来指定版本，默认 latest)
ARG REPO_OWNER="router-for-me"
ARG REPO_NAME="CLIProxyAPI"

# 下载并安装 CLIProxyAPI (逻辑复刻自 1.sh)
RUN echo "Detecting architecture..." && \
    ARCH=$(uname -m) && \
    case "$ARCH" in \
        x86_64|amd64) OS_ARCH="linux_amd64" ;; \
        arm64|aarch64) OS_ARCH="linux_arm64" ;; \
        *) echo "Unsupported architecture: $ARCH"; exit 1 ;; \
    esac && \
    echo "Fetching latest release for $OS_ARCH..." && \
    API_URL="https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/releases/latest" && \
    RELEASE_INFO=$(curl -s "$API_URL") && \
    # 提取下载链接
    DOWNLOAD_URL=$(echo "$RELEASE_INFO" | grep -o "\"browser_download_url\": *\"[^\"]*CLIProxyAPI_[^\"]*_${OS_ARCH}.tar.gz\"" | cut -d'"' -f4) && \
    if [ -z "$DOWNLOAD_URL" ]; then echo "Failed to find download URL"; exit 1; fi && \
    echo "Downloading from $DOWNLOAD_URL..." && \
    curl -L -o cliproxy.tar.gz "$DOWNLOAD_URL" && \
    # 解压
    tar -xzf cliproxy.tar.gz && \
    rm cliproxy.tar.gz && \
    # 整理文件结构：将解压出的版本文件夹内的内容移动到 /app 根目录
    # 注意：解压后通常会有一个版本号文件夹，我们需要找到二进制文件并移动
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
