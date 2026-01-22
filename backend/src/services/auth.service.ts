import prisma from "../utils/db";
import { FastifyInstance } from "fastify";
import bcrypt from "bcryptjs";
import { generateOTP, sendOTPEmail } from "./email.service";

export class AuthService {
  constructor(private app: FastifyInstance) {}

  async sendOTP(email: string) {
    const otp = generateOTP();
    const expiresAt = new Date(Date.now() + 10 * 60 * 1000);

    await prisma.otp.deleteMany({ where: { email } });

    await prisma.otp.create({
      data: {
        email,
        code: otp,
        expiresAt,
      },
    });

    const sent = await sendOTPEmail(email, otp);
    if (!sent) {
      throw new Error("Failed to send OTP email");
    }

    return { success: true, message: "OTP sent to email" };
  }

  async verifyOTP(email: string, code: string) {
    const otpRecord = await prisma.otp.findFirst({
      where: {
        email,
        code,
        verified: false,
        expiresAt: { gt: new Date() },
      },
    });

    if (!otpRecord) {
      throw new Error("Invalid or expired OTP");
    }

    await prisma.otp.update({
      where: { id: otpRecord.id },
      data: { verified: true },
    });

    let user = await prisma.user.findFirst({ where: { email } });

    if (!user) {
      user = await prisma.user.create({
        data: {
          email,
          passwordHash: await bcrypt.hash(code, 10),
          name: "User",
          birthDate: new Date(),
          birthTime: "12:00",
          birthPlace: "Unknown",
        },
      });
    }

    const token = this.app.jwt.sign({ id: user.id, email: user.email });

    return { token, user };
  }

  async register(data: any) {
    const {
      email,
      phone,
      name,
      birthDate,
      birthTime,
      birthPlace,
      rashi,
      nakshatra,
    } = data;

    const identifier = email || phone;
    if (!identifier) {
      throw new Error("Email or phone is required");
    }

    const whereClause = email ? { email } : { phone };
    const existing = await prisma.user.findFirst({ where: whereClause });

    if (existing) {
      throw new Error("User already exists");
    }

    const parsedDate = birthDate ? new Date(birthDate) : new Date();
    const validDate = isNaN(parsedDate.getTime()) ? new Date() : parsedDate;

    const user = await prisma.user.create({
      data: {
        email: email || null,
        phone: phone || null,
        passwordHash: await bcrypt.hash("bhagya_temp_pass", 10),
        name: name || "User",
        birthDate: validDate,
        birthTime: birthTime || "12:00",
        birthPlace: birthPlace || "Unknown",
        rashi: rashi || null,
        nakshatra: nakshatra || null,
      },
    });

    return user;
  }

  async login(data: any) {
    const { email, phone, password } = data;

    const whereClause = email ? { email } : { phone };
    const user = await prisma.user.findFirst({ where: whereClause });

    if (!user) {
      throw new Error("User not found");
    }

    if (password) {
      const valid = await bcrypt.compare(password, user.passwordHash);
      if (!valid) {
        throw new Error("Invalid credentials");
      }
    }

    const token = this.app.jwt.sign({ id: user.id, email: user.email });

    return { token, user };
  }

  async updateProfile(userId: string, data: any) {
    const { name, birthDate, birthTime, birthPlace, rashi, nakshatra } = data;

    const user = await prisma.user.update({
      where: { id: userId },
      data: {
        name,
        birthDate: birthDate ? new Date(birthDate) : undefined,
        birthTime,
        birthPlace,
        rashi,
        nakshatra,
      },
    });

    return user;
  }
}
