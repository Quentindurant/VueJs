FROM node:20-alpine

WORKDIR /app

# Dépendances natives pour better-sqlite3
RUN apk add --no-cache python3 make g++

COPY package*.json ./
# On installe TOUTES les dépendances (y compris tsx, nécessaire pour Prisma 7)
RUN npm ci

COPY . .

# DATABASE_URL nécessaire au moment du build pour prisma generate
ENV DATABASE_URL="file:./dev.db"

# Génère le client Prisma (émet des .ts avec Prisma 7) et crée la DB
RUN npx prisma generate
RUN npx prisma db push

EXPOSE 3000

# tsx permet à Node de charger les fichiers .ts générés par Prisma 7
CMD ["node", "--import", "tsx", "app.js"]
