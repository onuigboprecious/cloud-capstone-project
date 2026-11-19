FROM node:22-alpine

WORKDIR /app

# Copy dependency manifests
COPY package*.json ./

# Install production dependencies only
RUN npm install --omit=dev

# Copy backend source
COPY . .

# Ensure persistent data directory exists
RUN mkdir -p /app/data

EXPOSE 5000

ENV PORT=5000
ENV NODE_ENV=production

CMD ["node", "server.js"]
