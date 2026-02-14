import Fastify from "fastify";
import cors from "@fastify/cors";
import rateLimit from "@fastify/rate-limit";

const app = Fastify({ logger: true });

// Middleware
app.register(cors, { origin: true });
app.register(rateLimit, { max: 100, timeWindow: "1 minute" });

// Health
app.get("/health", async () => ({
  status: "UP",
  service: "monarch-gateway",
  version: "0.1.0",
  timestamp: new Date().toISOString(),
}));

// Service routes (proxy to backend services)
const ROUTES: Record<string, { upstream: string; prefix: string }> = {
  identity: { upstream: "http://localhost:8010", prefix: "/api/v1/clients" },
  policy: { upstream: "http://localhost:8011", prefix: "/api/v1/policy" },
  ledger: { upstream: "http://localhost:8012", prefix: "/api/v1/ledger" },
  orders: { upstream: "http://localhost:8001", prefix: "/api/v1/orders" },
};

// Register proxy routes
async function registerProxies() {
  const proxy = await import("@fastify/http-proxy");
  for (const [name, config] of Object.entries(ROUTES)) {
    app.register(proxy.default, {
      upstream: config.upstream,
      prefix: config.prefix,
      rewritePrefix: config.prefix,
    });
    app.log.info(`Registered route: ${config.prefix} -> ${config.upstream}`);
  }
}

// Start
async function start() {
  await registerProxies();
  await app.listen({ port: 3000, host: "0.0.0.0" });
}

start().catch((err) => {
  app.log.error(err);
  process.exit(1);
});
