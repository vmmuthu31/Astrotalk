import React from "react";
import { View, StyleSheet, ScrollView, RefreshControl, ActivityIndicator } from "react-native";
import { useBottomTabBarHeight } from "@react-navigation/bottom-tabs";
import { useHeaderHeight } from "@react-navigation/elements";
import { Feather } from "@expo/vector-icons";
import { useQuery } from "@tanstack/react-query";
import { ThemedText } from "@/components/ThemedText";
import LuckyCard from "@/components/LuckyCard";
import StarField from "@/components/StarField";
import { Colors, Spacing, BorderRadius, Typography, Shadows } from "@/constants/theme";
import { useAuth } from "@/lib/auth";
import type { DailyPrediction } from "@shared/schema";

const DIRECTION_ARROWS: Record<string, string> = {
  "North": "arrow-up",
  "South": "arrow-down",
  "East": "arrow-right",
  "West": "arrow-left",
  "North-East": "arrow-up-right",
  "North-West": "arrow-up-left",
  "South-East": "arrow-down-right",
  "South-West": "arrow-down-left",
};

export default function HomeScreen() {
  const tabBarHeight = useBottomTabBarHeight();
  const headerHeight = useHeaderHeight();
  const { user } = useAuth();
  const theme = Colors.dark;

  const today = new Date();
  const dateString = today.toISOString().split("T")[0];

  const { data: prediction, isLoading, refetch, isRefetching } = useQuery<DailyPrediction>({
    queryKey: [`/api/predictions/${user?.id}?date=${dateString}`],
    enabled: !!user?.id,
  });

  const formatDate = (date: Date) => {
    return date.toLocaleDateString("en-IN", {
      weekday: "long",
      day: "numeric",
      month: "long",
      year: "numeric",
    });
  };

  const getGreeting = () => {
    const hour = today.getHours();
    if (hour < 12) return "Shubh Prabhat";
    if (hour < 17) return "Shubh Dopahar";
    return "Shubh Sandhya";
  };

  if (isLoading) {
    return (
      <View style={[styles.container, styles.loadingContainer, { backgroundColor: theme.backgroundRoot }]}>
        <ActivityIndicator size="large" color={theme.accent} />
        <ThemedText style={styles.loadingText}>Loading your predictions...</ThemedText>
      </View>
    );
  }

  return (
    <View style={[styles.container, { backgroundColor: theme.backgroundRoot }]}>
      <StarField count={30} />
      <ScrollView
        contentContainerStyle={[
          styles.content,
          { paddingTop: headerHeight + Spacing.xl, paddingBottom: tabBarHeight + Spacing.xl },
        ]}
        showsVerticalScrollIndicator={false}
        refreshControl={
          <RefreshControl
            refreshing={isRefetching}
            onRefresh={refetch}
            tintColor={theme.accent}
          />
        }
      >
        <View style={styles.header}>
          <View>
            <ThemedText style={styles.greeting}>{getGreeting()}</ThemedText>
            <ThemedText style={styles.userName}>{user?.name || "User"}</ThemedText>
          </View>
        </View>

        <View style={[styles.dateCard, { backgroundColor: theme.cardBackground }]}>
          <Feather name="calendar" size={20} color={theme.accent} />
          <ThemedText style={styles.dateText}>{formatDate(today)}</ThemedText>
        </View>

        <ThemedText style={styles.sectionTitle}>Today's Lucky Guide</ThemedText>

        {prediction ? (
          <>
            <LuckyCard
              title="Lucky Color"
              value={prediction.luckyColor}
              icon="droplet"
              colorHex={prediction.luckyColorHex}
            />
            <LuckyCard
              title="Lucky Number"
              value={prediction.luckyNumber.toString()}
              icon="hash"
              color={theme.accent}
            />
            <LuckyCard
              title="Lucky Direction"
              value={prediction.luckyDirection}
              icon={DIRECTION_ARROWS[prediction.luckyDirection] as any || "compass"}
            />
            <LuckyCard
              title="Lucky Time"
              value={prediction.luckyTime}
              icon="clock"
            />

            {prediction.mantra ? (
              <View style={[styles.mantraCard, { backgroundColor: theme.primary }]}>
                <ThemedText style={styles.mantraLabel}>Today's Mantra</ThemedText>
                <ThemedText style={styles.mantraText}>{prediction.mantra}</ThemedText>
              </View>
            ) : null}
          </>
        ) : (
          <View style={[styles.emptyCard, { backgroundColor: theme.cardBackground }]}>
            <Feather name="star" size={40} color={theme.textSecondary} />
            <ThemedText style={styles.emptyText}>
              Unable to load predictions. Pull down to refresh.
            </ThemedText>
          </View>
        )}
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  loadingContainer: {
    justifyContent: "center",
    alignItems: "center",
  },
  loadingText: {
    ...Typography.body,
    color: Colors.dark.textSecondary,
    marginTop: Spacing.lg,
  },
  content: {
    paddingHorizontal: Spacing.lg,
  },
  header: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    marginBottom: Spacing["2xl"],
  },
  greeting: {
    ...Typography.body,
    color: Colors.dark.textSecondary,
  },
  userName: {
    ...Typography.h3,
    color: Colors.dark.text,
  },
  dateCard: {
    flexDirection: "row",
    alignItems: "center",
    padding: Spacing.lg,
    borderRadius: BorderRadius.md,
    marginBottom: Spacing["2xl"],
    ...Shadows.card,
  },
  dateText: {
    ...Typography.body,
    color: Colors.dark.text,
    marginLeft: Spacing.md,
  },
  sectionTitle: {
    ...Typography.h4,
    color: Colors.dark.accent,
    marginBottom: Spacing.lg,
  },
  mantraCard: {
    padding: Spacing["2xl"],
    borderRadius: BorderRadius.md,
    marginTop: Spacing.sm,
    ...Shadows.elevated,
  },
  mantraLabel: {
    ...Typography.small,
    color: Colors.dark.textSecondary,
    marginBottom: Spacing.sm,
  },
  mantraText: {
    ...Typography.h4,
    color: Colors.dark.accent,
    fontStyle: "italic",
  },
  emptyCard: {
    padding: Spacing["3xl"],
    borderRadius: BorderRadius.md,
    alignItems: "center",
    ...Shadows.card,
  },
  emptyText: {
    ...Typography.body,
    color: Colors.dark.textSecondary,
    textAlign: "center",
    marginTop: Spacing.lg,
  },
});
