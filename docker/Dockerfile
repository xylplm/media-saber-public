FROM alpine:3.23

ARG TARGETARCH

ENV MS_PORT="8888" \
    MS_REDIS_HOST="127.0.0.1:6379" \
    MS_REDIS_PASS="" \
    MS_AUTH_EMAIL="" \
    MS_AUTH_SLOGAN="" \
    MS_LOG_LEVEL="info" \
    MS_LOG_KEEP_DAYS="14" \
    MS_LOG_MAX_SIZE="10" \
    MS_TIMEOUT="15000" \
    MS_PGSQL_USERNAME="postgres" \
    MS_PGSQL_PASSWORD="" \
    MS_PGSQL_PATH="127.0.0.1" \
    MS_PGSQL_PORT="5432" \
    MS_PGSQL_DBNAME="ms" \
    MS_PGSQL_LOG_MODE="prod" \
    MS_MQ_CONCURRENCY="10" \
    TZ="Asia/Shanghai" \
    PUID=0 \
    PGID=0 \
    UMASK=022

# 安装 Go 环境（用于编译 dlv）
# RUN apk add --no-cache go
# ENV GOPROXY=https://goproxy.cn,direct

# 安装 Delve 并清理 Go 环境
# RUN go install github.com/go-delve/delve/cmd/dlv@latest \
#     && cp /root/go/bin/dlv /usr/local/bin/dlv \
#     && apk del go \
#     && rm -rf /root/go /var/cache/apk/*


WORKDIR /app

# 内置 ffprobe 静态副本（glibc/musl 通吃）：容器开箱即用，免去首启联网下载（跑在
# GitHub Actions 构建机上直连源站无碍）；独立部署的网络下载/手动上传链路保留为兜底。
# 后端解析链：显式配置 → PATH → 托管副本(卷) → /app/bundled 内置 → 网络下载。
ARG TARGETARCH=amd64
RUN set -ex \
    && apk add --no-cache xz ca-certificates wget \
    && case "${TARGETARCH}" in \
        amd64) FF_URL="https://johnvansickle.com/ffmpeg/releases/ffmpeg-7.0.2-amd64-static.tar.xz" ;; \
        arm64) FF_URL="https://johnvansickle.com/ffmpeg/releases/ffmpeg-7.0.2-arm64-static.tar.xz" ;; \
        *) echo "unsupported TARGETARCH: ${TARGETARCH}" && exit 1 ;; \
    esac \
    && wget -qO /tmp/ffprobe.tar.xz "${FF_URL}" \
    && tar -xJf /tmp/ffprobe.tar.xz -C /tmp \
    && mkdir -p /app/bundled \
    && mv /tmp/ffmpeg-7.0.2-*-static/ffprobe /app/bundled/ffprobe_${TARGETARCH} \
    && chmod 755 /app/bundled/ffprobe_${TARGETARCH} \
    && rm -rf /tmp/ffprobe.tar.xz /tmp/ffmpeg-7.0.2-*-static

COPY msaber-back-${TARGETARCH}/dist/linux/${TARGETARCH}/mediaSaber /app/mediaSaber
COPY msaber-back-${TARGETARCH}/etc/media_saber.template.yaml /app/etc/media_saber.yaml
COPY msaber-front/. /app/front
COPY msaber-back-${TARGETARCH}/etc/. /app/etc
COPY msaber-back-${TARGETARCH}/doc/. /app/doc
COPY msaber-back-${TARGETARCH}/static/. /app/static
COPY nginx.template.conf /etc/nginx/nginx.template.conf
COPY entrypoint.sh /entrypoint.sh
COPY upgrade.sh /upgrade.sh

RUN apk --no-cache add \
        tzdata \
        nginx \
        gettext \
        su-exec \
        bash \
        shadow \
        tar \
    && addgroup -S msaber -g 1000 \
    && adduser -S msaber -G msaber -h /app -u 1000 -s /bin/bash \
    && mkdir /app/config \
    && chmod +x /app/mediaSaber /entrypoint.sh /upgrade.sh \
    && echo 'fs.inotify.max_user_watches=5242880' >> /etc/sysctl.conf \
    && echo 'fs.inotify.max_user_instances=5242880' >> /etc/sysctl.conf

EXPOSE 8888
# EXPOSE 2345

ENTRYPOINT [ "/entrypoint.sh" ]

VOLUME ["/app/config"]
