import { users, dailyPredictions, type User, type InsertUser, type DailyPrediction, type InsertPrediction } from "@shared/schema";
import { db } from "./db";
import { eq, and } from "drizzle-orm";

export interface IStorage {
  getUser(id: string): Promise<User | undefined>;
  createUser(user: InsertUser): Promise<User>;
  updateUser(id: string, data: Partial<User>): Promise<User | undefined>;
  getDailyPrediction(userId: string, date: string): Promise<DailyPrediction | undefined>;
  createDailyPrediction(prediction: InsertPrediction): Promise<DailyPrediction>;
  getOrCreateDailyPrediction(userId: string, date: string): Promise<DailyPrediction>;
}

const LUCKY_COLORS = [
  { name: "Red", nameHi: "लाल", hex: "#E53935" },
  { name: "Yellow", nameHi: "पीला", hex: "#FDD835" },
  { name: "Green", nameHi: "हरा", hex: "#43A047" },
  { name: "Blue", nameHi: "नीला", hex: "#1E88E5" },
  { name: "White", nameHi: "सफ़ेद", hex: "#FAFAFA" },
  { name: "Orange", nameHi: "नारंगी", hex: "#FB8C00" },
  { name: "Pink", nameHi: "गुलाबी", hex: "#EC407A" },
  { name: "Purple", nameHi: "बैंगनी", hex: "#7E57C2" },
  { name: "Maroon", nameHi: "मैरून", hex: "#6D4C41" },
  { name: "Gold", nameHi: "सुनहरा", hex: "#FFD700" },
];

const DIRECTIONS = [
  { name: "North", nameHi: "उत्तर" },
  { name: "South", nameHi: "दक्षिण" },
  { name: "East", nameHi: "पूर्व" },
  { name: "West", nameHi: "पश्चिम" },
  { name: "North-East", nameHi: "ईशान" },
  { name: "North-West", nameHi: "वायव्य" },
  { name: "South-East", nameHi: "आग्नेय" },
  { name: "South-West", nameHi: "नैऋत्य" },
];

const MANTRAS = [
  "Om Namah Shivaya",
  "Om Gan Ganapataye Namah",
  "Om Shri Lakshmyai Namah",
  "Gayatri Mantra",
  "Mahamrityunjaya Mantra",
  "Om Namo Bhagavate Vasudevaya",
  "Om Aim Hreem Kleem Chamundaye Vichche",
  "Om Shanti Shanti Shanti",
];

function generatePrediction(userId: string, date: string): InsertPrediction {
  const dateObj = new Date(date);
  const seed = dateObj.getDate() + dateObj.getMonth() + userId.charCodeAt(0);
  
  const colorIndex = seed % LUCKY_COLORS.length;
  const directionIndex = (seed + 3) % DIRECTIONS.length;
  const luckyNumber = ((seed * 7) % 9) + 1;
  const mantraIndex = (seed + 5) % MANTRAS.length;
  
  const hours = [6, 7, 8, 9, 10, 11, 14, 15, 16, 17, 18];
  const startHour = hours[(seed + 2) % hours.length];
  const endHour = startHour + 2;
  const luckyTime = `${startHour}:00 - ${endHour}:00`;

  return {
    userId,
    date,
    luckyColor: LUCKY_COLORS[colorIndex].name,
    luckyColorHex: LUCKY_COLORS[colorIndex].hex,
    luckyNumber,
    luckyDirection: DIRECTIONS[directionIndex].name,
    luckyTime,
    mantra: MANTRAS[mantraIndex],
  };
}

export class DatabaseStorage implements IStorage {
  async getUser(id: string): Promise<User | undefined> {
    const [user] = await db.select().from(users).where(eq(users.id, id));
    return user || undefined;
  }

  async createUser(insertUser: InsertUser): Promise<User> {
    const [user] = await db
      .insert(users)
      .values(insertUser)
      .returning();
    return user;
  }

  async updateUser(id: string, data: Partial<User>): Promise<User | undefined> {
    const [user] = await db
      .update(users)
      .set(data)
      .where(eq(users.id, id))
      .returning();
    return user || undefined;
  }

  async getDailyPrediction(userId: string, date: string): Promise<DailyPrediction | undefined> {
    const [prediction] = await db
      .select()
      .from(dailyPredictions)
      .where(and(eq(dailyPredictions.userId, userId), eq(dailyPredictions.date, date)));
    return prediction || undefined;
  }

  async createDailyPrediction(prediction: InsertPrediction): Promise<DailyPrediction> {
    const [result] = await db
      .insert(dailyPredictions)
      .values(prediction)
      .returning();
    return result;
  }

  async getOrCreateDailyPrediction(userId: string, date: string): Promise<DailyPrediction> {
    let prediction = await this.getDailyPrediction(userId, date);
    if (!prediction) {
      const newPrediction = generatePrediction(userId, date);
      prediction = await this.createDailyPrediction(newPrediction);
    }
    return prediction;
  }
}

export const storage = new DatabaseStorage();
