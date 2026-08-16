# 多阶段构建
FROM node:22-slim AS builder

# 安装编译 node-pty 所需的系统依赖
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    make \
    g++ \
    git \
    && rm -rf /var/lib/apt/lists/*

RUN corepack enable && corepack prepare pnpm@11.7.0 --activate
WORKDIR /app
COPY . .

# 关键修改：仅跳过 lefthook 等非必需脚本，但允许 node-pty 编译
RUN pnpm install --ignore-scripts \
    && pnpm rebuild node-pty \
    && pnpm run build

FROM node:22-slim
WORKDIR /app

# 复制整个构建产物（包含编译好的原生模块）
COPY --from=builder /app /app

# 生产环境下，仅安装生产依赖，但确保不覆盖已编译的原生模块
RUN corepack enable \
    && pnpm install --prod --ignore-scripts \
    && pnpm rebuild node-pty --force

EXPOSE 3080
CMD ["node", "apps/cli/lib/bin.js", "web"]
