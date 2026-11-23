FROM node:24-alpine

WORKDIR /app

# Copy dependency
COPY package*.json ./

# Install production dependencies only
RUN npm ci --omit=dev && apk add --no-cache postgresql-client

# Copy backend source code
COPY . .

# Ensure persistent data directory exists
RUN mkdir -p /app/data

EXPOSE 5000

ENV PORT=5000

ENV NODE_ENV=production

CMD ["node", "server.js"]
