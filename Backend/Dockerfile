FROM node:20-alpine

WORKDIR /app

# Dépendances natives pour better-sqlite3
RUN apk add --no-cache python3 make g++

COPY package*.json ./
RUN npm ci --production

COPY . .

# Génère le client Prisma et applique les migrations
RUN npx prisma generate
RUN npx prisma migrate deploy || npx prisma db push

EXPOSE 3000

CMD ["node", "app.js"]
