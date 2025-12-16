import React, { useEffect, useState } from "react";
import { View, StyleSheet, ScrollView, RefreshControl, ActivityIndicator, Pressable, Linking, Platform, Share } from "react-native";
import { useBottomTabBarHeight } from "@react-navigation/bottom-tabs";
import { useHeaderHeight } from "@react-navigation/elements";
import { Feather } from "@expo/vector-icons";
import { useQuery } from "@tanstack/react-query";
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withTiming,
  withDelay,
  withRepeat,
  withSequence,
  Easing,
} from "react-native-reanimated";
import * as Haptics from "expo-haptics";
import * as Speech from "expo-speech";
import { ThemedText } from "@/components/ThemedText";
import LuckyCard from "@/components/LuckyCard";
import StarField from "@/components/StarField";
import { Colors, Spacing, BorderRadius, Typography } from "@/constants/theme";
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
  const [isSpeaking, setIsSpeaking] = useState(false);

  const today = new Date();
  const dateString = today.toISOString().split("T")[0];

  const headerScale = useSharedValue(0.9);
  const headerOpacity = useSharedValue(0);
  const dateCardTranslateX = useSharedValue(-50);
  const dateCardOpacity = useSharedValue(0);
  const shareButtonScale = useSharedValue(1);

  const { data: prediction, isLoading, refetch, isRefetching } = useQuery<DailyPrediction>({
    queryKey: [`/api/predictions/${user?.id}?date=${dateString}`],
    enabled: !!user?.id,
  });

  useEffect(() => {
    headerScale.value = withTiming(1, { duration: 600, easing: Easing.out(Easing.back(1.5)) });
    headerOpacity.value = withTiming(1, { duration: 500 });
    
    dateCardTranslateX.value = withDelay(200, withTiming(0, { duration: 500, easing: Easing.out(Easing.ease) }));
    dateCardOpacity.value = withDelay(200, withTiming(1, { duration: 400 }));

    shareButtonScale.value = withDelay(
      1500,
      withRepeat(
        withSequence(
          withTiming(1.05, { duration: 1000 }),
          withTiming(1, { duration: 1000 })
        ),
        3,
        true
      )
    );

    return () => {
      Speech.stop();
    };
  }, []);

  const headerStyle = useAnimatedStyle(() => ({
    transform: [{ scale: headerScale.value }],
    opacity: headerOpacity.value,
  }));

  const dateCardStyle = useAnimatedStyle(() => ({
    transform: [{ translateX: dateCardTranslateX.value }],
    opacity: dateCardOpacity.value,
  }));

  const shareButtonStyle = useAnimatedStyle(() => ({
    transform: [{ scale: shareButtonScale.value }],
  }));

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

  const shareToWhatsApp = async () => {
    if (!prediction) return;

    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
    
    const message = `${prediction.luckyColor} is my lucky color today!

My Daily Bhagya:
Lucky Number: ${prediction.luckyNumber}
Lucky Direction: ${prediction.luckyDirection}
Lucky Time: ${prediction.luckyTime}
${prediction.mantra ? `\nMantra: "${prediction.mantra}"` : ""}

Discover your daily luck with Bhagya app!`;

    const whatsappUrl = `whatsapp://send?text=${encodeURIComponent(message)}`;
    
    try {
      const canOpen = await Linking.canOpenURL(whatsappUrl);
      if (canOpen) {
        await Linking.openURL(whatsappUrl);
      } else {
        await Share.share({ message });
      }
    } catch (error) {
      await Share.share({ message });
    }
  };

  const playMantra = async () => {
    if (!prediction?.mantra) return;

    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);

    if (isSpeaking) {
      Speech.stop();
      setIsSpeaking(false);
      return;
    }

    setIsSpeaking(true);
    
    Speech.speak(prediction.mantra, {
      language: "hi-IN",
      pitch: 1.0,
      rate: 0.85,
      onDone: () => setIsSpeaking(false),
      onStopped: () => setIsSpeaking(false),
      onError: () => setIsSpeaking(false),
    });
  };

  if (isLoading) {
    return (
      <View style={[styles.container, styles.loadingContainer, { backgroundColor: theme.backgroundRoot }]}>
        <StarField count={20} />
        <ActivityIndicator size="large" color={theme.accent} />
        <ThemedText style={styles.loadingText}>Reading the stars...</ThemedText>
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
        <Animated.View style={[styles.header, headerStyle]}>
          <View>
            <ThemedText style={styles.greeting}>{getGreeting()}</ThemedText>
            <ThemedText style={styles.userName}>{user?.name || "User"}</ThemedText>
          </View>
        </Animated.View>

        <Animated.View style={[styles.dateCard, { backgroundColor: theme.cardBackground }, dateCardStyle]}>
          <Feather name="calendar" size={20} color={theme.accent} />
          <ThemedText style={styles.dateText}>{formatDate(today)}</ThemedText>
        </Animated.View>

        <ThemedText style={styles.sectionTitle}>Today's Lucky Guide</ThemedText>

        {prediction ? (
          <>
            <LuckyCard
              title="Lucky Color"
              value={prediction.luckyColor}
              icon="droplet"
              colorHex={prediction.luckyColorHex}
              index={0}
            />
            <LuckyCard
              title="Lucky Number"
              value={prediction.luckyNumber.toString()}
              icon="hash"
              color={theme.accent}
              index={1}
            />
            <LuckyCard
              title="Lucky Direction"
              value={prediction.luckyDirection}
              icon={DIRECTION_ARROWS[prediction.luckyDirection] as any || "compass"}
              index={2}
            />
            <LuckyCard
              title="Lucky Time"
              value={prediction.luckyTime}
              icon="clock"
              index={3}
            />

            {prediction.mantra ? (
              <View style={[styles.mantraCard, { backgroundColor: theme.primary }]}>
                <View style={styles.mantraHeader}>
                  <ThemedText style={styles.mantraLabel}>Today's Mantra</ThemedText>
                  <Pressable
                    style={[
                      styles.playButton,
                      { backgroundColor: isSpeaking ? theme.accent : theme.cardBackground }
                    ]}
                    onPress={playMantra}
                  >
                    <Feather
                      name={isSpeaking ? "pause" : "play"}
                      size={18}
                      color={isSpeaking ? theme.backgroundRoot : theme.accent}
                    />
                    <ThemedText
                      style={[
                        styles.playButtonText,
                        { color: isSpeaking ? theme.backgroundRoot : theme.accent }
                      ]}
                    >
                      {isSpeaking ? "Stop" : "Listen"}
                    </ThemedText>
                  </Pressable>
                </View>
                <ThemedText style={styles.mantraText}>{prediction.mantra}</ThemedText>
              </View>
            ) : null}

            <Animated.View style={[styles.shareSection, shareButtonStyle]}>
              <Pressable
                style={[styles.whatsappButton, { backgroundColor: "#25D366" }]}
                onPress={shareToWhatsApp}
              >
                <Feather name="send" size={20} color="#FFFFFF" />
                <ThemedText style={styles.whatsappButtonText}>Share on WhatsApp</ThemedText>
              </Pressable>
            </Animated.View>

            <View style={styles.viralHint}>
              <Feather name="star" size={14} color={theme.textSecondary} />
              <ThemedText style={styles.viralHintText}>
                Share your luck with friends & family!
              </ThemedText>
            </View>
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
    marginBottom: Spacing.xl,
  },
  mantraHeader: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    marginBottom: Spacing.md,
  },
  mantraLabel: {
    ...Typography.small,
    color: Colors.dark.textSecondary,
  },
  playButton: {
    flexDirection: "row",
    alignItems: "center",
    paddingHorizontal: Spacing.md,
    paddingVertical: Spacing.sm,
    borderRadius: BorderRadius.full,
    gap: Spacing.xs,
  },
  playButtonText: {
    ...Typography.small,
    fontWeight: "600",
  },
  mantraText: {
    ...Typography.h4,
    color: Colors.dark.accent,
    fontStyle: "italic",
  },
  shareSection: {
    marginTop: Spacing.xl,
    gap: Spacing.md,
  },
  whatsappButton: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "center",
    padding: Spacing.lg,
    borderRadius: BorderRadius.md,
    gap: Spacing.md,
  },
  whatsappButtonText: {
    ...Typography.body,
    color: "#FFFFFF",
    fontWeight: "600",
  },
  viralHint: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "center",
    marginTop: Spacing.lg,
    gap: Spacing.sm,
  },
  viralHintText: {
    ...Typography.small,
    color: Colors.dark.textSecondary,
    textAlign: "center",
  },
  emptyCard: {
    padding: Spacing["3xl"],
    borderRadius: BorderRadius.md,
    alignItems: "center",
  },
  emptyText: {
    ...Typography.body,
    color: Colors.dark.textSecondary,
    textAlign: "center",
    marginTop: Spacing.lg,
  },
});
