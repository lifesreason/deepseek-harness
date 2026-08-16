# 多阶段构建
FROM node:22-slim AS builder
RUN apt-get update && apt-get install -y --no-install-recommends python3 make g++ git && rm -rf /var/lib/apt/lists/*
RUN corepack enable && corepack prepare pnpm@11.7.0 --activate
WORKDIR /app
COPY . .
RUN pnpm install --ignore-scripts && pnpm run build

FROM node:22-slim
WORKDIR /app
COPY --from=builder /app /app
RUN corepack enable && pnpm install --ignore-scripts
EXPOSE 3080
CMD ["node", "apps/cli/lib/bin.js", "web"]
