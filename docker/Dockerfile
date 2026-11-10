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

# 内置 ffprobe 静态副本（glibc/musl 通吃）：容器开箱即用（跑在 GitHub Actions 构建
# 机上直连源站无碍）。后端只检测不安装，解析链：显式配置 → PATH → 托管副本(卷) →
# /app/bundled 内置。
# 注意：TARGETARCH 在文件顶部已裸声明（自动取构建平台值）。此处严禁写成
# `ARG TARGETARCH=amd64`——带默认值的重声明会覆盖平台自动值，导致 arm64 镜像
# 里混入 amd64 产物（2026-11-06 ffprobe 内置提交引入，ARM 真机 Exec format error 崩溃）。
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

# 架构守卫：主程序 ELF e_machine 必须与 TARGETARCH 一致（x86_64=3e00 / aarch64=b700），
# 构建期即拦下「arm64 镜像装 amd64 产物」这类错误，失败信息直接指明两个值。
RUN set -ex \
    && M=$(dd if=/app/mediaSaber bs=1 skip=18 count=2 2>/dev/null | od -An -tx1 | tr -d ' \n') \
    && case "${M}:${TARGETARCH}" in \
        3e00:amd64 | b700:arm64) ;; \
        *) echo "arch mismatch: mediaSaber e_machine=${M} TARGETARCH=${TARGETARCH}" && exit 1 ;; \
    esac

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
