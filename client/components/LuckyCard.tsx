import React from "react";
import { View, StyleSheet, Pressable } from "react-native";
import { Feather } from "@expo/vector-icons";
import { ThemedText } from "@/components/ThemedText";
import { Colors, Spacing, BorderRadius, Shadows, Typography } from "@/constants/theme";

interface LuckyCardProps {
  title: string;
  value: string;
  icon: keyof typeof Feather.glyphMap;
  color?: string;
  colorHex?: string;
  onPress?: () => void;
}

export default function LuckyCard({ title, value, icon, color, colorHex, onPress }: LuckyCardProps) {
  const theme = Colors.dark;

  return (
    <Pressable
      onPress={onPress}
      style={({ pressed }) => [
        styles.card,
        { backgroundColor: theme.cardBackground },
        pressed && styles.pressed,
      ]}
    >
      <View style={styles.iconContainer}>
        <View style={[styles.iconCircle, { backgroundColor: theme.primary }]}>
          <Feather name={icon} size={24} color={theme.accent} />
        </View>
      </View>
      <View style={styles.content}>
        <ThemedText style={styles.title}>{title}</ThemedText>
        <View style={styles.valueRow}>
          {colorHex ? (
            <View style={[styles.colorSwatch, { backgroundColor: colorHex }]} />
          ) : null}
          <ThemedText style={[styles.value, color ? { color } : null]}>{value}</ThemedText>
        </View>
      </View>
      <Feather name="chevron-right" size={20} color={theme.textSecondary} />
    </Pressable>
  );
}

const styles = StyleSheet.create({
  card: {
    flexDirection: "row",
    alignItems: "center",
    padding: Spacing.lg,
    borderRadius: BorderRadius.md,
    marginBottom: Spacing.md,
    ...Shadows.card,
  },
  pressed: {
    opacity: 0.7,
  },
  iconContainer: {
    marginRight: Spacing.lg,
  },
  iconCircle: {
    width: 48,
    height: 48,
    borderRadius: 24,
    justifyContent: "center",
    alignItems: "center",
  },
  content: {
    flex: 1,
  },
  title: {
    ...Typography.small,
    color: Colors.dark.textSecondary,
    marginBottom: Spacing.xs,
  },
  valueRow: {
    flexDirection: "row",
    alignItems: "center",
  },
  colorSwatch: {
    width: 20,
    height: 20,
    borderRadius: 10,
    marginRight: Spacing.sm,
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.2)",
  },
  value: {
    ...Typography.cardTitle,
    color: Colors.dark.text,
  },
});
