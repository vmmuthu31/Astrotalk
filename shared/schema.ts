import { sql, relations } from "drizzle-orm";
import { pgTable, text, varchar, timestamp, boolean, integer, date, time, jsonb } from "drizzle-orm/pg-core";
import { createInsertSchema } from "drizzle-zod";
import { z } from "zod";

export const users = pgTable("users", {
  id: varchar("id")
    .primaryKey()
    .default(sql`gen_random_uuid()`),
  name: text("name").notNull(),
  birthDate: date("birth_date").notNull(),
  birthTime: time("birth_time").notNull(),
  birthPlace: text("birth_place").notNull(),
  birthLat: text("birth_lat"),
  birthLng: text("birth_lng"),
  nakshatra: text("nakshatra"),
  rashi: text("rashi"),
  lagnaSign: text("lagna_sign"),
  moonNakshatraLord: text("moon_nakshatra_lord"),
  natalChartData: jsonb("natal_chart_data"),
  isSubscribed: boolean("is_subscribed").default(false),
  subscriptionEndDate: timestamp("subscription_end_date"),
  notificationTime: time("notification_time").default("07:00"),
  language: text("language").default("en"),
  createdAt: timestamp("created_at").defaultNow(),
  pushToken: text("push_token"),
});

export const usersRelations = relations(users, ({ many }) => ({
  dailyPredictions: many(dailyPredictions),
}));

export const dailyPredictions = pgTable("daily_predictions", {
  id: varchar("id")
    .primaryKey()
    .default(sql`gen_random_uuid()`),
  userId: varchar("user_id")
    .notNull()
    .references(() => users.id),
  date: date("date").notNull(),
  rulingPlanet: text("ruling_planet"),
  luckyColor: text("lucky_color").notNull(),
  luckyColorHex: text("lucky_color_hex").notNull(),
  luckyNumber: integer("lucky_number").notNull(),
  luckyDirection: text("lucky_direction").notNull(),
  luckyDirectionHi: text("lucky_direction_hi"),
  luckyTime: text("lucky_time").notNull(),
  luckyTimeWindows: jsonb("lucky_time_windows"),
  mantra: text("mantra"),
  mantraMeaning: text("mantra_meaning"),
  weekdayLord: text("weekday_lord"),
  todayNakshatra: text("today_nakshatra"),
  scores: jsonb("scores"),
  createdAt: timestamp("created_at").defaultNow(),
});

export const dailyPredictionsRelations = relations(dailyPredictions, ({ one }) => ({
  user: one(users, {
    fields: [dailyPredictions.userId],
    references: [users.id],
  }),
}));

export const insertUserSchema = createInsertSchema(users).pick({
  name: true,
  birthDate: true,
  birthTime: true,
  birthPlace: true,
});

export const insertPredictionSchema = createInsertSchema(dailyPredictions).pick({
  userId: true,
  date: true,
  luckyColor: true,
  luckyColorHex: true,
  luckyNumber: true,
  luckyDirection: true,
  luckyTime: true,
  mantra: true,
});

export type InsertUser = z.infer<typeof insertUserSchema>;
export type User = typeof users.$inferSelect;
export type InsertPrediction = z.infer<typeof insertPredictionSchema>;
export type DailyPrediction = typeof dailyPredictions.$inferSelect;
