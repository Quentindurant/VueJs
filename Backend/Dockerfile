FROM node:20-alpine

WORKDIR /app

# Dépendances natives pour better-sqlite3
RUN apk add --no-cache python3 make g++

COPY package*.json ./
RUN npm ci --production

COPY . .

# DATABASE_URL nécessaire au moment du build pour prisma generate
ENV DATABASE_URL="file:./dev.db"

# Génère le client Prisma et applique les migrations
RUN npx prisma generate
RUN npx prisma db push

EXPOSE 3000

CMD ["node", "app.js"]
