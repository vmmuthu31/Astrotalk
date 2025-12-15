import React, { useState } from "react";
import { View, StyleSheet, Switch, Pressable, Platform } from "react-native";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import DateTimePicker from "@react-native-community/datetimepicker";
import { Feather } from "@expo/vector-icons";
import { ThemedText } from "@/components/ThemedText";
import { KeyboardAwareScrollViewCompat } from "@/components/KeyboardAwareScrollViewCompat";
import { Colors, Spacing, BorderRadius, Typography, Shadows } from "@/constants/theme";
import { useAuth } from "@/lib/auth";

export default function NotificationSettingsScreen() {
  const insets = useSafeAreaInsets();
  const { user } = useAuth();
  const theme = Colors.dark;

  const [dailyEnabled, setDailyEnabled] = useState(true);
  const [weeklyEnabled, setWeeklyEnabled] = useState(false);
  const [notificationTime, setNotificationTime] = useState(new Date(2024, 0, 1, 7, 0));
  const [showTimePicker, setShowTimePicker] = useState(false);

  const formatTime = (date: Date) => {
    return date.toLocaleTimeString("en-IN", {
      hour: "2-digit",
      minute: "2-digit",
      hour12: true,
    });
  };

  return (
    <View style={[styles.container, { backgroundColor: theme.backgroundRoot }]}>
      <KeyboardAwareScrollViewCompat
        contentContainerStyle={[
          styles.content,
          { paddingTop: Spacing.xl, paddingBottom: insets.bottom + Spacing.xl },
        ]}
      >
        <ThemedText style={styles.sectionTitle}>Daily Notifications</ThemedText>

        <View style={[styles.card, { backgroundColor: theme.cardBackground }]}>
          <View style={styles.settingsRow}>
            <View style={styles.settingsLeft}>
              <Feather name="sun" size={20} color={theme.text} />
              <View style={styles.settingsText}>
                <ThemedText style={styles.settingsLabel}>Daily Lucky Predictions</ThemedText>
                <ThemedText style={styles.settingsDescription}>
                  Receive your daily color, number & direction
                </ThemedText>
              </View>
            </View>
            <Switch
              value={dailyEnabled}
              onValueChange={setDailyEnabled}
              trackColor={{ false: theme.backgroundSecondary, true: theme.secondary }}
              thumbColor={theme.text}
            />
          </View>

          {dailyEnabled ? (
            <Pressable
              style={[styles.timeRow, { borderTopColor: "rgba(255,255,255,0.1)" }]}
              onPress={() => setShowTimePicker(true)}
            >
              <View style={styles.settingsLeft}>
                <Feather name="clock" size={20} color={theme.text} />
                <View style={styles.settingsText}>
                  <ThemedText style={styles.settingsLabel}>Notification Time</ThemedText>
                  <ThemedText style={styles.settingsDescription}>
                    When to send daily predictions
                  </ThemedText>
                </View>
              </View>
              <View style={styles.timeValue}>
                <ThemedText style={styles.timeText}>{formatTime(notificationTime)}</ThemedText>
                <Feather name="chevron-right" size={20} color={theme.textSecondary} />
              </View>
            </Pressable>
          ) : null}
        </View>

        <ThemedText style={styles.sectionTitle}>Other Notifications</ThemedText>

        <View style={[styles.card, { backgroundColor: theme.cardBackground }]}>
          <View style={styles.settingsRow}>
            <View style={styles.settingsLeft}>
              <Feather name="calendar" size={20} color={theme.text} />
              <View style={styles.settingsText}>
                <ThemedText style={styles.settingsLabel}>Weekly Summary</ThemedText>
                <ThemedText style={styles.settingsDescription}>
                  Get weekly overview every Sunday
                </ThemedText>
              </View>
            </View>
            <Switch
              value={weeklyEnabled}
              onValueChange={setWeeklyEnabled}
              trackColor={{ false: theme.backgroundSecondary, true: theme.secondary }}
              thumbColor={theme.text}
            />
          </View>
        </View>

        <View style={[styles.infoCard, { backgroundColor: theme.backgroundSecondary }]}>
          <Feather name="info" size={20} color={theme.textSecondary} />
          <ThemedText style={styles.infoText}>
            Push notifications help you start your day with cosmic guidance. 
            You can change these settings anytime.
          </ThemedText>
        </View>

        {showTimePicker && (
          <DateTimePicker
            value={notificationTime}
            mode="time"
            display={Platform.OS === "ios" ? "spinner" : "default"}
            onChange={(event, date) => {
              setShowTimePicker(Platform.OS === "ios");
              if (date) setNotificationTime(date);
            }}
          />
        )}
      </KeyboardAwareScrollViewCompat>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  content: {
    paddingHorizontal: Spacing.lg,
    flexGrow: 1,
  },
  sectionTitle: {
    ...Typography.cardTitle,
    color: Colors.dark.text,
    marginBottom: Spacing.md,
    marginTop: Spacing.lg,
  },
  card: {
    borderRadius: BorderRadius.md,
    ...Shadows.card,
  },
  settingsRow: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    padding: Spacing.lg,
  },
  timeRow: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    padding: Spacing.lg,
    borderTopWidth: 1,
  },
  settingsLeft: {
    flexDirection: "row",
    alignItems: "center",
    flex: 1,
  },
  settingsText: {
    marginLeft: Spacing.md,
    flex: 1,
  },
  settingsLabel: {
    ...Typography.body,
    color: Colors.dark.text,
  },
  settingsDescription: {
    ...Typography.small,
    color: Colors.dark.textSecondary,
    marginTop: Spacing.xs,
  },
  timeValue: {
    flexDirection: "row",
    alignItems: "center",
  },
  timeText: {
    ...Typography.body,
    color: Colors.dark.accent,
    marginRight: Spacing.sm,
  },
  infoCard: {
    flexDirection: "row",
    padding: Spacing.lg,
    borderRadius: BorderRadius.md,
    marginTop: Spacing["2xl"],
  },
  infoText: {
    ...Typography.small,
    color: Colors.dark.textSecondary,
    marginLeft: Spacing.md,
    flex: 1,
  },
});
