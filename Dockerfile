# Estágio 1: build
FROM node:24.19.0-alpine AS builder

WORKDIR /app

COPY package*.json prisma.config.js ./
COPY prisma ./prisma

RUN npm ci

COPY src ./src

# Estágio 2: produção
FROM node:24.19.0-alpine

# Define uma variável de ambiente dentro do container, é uma convenção.
ENV NODE_ENV=production

WORKDIR /app

COPY package*.json prisma.config.js ./
COPY prisma ./prisma

# Limpa o cache junto
RUN npm ci --omit=dev && npm cache clean --force

COPY --from=builder /app/node_modules/.prisma ./node_modules/.prisma
COPY --from=builder /app/src ./src

EXPOSE 3000

CMD ["node", "src/server.js"]
