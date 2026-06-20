FROM debian:bullseye-slim

# 安装运行时需要的必要依赖
RUN apt-get update && apt-get install -y \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# 设置工作目录
WORKDIR /app

# 声明 TARGETARCH 构建参数，Buildx 会自动传入 (amd64, arm64)
ARG TARGETARCH

# 复制对应架构的二进制文件到镜像中
COPY bin/${TARGETARCH}/cli-proxy-api /app/cli-proxy-api
RUN chmod +x /app/cli-proxy-api

# 复制启动脚本
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# 暴露端口
EXPOSE 8317

# 设置数据卷 (用于持久化 Token 和 Config)
VOLUME ["/app"]

# 设置入口点
ENTRYPOINT ["docker-entrypoint.sh"]
