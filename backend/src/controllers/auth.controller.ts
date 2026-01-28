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

  googleLogin = async (req: FastifyRequest, reply: FastifyReply) => {
    try {
      const { token } = req.body as { token: string };
      if (!token) {
        return reply.code(400).send({ error: "Google token is required" });
      }
      const result = await this.authService.googleLogin(token);
      return reply.send(result);
    } catch (err: any) {
      return reply
        .code(401)
        .send({ error: "Google Authentication Failed: " + err.message });
    }
  };

  sendOTP = async (req: FastifyRequest, reply: FastifyReply) => {
    try {
      const { email } = req.body as { email: string };
      if (!email) {
        return reply.code(400).send({ error: "Email is required" });
      }
      const result = await this.authService.sendOTP(email);
      return reply.send(result);
    } catch (err: any) {
      return reply.code(500).send({ error: err.message });
    }
  };

  verifyOTP = async (req: FastifyRequest, reply: FastifyReply) => {
    try {
      const { email, otp } = req.body as { email: string; otp: string };
      if (!email || !otp) {
        return reply.code(400).send({ error: "Email and OTP are required" });
      }
      const result = await this.authService.verifyOTP(email, otp);
      return reply.send(result);
    } catch (err: any) {
      if (err.message === "Invalid or expired OTP") {
        return reply.code(401).send({ error: err.message });
      }
      return reply.code(500).send({ error: err.message });
    }
  };

  updateProfile = async (req: FastifyRequest, reply: FastifyReply) => {
    try {
      const { userId } = req.params as { userId: string };
      const user = await this.authService.updateProfile(userId, req.body);
      return reply.send(user);
    } catch (err: any) {
      if (
        err.code === "P2025" ||
        err.message?.includes("Record to update not found")
      ) {
        return reply.code(404).send({ error: "User not found" });
      }
      return reply.code(500).send({ error: err.message });
    }
  };
}
