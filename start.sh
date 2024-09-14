# 检查 PORT 环境变量是否设置，如果没有设置则使用默认端口 80
if [ -z "$MS_PORT" ]; then
  MS_PORT=8888
fi

# 使用环境变量替换配置文件中的占位符
envsubst '${MS_PORT}' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

# 启动 Nginx
nginx &

# 启动 Go 服务
./mediaSaber
