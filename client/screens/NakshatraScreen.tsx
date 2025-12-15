import React from "react";
import { View, StyleSheet, ScrollView } from "react-native";
import { useBottomTabBarHeight } from "@react-navigation/bottom-tabs";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import { Feather } from "@expo/vector-icons";
import Svg, { Circle, Line, G } from "react-native-svg";
import { ThemedText } from "@/components/ThemedText";
import { Colors, Spacing, BorderRadius, Typography, Shadows } from "@/constants/theme";
import { useAuth } from "@/lib/auth";

const NAKSHATRA_INFO: Record<string, { ruler: string; deity: string; element: string; symbol: string }> = {
  "Ashwini": { ruler: "Ketu", deity: "Ashwini Kumaras", element: "Earth", symbol: "Horse Head" },
  "Bharani": { ruler: "Venus", deity: "Yama", element: "Earth", symbol: "Yoni" },
  "Krittika": { ruler: "Sun", deity: "Agni", element: "Earth", symbol: "Razor" },
  "Rohini": { ruler: "Moon", deity: "Brahma", element: "Earth", symbol: "Cart" },
  "Mrigashira": { ruler: "Mars", deity: "Soma", element: "Earth", symbol: "Deer Head" },
  "Ardra": { ruler: "Rahu", deity: "Rudra", element: "Water", symbol: "Teardrop" },
  "Punarvasu": { ruler: "Jupiter", deity: "Aditi", element: "Water", symbol: "Bow" },
  "Pushya": { ruler: "Saturn", deity: "Brihaspati", element: "Water", symbol: "Flower" },
  "Ashlesha": { ruler: "Mercury", deity: "Nagas", element: "Water", symbol: "Serpent" },
  "Magha": { ruler: "Ketu", deity: "Pitris", element: "Water", symbol: "Throne" },
  "Purva Phalguni": { ruler: "Venus", deity: "Bhaga", element: "Water", symbol: "Hammock" },
  "Uttara Phalguni": { ruler: "Sun", deity: "Aryaman", element: "Fire", symbol: "Bed" },
  "Hasta": { ruler: "Moon", deity: "Savitar", element: "Fire", symbol: "Hand" },
  "Chitra": { ruler: "Mars", deity: "Tvashtar", element: "Fire", symbol: "Pearl" },
  "Swati": { ruler: "Rahu", deity: "Vayu", element: "Fire", symbol: "Coral" },
  "Vishakha": { ruler: "Jupiter", deity: "Indragni", element: "Fire", symbol: "Archway" },
  "Anuradha": { ruler: "Saturn", deity: "Mitra", element: "Fire", symbol: "Lotus" },
  "Jyeshtha": { ruler: "Mercury", deity: "Indra", element: "Air", symbol: "Earring" },
  "Mula": { ruler: "Ketu", deity: "Nirrti", element: "Air", symbol: "Root" },
  "Purva Ashadha": { ruler: "Venus", deity: "Apas", element: "Air", symbol: "Fan" },
  "Uttara Ashadha": { ruler: "Sun", deity: "Vishvadevas", element: "Air", symbol: "Tusk" },
  "Shravana": { ruler: "Moon", deity: "Vishnu", element: "Air", symbol: "Ear" },
  "Dhanishta": { ruler: "Mars", deity: "Vasus", element: "Ether", symbol: "Drum" },
  "Shatabhisha": { ruler: "Rahu", deity: "Varuna", element: "Ether", symbol: "Circle" },
  "Purva Bhadrapada": { ruler: "Jupiter", deity: "Ajaikapada", element: "Ether", symbol: "Sword" },
  "Uttara Bhadrapada": { ruler: "Saturn", deity: "Ahirbudhnya", element: "Ether", symbol: "Twins" },
  "Revati": { ruler: "Mercury", deity: "Pushan", element: "Ether", symbol: "Fish" },
};

const CONSTELLATION_POINTS = [
  { x: 0.5, y: 0.15 },
  { x: 0.3, y: 0.3 },
  { x: 0.7, y: 0.3 },
  { x: 0.2, y: 0.5 },
  { x: 0.8, y: 0.5 },
  { x: 0.35, y: 0.7 },
  { x: 0.65, y: 0.7 },
  { x: 0.5, y: 0.85 },
];

const CONSTELLATION_LINES = [
  [0, 1], [0, 2], [1, 3], [2, 4], [1, 2],
  [3, 5], [4, 6], [5, 6], [5, 7], [6, 7],
];

export default function NakshatraScreen() {
  const tabBarHeight = useBottomTabBarHeight();
  const insets = useSafeAreaInsets();
  const { user } = useAuth();
  const theme = Colors.dark;

  const nakshatra = user?.nakshatra || "Ashwini";
  const rashi = user?.rashi || "Aries";
  const info = NAKSHATRA_INFO[nakshatra] || NAKSHATRA_INFO["Ashwini"];

  const chartSize = 280;
  const centerX = chartSize / 2;
  const centerY = chartSize / 2;
  const scale = chartSize * 0.4;

  return (
    <View style={[styles.container, { backgroundColor: theme.backgroundRoot }]}>
      <ScrollView
        contentContainerStyle={[
          styles.content,
          { paddingTop: Spacing.xl, paddingBottom: tabBarHeight + Spacing.xl },
        ]}
        showsVerticalScrollIndicator={false}
      >
        <View style={[styles.chartCard, { backgroundColor: theme.cardBackground }]}>
          <Svg width={chartSize} height={chartSize}>
            <G>
              {CONSTELLATION_LINES.map(([from, to], index) => (
                <Line
                  key={`line-${index}`}
                  x1={centerX + (CONSTELLATION_POINTS[from].x - 0.5) * scale}
                  y1={centerY + (CONSTELLATION_POINTS[from].y - 0.5) * scale}
                  x2={centerX + (CONSTELLATION_POINTS[to].x - 0.5) * scale}
                  y2={centerY + (CONSTELLATION_POINTS[to].y - 0.5) * scale}
                  stroke={theme.accent}
                  strokeWidth={1.5}
                  strokeOpacity={0.6}
                />
              ))}
              {CONSTELLATION_POINTS.map((point, index) => (
                <Circle
                  key={`star-${index}`}
                  cx={centerX + (point.x - 0.5) * scale}
                  cy={centerY + (point.y - 0.5) * scale}
                  r={index === 0 ? 8 : 5}
                  fill={index === 0 ? theme.accent : theme.text}
                />
              ))}
            </G>
          </Svg>
          <ThemedText style={styles.nakshatraName}>{nakshatra}</ThemedText>
          <ThemedText style={styles.rashiName}>Rashi: {rashi}</ThemedText>
        </View>

        <ThemedText style={styles.sectionTitle}>Nakshatra Details</ThemedText>

        <View style={[styles.detailsCard, { backgroundColor: theme.cardBackground }]}>
          <DetailRow icon="star" label="Ruling Planet" value={info.ruler} />
          <DetailRow icon="sun" label="Deity" value={info.deity} />
          <DetailRow icon="wind" label="Element" value={info.element} />
          <DetailRow icon="target" label="Symbol" value={info.symbol} />
        </View>

        <ThemedText style={styles.sectionTitle}>Birth Details</ThemedText>

        <View style={[styles.detailsCard, { backgroundColor: theme.cardBackground }]}>
          <DetailRow icon="user" label="Name" value={user?.name || "-"} />
          <DetailRow icon="calendar" label="Birth Date" value={user?.birthDate || "-"} />
          <DetailRow icon="clock" label="Birth Time" value={user?.birthTime || "-"} />
          <DetailRow icon="map-pin" label="Birth Place" value={user?.birthPlace || "-"} />
        </View>
      </ScrollView>
    </View>
  );
}

function DetailRow({ icon, label, value }: { icon: string; label: string; value: string }) {
  const theme = Colors.dark;
  return (
    <View style={styles.detailRow}>
      <View style={styles.detailLeft}>
        <Feather name={icon as any} size={18} color={theme.accent} />
        <ThemedText style={styles.detailLabel}>{label}</ThemedText>
      </View>
      <ThemedText style={styles.detailValue}>{value}</ThemedText>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  content: {
    paddingHorizontal: Spacing.lg,
  },
  chartCard: {
    alignItems: "center",
    padding: Spacing["2xl"],
    borderRadius: BorderRadius.lg,
    marginBottom: Spacing["2xl"],
    ...Shadows.elevated,
  },
  nakshatraName: {
    ...Typography.h2,
    color: Colors.dark.accent,
    marginTop: Spacing.lg,
  },
  rashiName: {
    ...Typography.body,
    color: Colors.dark.textSecondary,
    marginTop: Spacing.xs,
  },
  sectionTitle: {
    ...Typography.h4,
    color: Colors.dark.accent,
    marginBottom: Spacing.lg,
  },
  detailsCard: {
    borderRadius: BorderRadius.md,
    padding: Spacing.lg,
    marginBottom: Spacing["2xl"],
    ...Shadows.card,
  },
  detailRow: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    paddingVertical: Spacing.md,
    borderBottomWidth: 1,
    borderBottomColor: "rgba(255,255,255,0.1)",
  },
  detailLeft: {
    flexDirection: "row",
    alignItems: "center",
  },
  detailLabel: {
    ...Typography.body,
    color: Colors.dark.textSecondary,
    marginLeft: Spacing.md,
  },
  detailValue: {
    ...Typography.body,
    color: Colors.dark.text,
    fontWeight: "500",
  },
});
