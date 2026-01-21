import { FastifyInstance } from "fastify";
import { AuthController } from "../controllers/auth.controller";
import { AuthService } from "../services/auth.service";

export async function authRoutes(fastify: FastifyInstance) {
  const authService = new AuthService(fastify);
  const authController = new AuthController(authService);

  fastify.post("/register", authController.register);
  fastify.post("/login", authController.login);
}
