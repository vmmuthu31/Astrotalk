import { FastifyInstance } from "fastify";
import prisma from "../utils/db";

const RAZORPAY_KEY_ID = process.env.RAZORPAY_KEY_ID || "rzp_test_YOUR_KEY";
const RAZORPAY_KEY_SECRET = process.env.RAZORPAY_KEY_SECRET || "YOUR_SECRET";

function getAuthHeader(): string {
  const authString = Buffer.from(
    `${RAZORPAY_KEY_ID}:${RAZORPAY_KEY_SECRET}`
  ).toString("base64");
  return `Basic ${authString}`;
}

export async function paymentRoutes(fastify: FastifyInstance) {
  fastify.post("/create-plan", async (req, reply) => {
    try {
      const response = await fetch("https://api.razorpay.com/v1/plans", {
        method: "POST",
        headers: {
          Authorization: getAuthHeader(),
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          period: "monthly",
          interval: 1,
          item: {
            name: "Bhagya Premium Monthly",
            amount: 9900,
            currency: "INR",
            description: "Monthly subscription for Bhagya Premium features",
          },
          notes: {
            app: "bhagya",
            type: "monthly_subscription",
          },
        }),
      });

      const data = await response.json();

      if (response.ok) {
        return reply.send(data);
      } else {
        return reply.code(response.status).send({ error: data });
      }
    } catch (error: any) {
      return reply.code(500).send({ error: error.message });
    }
  });

  fastify.post("/create-subscription", async (req, reply) => {
    try {
      const { planId, customerPhone, startAt } = req.body as any;

      const now = Date.now();
      const expireBy = Math.floor((now + 24 * 60 * 60 * 1000) / 1000);

      const requestBody: any = {
        plan_id: planId,
        total_count: 12,
        quantity: 1,
        customer_notify: 1,
        expire_by: expireBy,
        notify_info: {
          notify_phone: customerPhone,
        },
      };

      if (startAt) {
        requestBody.start_at = startAt;
      }

      const response = await fetch(
        "https://api.razorpay.com/v1/subscriptions",
        {
          method: "POST",
          headers: {
            Authorization: getAuthHeader(),
            "Content-Type": "application/json",
          },
          body: JSON.stringify(requestBody),
        }
      );

      const data = await response.json();

      if (response.ok) {
        return reply.send(data);
      } else {
        return reply.code(response.status).send({ error: data });
      }
    } catch (error: any) {
      return reply.code(500).send({ error: error.message });
    }
  });

  fastify.post("/verify", async (req, reply) => {
    try {
      const {
        razorpay_payment_id,
        razorpay_subscription_id,
        razorpay_signature,
        userId,
      } = req.body as any;

      if (!userId) {
        return reply.code(400).send({ error: "User ID is required" });
      }

      await prisma.payment.create({
        data: {
          userId,
          amount: 99,
          orderId: razorpay_subscription_id || "manual",
          paymentId: razorpay_payment_id,
          signature: razorpay_signature,
          status: "SUCCESS",
        },
      });

      await prisma.user.update({
        where: { id: userId },
        data: { isPremium: true },
      });

      return reply.send({
        success: true,
        message: "Payment verified and user upgraded",
      });
    } catch (error: any) {
      return reply.code(500).send({ error: error.message });
    }
  });

  fastify.get("/status/:userId", async (req, reply) => {
    try {
      const { userId } = req.params as any;

      const user = await prisma.user.findUnique({
        where: { id: userId },
        select: { isPremium: true },
      });

      if (!user) {
        return reply.code(404).send({ error: "User not found" });
      }

      return reply.send({ isPremium: user.isPremium });
    } catch (error: any) {
      return reply.code(500).send({ error: error.message });
    }
  });
}
