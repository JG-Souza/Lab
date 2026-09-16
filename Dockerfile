# Estágio base
FROM node:24.19.0-alpine AS base
WORKDIR /app
COPY package*.json prisma.config.js ./
COPY prisma ./prisma
RUN npm ci
COPY src ./src
COPY tests ./tests

# Estágio de teste
FROM base AS test
ENV NODE_ENV=test
CMD ["npm", "test"]


# Estágio de produção
FROM node:24.19.0-alpine AS production
WORKDIR /app
ENV NODE_ENV=production
COPY package*.json prisma.config.js ./
COPY prisma ./prisma

# Limpa o cache junto
RUN npm ci --omit=dev && npm cache clean --force

COPY src ./src

EXPOSE 3000

CMD ["node", "src/server.js"]
