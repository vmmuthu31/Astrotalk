import prisma from "../utils/db";

interface DailyPrediction {
  luckyColor: string;
  luckyNumber: number;
  luckyDirection: string;
  luckyTime: string;
  mantra: string;
}

const rashiPredictions: Record<string, any> = {
  Mesha: {
    colors: ["Red", "Coral", "Crimson"],
    numbers: [1, 9, 8],
    directions: ["East", "North-East"],
    mantras: ["ॐ श्री गणेशाय नमः", "ॐ नमो भगवते वासुदेवाय"],
  },
  Vrishabha: {
    colors: ["White", "Green", "Pink"],
    numbers: [2, 6, 9],
    directions: ["South-East", "South"],
    mantras: ["ॐ शुक्राय नमः", "ॐ लक्ष्मी नारायणाय नमः"],
  },
  Mithuna: {
    colors: ["Green", "Yellow", "Light Blue"],
    numbers: [3, 5, 6],
    directions: ["West", "North-West"],
    mantras: ["ॐ बुधाय नमः", "ॐ श्री सरस्वत्यै नमः"],
  },
  Karka: {
    colors: ["White", "Silver", "Pearl"],
    numbers: [2, 4, 7],
    directions: ["North", "North-West"],
    mantras: ["ॐ चंद्राय नमः", "ॐ श्री दुर्गायै नमः"],
  },
  Simha: {
    colors: ["Gold", "Orange", "Saffron"],
    numbers: [1, 4, 5],
    directions: ["East", "South-East"],
    mantras: ["ॐ सूर्याय नमः", "ॐ श्री रामाय नमः"],
  },
  Kanya: {
    colors: ["Green", "Yellow", "White"],
    numbers: [3, 5, 6],
    directions: ["South", "South-West"],
    mantras: ["ॐ बुधाय नमः", "ॐ श्री विष्णवे नमः"],
  },
  Tula: {
    colors: ["White", "Blue", "Pink"],
    numbers: [2, 6, 9],
    directions: ["West", "North-West"],
    mantras: ["ॐ शुक्राय नमः", "ॐ श्री कृष्णाय नमः"],
  },
  Vrishchika: {
    colors: ["Red", "Maroon", "Crimson"],
    numbers: [1, 4, 9],
    directions: ["North", "North-East"],
    mantras: ["ॐ मंगलाय नमः", "ॐ नमः शिवाय"],
  },
  Dhanu: {
    colors: ["Yellow", "Gold", "Saffron"],
    numbers: [3, 5, 8],
    directions: ["East", "North-East"],
    mantras: ["ॐ बृहस्पतये नमः", "ॐ श्री हनुमते नमः"],
  },
  Makara: {
    colors: ["Black", "Navy Blue", "Brown"],
    numbers: [4, 8, 6],
    directions: ["South", "South-West"],
    mantras: ["ॐ शनैश्चराय नमः", "ॐ श्री शनि देवाय नमः"],
  },
  Kumbha: {
    colors: ["Blue", "Black", "Electric Blue"],
    numbers: [4, 8, 7],
    directions: ["West", "South-West"],
    mantras: ["ॐ शनैश्चराय नमः", "ॐ श्री राधा कृष्णाय नमः"],
  },
  Meena: {
    colors: ["Yellow", "Sea Green", "White"],
    numbers: [3, 7, 9],
    directions: ["North", "North-East"],
    mantras: ["ॐ बृहस्पतये नमः", "ॐ श्री विष्णवे नमः"],
  },
};

function generateDailyPrediction(rashi: string, date: Date): DailyPrediction {
  const rashiData = rashiPredictions[rashi] || rashiPredictions["Mesha"];
  const seed =
    date.getFullYear() * 10000 + (date.getMonth() + 1) * 100 + date.getDate();

  const random = (max: number) => Math.floor((Math.sin(seed) * 10000) % max);

  const colorIndex = random(rashiData.colors.length);
  const numberIndex = random(rashiData.numbers.length);
  const directionIndex = random(rashiData.directions.length);
  const mantraIndex = random(rashiData.mantras.length);

  const hour = 5 + random(6);
  const endHour = hour + 2 + random(2);

  return {
    luckyColor: rashiData.colors[colorIndex],
    luckyNumber: rashiData.numbers[numberIndex],
    luckyDirection: rashiData.directions[directionIndex],
    luckyTime: `${hour}:00 AM - ${endHour > 12 ? endHour - 12 : endHour}:00 ${endHour >= 12 ? "PM" : "AM"}`,
    mantra: rashiData.mantras[mantraIndex],
  };
}

export async function sendDailyNotifications() {
  try {
    console.log("[CRON] Starting daily notifications...");

    const users = await prisma.user.findMany({
      where: {
        rashi: { not: null },
      },
      select: {
        id: true,
        name: true,
        email: true,
        rashi: true,
      },
    });

    console.log(`[CRON] Found ${users.length} users to notify`);

    const today = new Date();
    const results = [];

    for (const user of users) {
      try {
        const prediction = generateDailyPrediction(user.rashi!, today);

        console.log(`[NOTIFICATION] User: ${user.name} (${user.email})`);
        console.log(`  Rashi: ${user.rashi}`);
        console.log(`  Lucky Color: ${prediction.luckyColor}`);
        console.log(`  Lucky Number: ${prediction.luckyNumber}`);
        console.log(`  Lucky Direction: ${prediction.luckyDirection}`);
        console.log(`  Lucky Time: ${prediction.luckyTime}`);
        console.log(`  Mantra: ${prediction.mantra}`);

        results.push({
          userId: user.id,
          name: user.name,
          status: "sent",
          prediction,
        });
      } catch (error: any) {
        console.error(
          `[ERROR] Failed to send notification to ${user.name}:`,
          error.message,
        );
        results.push({
          userId: user.id,
          name: user.name,
          status: "failed",
          error: error.message,
        });
      }
    }

    console.log(
      `[CRON] Completed. Success: ${results.filter((r) => r.status === "sent").length}, Failed: ${results.filter((r) => r.status === "failed").length}`,
    );

    return {
      success: true,
      totalUsers: users.length,
      results,
    };
  } catch (error: any) {
    console.error("[CRON] Fatal error in sendDailyNotifications:", error);
    throw error;
  }
}
