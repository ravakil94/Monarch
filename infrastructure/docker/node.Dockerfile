FROM node:22-alpine AS build
WORKDIR /app
ARG SERVICE_DIR
COPY ${SERVICE_DIR}/package*.json ./
RUN npm ci --production
COPY ${SERVICE_DIR}/ ./
RUN npm run build 2>/dev/null || true

FROM node:22-alpine
WORKDIR /app
COPY --from=build /app ./
EXPOSE 8080
CMD ["node", "dist/main.js"]
