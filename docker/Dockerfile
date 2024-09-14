FROM alpine:3.20

ARG TARGETPLATFORM

ENV REDIS_HOST="127.0.0.1:6379" \
    REDIS_PASS="" \
    MS_PORT="8888" \
    MS_SITE_CONFIG_DIR="./config/site_configs" \
    MS_AUTH_EMAIL="" \
    MS_AUTH_SLOGAN="" \
    MS_LOG_MODE="console" \
    TZ="Asia/Shanghai" \
    PUID=0 \
    PGID=0 \
    UMASK=022

WORKDIR /app

COPY msaber-back/dist/$TARGETPLATFORM/mediaSaber /app/mediaSaber
COPY msaber-front/dist/MediaSaber/browser/. /app/front
COPY msaber-back/etc/. /app/etc
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
