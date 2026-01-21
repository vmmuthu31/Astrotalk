import { FastifyReply, FastifyRequest } from "fastify";
import { AuthService } from "../services/auth.service";

export class AuthController {
  constructor(private authService: AuthService) {}

  register = async (req: FastifyRequest, reply: FastifyReply) => {
    try {
      const user = await this.authService.register(req.body);
      return reply.code(201).send(user);
    } catch (err: any) {
      if (err.message === "User already exists") {
        return reply.code(409).send({ error: err.message });
      }
      return reply.code(500).send({ error: err.message });
    }
  };

  login = async (req: FastifyRequest, reply: FastifyReply) => {
    try {
      const result = await this.authService.login(req.body);
      return reply.send(result);
    } catch (err: any) {
      return reply.code(401).send({ error: err.message });
    }
  };
}
