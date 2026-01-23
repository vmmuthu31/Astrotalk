import cron from "node-cron";
import { sendDailyNotifications } from "../services/notification.service";

export function initCronJobs() {
  cron.schedule(
    "0 8 * * *",
    async () => {
      console.log(
        "[CRON SCHEDULER] Running daily notifications at 8:00 AM IST",
      );
      try {
        await sendDailyNotifications();
      } catch (error) {
        console.error("[CRON SCHEDULER] Error:", error);
      }
    },
    {
      timezone: "Asia/Kolkata",
    },
  );

  console.log(
    "[CRON] Scheduler initialized - Daily notifications at 8:00 AM IST",
  );
}
