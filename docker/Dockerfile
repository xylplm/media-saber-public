FROM alpine:latest

ARG TARGETPLATFORM

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
    MS_PGSQL_PASSWORD="ms888888" \
    MS_PGSQL_PATH="127.0.0.1" \
    MS_PGSQL_PORT="5432" \
    MS_PGSQL_DBNAME="ms" \
    MS_PGSQL_LOG_MODE="prod" \
    MS_MQ_CONCURRENCY="10" \
    MS_MCP_SERVER_BASE_URL="http://0.0.0.0:22699" \
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

COPY msaber-back/dist/$TARGETPLATFORM/mediaSaber /app/mediaSaber
COPY msaber-front/. /app/front
COPY msaber-back/etc/. /app/etc
COPY msaber-back/doc/static/. /app/doc/static
COPY nginx.template.conf /etc/nginx/nginx.template.conf
COPY entrypoint.sh /entrypoint.sh

RUN apk --no-cache add \
        tzdata \
        nginx \
        nginx-mod-http-js \
        gettext \
        su-exec \
        bash \
        shadow \
    && addgroup -S msaber -g 1000 \
    && adduser -S msaber -G msaber -h /app -u 1000 -s /bin/bash \
    && mkdir /app/config \
    && chmod +x /app/mediaSaber /entrypoint.sh \
    && echo 'fs.inotify.max_user_watches=5242880' >> /etc/sysctl.conf \
    && echo 'fs.inotify.max_user_instances=5242880' >> /etc/sysctl.conf

EXPOSE 8888
# EXPOSE 2345

ENTRYPOINT [ "/entrypoint.sh" ]

VOLUME ["/app/config"]
