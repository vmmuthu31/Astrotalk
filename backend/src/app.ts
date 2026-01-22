import Fastify, { FastifyInstance } from "fastify";
import cors from "@fastify/cors";
import customJwt from "@fastify/jwt";
import dotenv from "dotenv";

dotenv.config();

const server: FastifyInstance = Fastify({
  logger: true,
});

import { authRoutes } from "./routes/auth.routes";
import { paymentRoutes } from "./routes/payment.routes";

server.register(cors, {
  origin: true,
});

server.register(customJwt, {
  secret: process.env.JWT_SECRET || "supersecret",
});

server.register(authRoutes, { prefix: "/api/auth" });
server.register(paymentRoutes, { prefix: "/api/payment" });

server.get("/", async () => {
  return { message: "Welcome to the Astro Guide API 🚀" };
});

server.get("/health", async () => {
  return { status: "ok", timestamp: new Date() };
});

const start = async () => {
  try {
    const port = parseInt(process.env.PORT || "3000");
    await server.listen({ port, host: "0.0.0.0" });
    console.log(`Server listening on port ${port}`);
  } catch (err) {
    server.log.error(err);
    process.exit(1);
  }
};

start();
