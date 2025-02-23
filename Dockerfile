FROM nginx:alpine-slim

# 删除默认配置
RUN rm /etc/nginx/conf.d/default.conf

# 创建证书和认证文件目录
RUN mkdir -p /etc/nginx/certs && \
    mkdir -p /etc/nginx/auth

# 复制自定义配置
COPY nginx/default.conf /etc/nginx/conf.d/

# 复制网站内容
COPY content /usr/share/nginx/html

# 暴露端口
EXPOSE 8080 443

CMD ["nginx", "-g", "daemon off;"]
