# 使用环境变量替换配置文件中的占位符
envsubst '${MS_PORT}' < /etc/nginx/conf.d/site.template > /etc/nginx/conf.d/default.conf

# 启动 Nginx
nginx &

# 启动 Go 服务
./mediaSaber