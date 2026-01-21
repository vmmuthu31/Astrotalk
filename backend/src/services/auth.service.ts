import prisma from "../utils/db";
import { FastifyInstance } from "fastify";
import bcrypt from "bcryptjs"; // Need to install bcryptjs

export class AuthService {
  constructor(private app: FastifyInstance) {}

  async register(data: any) {
    const { phone, password, name, birthDate, birthTime, birthPlace } = data;

    const existing = await prisma.user.findFirst({
      where: { phone },
    });

    if (existing) {
      throw new Error("User already exists");
    }

    const passwordHash = await bcrypt.hash(password || "defaultpass", 10);

    const user = await prisma.user.create({
      data: {
        phone,
        passwordHash,
        name,
        birthDate: new Date(birthDate),
        birthTime,
        birthPlace,
      },
    });

    return user;
  }

  async login(data: any) {
    const { phone, password } = data;

    const user = await prisma.user.findFirst({
      where: { phone },
    });

    if (!user) {
      throw new Error("User not found");
    }

    const valid = await bcrypt.compare(password, user.passwordHash);
    if (!valid) {
      throw new Error("Invalid credentials");
    }

    const token = this.app.jwt.sign({ id: user.id, phone: user.phone });

    return { token, user };
  }
}
