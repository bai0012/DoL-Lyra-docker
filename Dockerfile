FROM nginx:alpine-slim

# 复制网站文件
COPY site /usr/share/nginx/html

# 复制 nginx 配置
COPY nginx.conf /etc/nginx/conf.d/default.conf

# 创建 SSL 和 auth 目录
RUN mkdir -p /etc/nginx/ssl /etc/nginx/auth

EXPOSE 8080
