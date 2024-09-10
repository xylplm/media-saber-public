# 使用 Alpine 作为基础镜像
FROM alpine
LABEL authors="xylplm"
WORKDIR /app

ARG TARGETPLATFORM
# 复制适当的平台二进制文件
ADD msaber-back/dist/$TARGETPLATFORM/mediaSaber /app/mediaSaber

# 复制其他需要的文件或目录，例如 start.sh
RUN mkdir front config etc \
    && chmod +x /app/mediaSaber \
    && apk --no-cache add tzdata

COPY msaber-front/dist/MediaSaber/browser/. front
COPY msaber-back/etc/. etc



# 设置环境变量
ENV REDIS_HOST="127.0.0.1:6379" \
    REDIS_PASS="" \
    MS_PORT="8888" \
    MS_SITE_CONFIG_DIR="./config/site_configs" \
    MS_AUTH_EMAIL="" \
    MS_AUTH_SLOGAN="" \
    MS_LOG_MODE="console" \
    TZ="Asia/Shanghai"

EXPOSE 8888
VOLUME ["/app/config"]
# 设置启动命令
CMD ["sh", "-c", "ls -al && ./mediaSaber"]