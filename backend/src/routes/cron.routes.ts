import { FastifyInstance } from "fastify";
import { sendDailyNotifications } from "../services/notification.service";

export async function cronRoutes(fastify: FastifyInstance) {
  fastify.post("/send-daily-notifications", async (req, reply) => {
    try {
      console.log("[API] Manual trigger: send-daily-notifications");

      const result = await sendDailyNotifications();

      return reply.send({
        message: "Daily notifications sent successfully",
        ...result,
      });
    } catch (error: any) {
      console.error("[API] Error sending daily notifications:", error);
      return reply.code(500).send({
        success: false,
        error: error.message,
      });
    }
  });

  fastify.get("/health", async (req, reply) => {
    return reply.send({
      status: "ok",
      service: "cron",
      timestamp: new Date().toISOString(),
    });
  });
}
