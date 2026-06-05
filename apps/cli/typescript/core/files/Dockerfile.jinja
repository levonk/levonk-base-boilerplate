FROM node:20-slim AS builder

WORKDIR /app
COPY package.json package-lock.json* pnpm-lock.yaml* ./
RUN npm install

COPY . .
RUN npm run build

FROM node:20-slim
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/package.json ./
COPY --from=builder /app/node_modules ./node_modules

ENTRYPOINT ["node", "dist/index.js"]
CMD ["--help"]
