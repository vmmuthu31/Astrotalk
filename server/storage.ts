import { users, dailyPredictions, type User, type InsertUser, type DailyPrediction, type InsertPrediction } from "@shared/schema";
import { db } from "./db";
import { eq, and, desc } from "drizzle-orm";
import {
  computeNatalChart,
  computeDailyPanchang,
  generateDailyPrediction,
  type NatalChart,
} from "./astrology/calculator";
import type { Planet } from "./astrology/constants";

export interface IStorage {
  getUser(id: string): Promise<User | undefined>;
  createUser(user: InsertUser): Promise<User>;
  updateUser(id: string, data: Partial<User>): Promise<User | undefined>;
  getDailyPrediction(userId: string, date: string): Promise<DailyPrediction | undefined>;
  createDailyPrediction(prediction: InsertPrediction): Promise<DailyPrediction>;
  getOrCreateDailyPrediction(userId: string, date: string): Promise<DailyPrediction>;
}

const DEFAULT_LOCATIONS: Record<string, { lat: number; lng: number }> = {
  'delhi': { lat: 28.6139, lng: 77.209 },
  'mumbai': { lat: 19.076, lng: 72.8777 },
  'bangalore': { lat: 12.9716, lng: 77.5946 },
  'chennai': { lat: 13.0827, lng: 80.2707 },
  'kolkata': { lat: 22.5726, lng: 88.3639 },
  'hyderabad': { lat: 17.385, lng: 78.4867 },
  'pune': { lat: 18.5204, lng: 73.8567 },
  'ahmedabad': { lat: 23.0225, lng: 72.5714 },
  'jaipur': { lat: 26.9124, lng: 75.7873 },
  'lucknow': { lat: 26.8467, lng: 80.9462 },
  'kanpur': { lat: 26.4499, lng: 80.3319 },
  'nagpur': { lat: 21.1458, lng: 79.0882 },
  'indore': { lat: 22.7196, lng: 75.8577 },
  'bhopal': { lat: 23.2599, lng: 77.4126 },
  'patna': { lat: 25.5941, lng: 85.1376 },
  'vadodara': { lat: 22.3072, lng: 73.1812 },
  'surat': { lat: 21.1702, lng: 72.8311 },
  'agra': { lat: 27.1767, lng: 78.0081 },
  'varanasi': { lat: 25.3176, lng: 82.9739 },
  'default': { lat: 28.6139, lng: 77.209 },
};

function getLocationFromPlace(birthPlace: string): { lat: number; lng: number } {
  const place = birthPlace.toLowerCase();
  for (const [city, coords] of Object.entries(DEFAULT_LOCATIONS)) {
    if (place.includes(city)) {
      return coords;
    }
  }
  return DEFAULT_LOCATIONS.default;
}

function getNatalChartFromUser(user: User): { chart: NatalChart; needsPersist: boolean } | null {
  if (user.natalChartData) {
    return { chart: user.natalChartData as unknown as NatalChart, needsPersist: false };
  }
  try {
    const birthDate = new Date(user.birthDate);
    const birthTime = user.birthTime || '12:00';
    let lat: number, lng: number;
    if (user.birthLat && user.birthLng) {
      lat = parseFloat(user.birthLat);
      lng = parseFloat(user.birthLng);
    } else {
      const coords = getLocationFromPlace(user.birthPlace);
      lat = coords.lat;
      lng = coords.lng;
    }
    return { chart: computeNatalChart(birthDate, birthTime, lat, lng), needsPersist: true };
  } catch (error) {
    console.error('Error computing natal chart:', error);
    return null;
  }
}

async function getYesterdayRulingPlanet(userId: string, date: string): Promise<Planet | undefined> {
  const [year, month, day] = date.split('-').map(Number);
  const yesterday = new Date(year, month - 1, day);
  yesterday.setDate(yesterday.getDate() - 1);
  const yesterdayStr = `${yesterday.getFullYear()}-${String(yesterday.getMonth() + 1).padStart(2, '0')}-${String(yesterday.getDate()).padStart(2, '0')}`;
  const [prediction] = await db
    .select()
    .from(dailyPredictions)
    .where(and(eq(dailyPredictions.userId, userId), eq(dailyPredictions.date, yesterdayStr)));
  return prediction?.rulingPlanet as Planet | undefined;
}

async function persistNatalChart(userId: string, natalChart: NatalChart): Promise<void> {
  await db
    .update(users)
    .set({
      nakshatra: natalChart.moonNakshatra,
      rashi: natalChart.moonSign,
      lagnaSign: natalChart.lagnaSign,
      moonNakshatraLord: natalChart.moonNakshatraLord,
      natalChartData: natalChart as any,
    })
    .where(eq(users.id, userId));
}

async function generateVedicPrediction(user: User, date: string, yesterdayRPD?: Planet): Promise<InsertPrediction> {
  const natalResult = getNatalChartFromUser(user);
  if (!natalResult) {
    return generateFallbackPrediction(user.id, date);
  }
  const { chart: natalChart, needsPersist } = natalResult;
  if (needsPersist) {
    await persistNatalChart(user.id, natalChart);
  }
  let lat: number, lng: number;
  if (user.birthLat && user.birthLng) {
    lat = parseFloat(user.birthLat);
    lng = parseFloat(user.birthLng);
  } else {
    const coords = getLocationFromPlace(user.birthPlace);
    lat = coords.lat;
    lng = coords.lng;
  }
  const [year, month, day] = date.split('-').map(Number);
  const localDate = new Date(year, month - 1, day, 6, 0, 0);
  const panchang = computeDailyPanchang(localDate, lat, lng);
  const prediction = generateDailyPrediction(natalChart, panchang, yesterdayRPD);
  const luckyTimeStr = prediction.luckyTimeWindows
    .map((w) => `${w.start} - ${w.end}`)
    .join(', ');
  return {
    userId: user.id,
    date,
    rulingPlanet: prediction.rulingPlanet,
    luckyColor: prediction.luckyColor.name,
    luckyColorHex: prediction.luckyColor.hex,
    luckyNumber: prediction.luckyNumber,
    luckyDirection: prediction.luckyDirection,
    luckyDirectionHi: prediction.luckyDirectionHi,
    luckyTime: luckyTimeStr,
    luckyTimeWindows: prediction.luckyTimeWindows as any,
    mantra: prediction.mantra.sanskrit,
    mantraMeaning: prediction.mantra.meaning,
    weekdayLord: panchang.weekdayLord,
    todayNakshatra: panchang.todayNakshatra,
    scores: prediction.scores as any,
  };
}

function generateFallbackPrediction(userId: string, date: string): InsertPrediction {
  const LUCKY_COLORS = [
    { name: "Red", hex: "#E53935" },
    { name: "Yellow", hex: "#FDD835" },
    { name: "Green", hex: "#43A047" },
    { name: "Blue", hex: "#1E88E5" },
    { name: "White", hex: "#FAFAFA" },
    { name: "Orange", hex: "#FB8C00" },
    { name: "Pink", hex: "#EC407A" },
    { name: "Purple", hex: "#7E57C2" },
    { name: "Maroon", hex: "#6D4C41" },
    { name: "Gold", hex: "#FFD700" },
  ];
  const DIRECTIONS = ["North", "South", "East", "West", "North-East", "North-West", "South-East", "South-West"];
  const MANTRAS = [
    { sanskrit: "Om Namah Shivaya", meaning: "I bow to the auspicious one." },
    { sanskrit: "Om Gan Ganapataye Namah", meaning: "I invoke the remover of obstacles." },
  ];
  const dateObj = new Date(date);
  const seed = dateObj.getDate() + dateObj.getMonth() + userId.charCodeAt(0);
  const colorIndex = seed % LUCKY_COLORS.length;
  const directionIndex = (seed + 3) % DIRECTIONS.length;
  const luckyNumber = ((seed * 7) % 9) + 1;
  const mantraIndex = seed % MANTRAS.length;
  const hours = [6, 7, 8, 9, 10, 11, 14, 15, 16, 17, 18];
  const startHour = hours[(seed + 2) % hours.length];
  const endHour = startHour + 2;
  const luckyTime = `${startHour}:00 AM - ${endHour}:00 AM`;
  return {
    userId,
    date,
    luckyColor: LUCKY_COLORS[colorIndex].name,
    luckyColorHex: LUCKY_COLORS[colorIndex].hex,
    luckyNumber,
    luckyDirection: DIRECTIONS[directionIndex],
    luckyTime,
    mantra: MANTRAS[mantraIndex].sanskrit,
    mantraMeaning: MANTRAS[mantraIndex].meaning,
  };
}

export class DatabaseStorage implements IStorage {
  async getUser(id: string): Promise<User | undefined> {
    const [user] = await db.select().from(users).where(eq(users.id, id));
    return user || undefined;
  }

  async createUser(insertUser: InsertUser): Promise<User> {
    const coords = getLocationFromPlace(insertUser.birthPlace);
    const birthDate = new Date(insertUser.birthDate);
    const natalChart = computeNatalChart(birthDate, insertUser.birthTime, coords.lat, coords.lng);
    const [user] = await db
      .insert(users)
      .values({
        ...insertUser,
        birthLat: coords.lat.toString(),
        birthLng: coords.lng.toString(),
        nakshatra: natalChart.moonNakshatra,
        rashi: natalChart.moonSign,
        lagnaSign: natalChart.lagnaSign,
        moonNakshatraLord: natalChart.moonNakshatraLord,
        natalChartData: natalChart as any,
      })
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
      const user = await this.getUser(userId);
      if (!user) {
        throw new Error('User not found');
      }
      const yesterdayRPD = await getYesterdayRulingPlanet(userId, date);
      const newPrediction = await generateVedicPrediction(user, date, yesterdayRPD);
      prediction = await this.createDailyPrediction(newPrediction);
    }
    return prediction;
  }
}

export const storage = new DatabaseStorage();
