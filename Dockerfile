# 多阶段构建，有效控制镜像体积
FROM node:22-slim AS builder
RUN apt-get update && apt-get install -y --no-install-recommends python3 make g++ git && rm -rf /var/lib/apt/lists/*
RUN corepack enable && corepack prepare pnpm@11.7.0 --activate
WORKDIR /app
COPY . .
# 关键修改：通过环境变量跳过 lefthook 的安装
RUN pnpm install --ignore-scripts && pnpm run build

FROM node:22-slim
WORKDIR /app
COPY --from=builder /app/apps /app/apps
COPY --from=builder /app/packages /app/packages
COPY --from=builder /app/package.json /app/pnpm-lock.yaml ./
# 生产环境中也需要跳过脚本安装
RUN corepack enable && pnpm install --prod --ignore-scripts
EXPOSE 3080
CMD ["node", "apps/cli/lib/bin.js", "web"]
