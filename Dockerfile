# 阶段1：构建（使用Node 10，兼容老版本node-sass）
FROM node:10 AS builder

WORKDIR /app

# 设置npm镜像和node-sass二进制下载地址
RUN npm config set registry https://registry.npmjs.org && \
    npm config set sass_binary_site https://npmmirror.com/mirrors/node-sass/

# 先复制依赖文件，利用Docker缓存
COPY package.json yarn.lock ./

# 安装依赖
RUN npm install --legacy-peer-deps

# 复制源码并构建
COPY . .
RUN npm run build:prod

# 阶段2：生产镜像（nginx）
FROM nginx:alpine

# 复制构建产物到nginx目录
COPY --from=builder /app/admin /usr/share/nginx/html

# 复制nginx配置
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]