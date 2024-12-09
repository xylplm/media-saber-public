FROM alpine:3.20

ARG TARGETPLATFORM

ENV MS_REDIS_HOST="127.0.0.1:6379" \
    MS_REDIS_PASS="" \
    MS_PORT="8888" \
    MS_SITE_CONFIG_DIR="/app/config/data/siteConfig" \
    MS_AUTH_EMAIL="" \
    MS_AUTH_SLOGAN="" \
    MS_LOG_LEVEL="info" \
    MS_LOG_MODE="console" \
    MS_LOG_ENCODING="json" \
    MS_LOG_KEEP_DAYS=14 \
    TZ="Asia/Shanghai" \
    PUID=0 \
    PGID=0 \
    UMASK=022

WORKDIR /app

COPY msaber-back/dist/$TARGETPLATFORM/mediaSaber /app/mediaSaber
COPY msaber-front/dist/MediaSaber/browser/. /app/front
COPY msaber-back/etc/. /app/etc
COPY msaber-back/doc/static/. /app/doc/static
COPY nginx.template.conf /etc/nginx/nginx.template.conf
COPY entrypoint.sh /entrypoint.sh

RUN apk --no-cache add \
        tzdata \
        nginx \
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

ENTRYPOINT [ "/entrypoint.sh" ]

EXPOSE 8888
VOLUME ["/app/config"]
