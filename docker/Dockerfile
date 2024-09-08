# 使用 Alpine 作为基础镜像
FROM alpine
LABEL authors="xylplm"
WORKDIR /app

ARG TARGETPLATFORM
# 复制适当的平台二进制文件
RUN mkdir -p /app/mediaSaber
COPY msaber-back/dist/$TARGETPLATFORM/mediaSaber /app/mediaSaber

# 复制其他需要的文件或目录，例如 start.sh
#COPY . ${WORKDIR}
RUN mkdir -p /app/mediaSaber/front
RUN mkdir -p /app/mediaSaber/config
COPY msaber-front/dist/MediaSaber/browser/. /app/mediaSaber/front
COPY msaber-back/config/. /app/mediaSaber/config
RUN apk add --no-cache tzdata

# 设置环境变量
ENV secretKey="" \
    TZ="Asia/Shanghai"

EXPOSE 8088
VOLUME ["/config"]
# 设置启动命令
CMD ["./mediaSaber"]