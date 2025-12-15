import React, { useState } from "react";
import { View, StyleSheet, Pressable, ScrollView, Alert, Platform } from "react-native";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import { useNavigation, useRoute, RouteProp } from "@react-navigation/native";
import { Feather } from "@expo/vector-icons";
import { ThemedText } from "@/components/ThemedText";
import StarField from "@/components/StarField";
import { Colors, Spacing, BorderRadius, Typography, Shadows } from "@/constants/theme";
import { OnboardingStackParamList } from "@/navigation/OnboardingStackNavigator";
import { useAuth } from "@/lib/auth";

type RouteProps = RouteProp<OnboardingStackParamList, "Subscription">;

const FEATURES = [
  { icon: "check-circle", text: "Daily Lucky Color & Number" },
  { icon: "check-circle", text: "Auspicious Direction Guidance" },
  { icon: "check-circle", text: "Personalized Lucky Time" },
  { icon: "check-circle", text: "Daily Mantra Recommendations" },
  { icon: "check-circle", text: "Push Notifications" },
  { icon: "check-circle", text: "Nakshatra Birth Chart" },
];

export default function SubscriptionScreen() {
  const insets = useSafeAreaInsets();
  const navigation = useNavigation();
  const route = useRoute<RouteProps>();
  const { setIsOnboarded } = useAuth();
  const theme = Colors.dark;

  const [isProcessing, setIsProcessing] = useState(false);

  const handleSubscribe = async () => {
    setIsProcessing(true);
    setTimeout(() => {
      setIsProcessing(false);
      if (Platform.OS === "web") {
        setIsOnboarded(true);
      } else {
        Alert.alert(
          "UPI AutoPay",
          "UPI AutoPay integration coming soon! For now, enjoy free access.",
          [{ text: "Continue", onPress: () => setIsOnboarded(true) }]
        );
      }
    }, 1500);
  };

  const handleSkip = () => {
    setIsOnboarded(true);
  };

  return (
    <View style={[styles.container, { backgroundColor: theme.backgroundRoot }]}>
      <StarField count={40} />
      <ScrollView
        contentContainerStyle={[
          styles.content,
          { paddingTop: insets.top + Spacing.xl, paddingBottom: insets.bottom + Spacing.xl },
        ]}
        showsVerticalScrollIndicator={false}
      >
        <View style={styles.header}>
          <Pressable
            style={styles.skipButton}
            onPress={handleSkip}
            hitSlop={12}
          >
            <ThemedText style={styles.skipText}>Skip</ThemedText>
          </Pressable>
        </View>

        <View style={styles.titleSection}>
          <ThemedText style={styles.title}>Unlock Your Daily Bhagya</ThemedText>
          <ThemedText style={styles.subtitle}>
            Get personalized cosmic guidance every day
          </ThemedText>
        </View>

        <View style={[styles.pricingCard, { backgroundColor: theme.cardBackground }]}>
          <View style={styles.priceBadge}>
            <ThemedText style={styles.popularText}>Most Popular</ThemedText>
          </View>
          <ThemedText style={styles.planName}>Monthly Plan</ThemedText>
          <View style={styles.priceRow}>
            <ThemedText style={styles.rupee}>Rs.</ThemedText>
            <ThemedText style={styles.price}>99</ThemedText>
            <ThemedText style={styles.period}>/month</ThemedText>
          </View>
          <ThemedText style={styles.upiNote}>via UPI AutoPay</ThemedText>
        </View>

        <View style={styles.featuresSection}>
          {FEATURES.map((feature, index) => (
            <View key={index} style={styles.featureItem}>
              <Feather name={feature.icon as any} size={20} color={theme.success} />
              <ThemedText style={styles.featureText}>{feature.text}</ThemedText>
            </View>
          ))}
        </View>

        <Pressable
          style={({ pressed }) => [
            styles.subscribeButton,
            { backgroundColor: theme.secondary },
            pressed && styles.buttonPressed,
            isProcessing && { opacity: 0.7 },
          ]}
          onPress={handleSubscribe}
          disabled={isProcessing}
        >
          <Feather name="credit-card" size={20} color={theme.buttonText} style={{ marginRight: Spacing.sm }} />
          <ThemedText style={styles.buttonText}>
            {isProcessing ? "Processing..." : "Subscribe with UPI AutoPay"}
          </ThemedText>
        </Pressable>

        <Pressable
          style={({ pressed }) => [
            styles.freeTrialButton,
            { borderColor: theme.accent },
            pressed && styles.buttonPressed,
          ]}
          onPress={handleSkip}
        >
          <ThemedText style={[styles.freeTrialText, { color: theme.accent }]}>
            Start 7-Day Free Trial
          </ThemedText>
        </Pressable>

        <ThemedText style={styles.disclaimer}>
          By subscribing, you agree to our Terms of Service and Privacy Policy.
          Cancel anytime.
        </ThemedText>
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  content: {
    paddingHorizontal: Spacing["2xl"],
    flexGrow: 1,
  },
  header: {
    flexDirection: "row",
    justifyContent: "flex-end",
  },
  skipButton: {
    padding: Spacing.sm,
  },
  skipText: {
    ...Typography.body,
    color: Colors.dark.textSecondary,
  },
  titleSection: {
    alignItems: "center",
    marginTop: Spacing.xl,
    marginBottom: Spacing["3xl"],
  },
  title: {
    ...Typography.h2,
    color: Colors.dark.accent,
    textAlign: "center",
    marginBottom: Spacing.sm,
  },
  subtitle: {
    ...Typography.body,
    color: Colors.dark.textSecondary,
    textAlign: "center",
  },
  pricingCard: {
    padding: Spacing["2xl"],
    borderRadius: BorderRadius.lg,
    alignItems: "center",
    marginBottom: Spacing["3xl"],
    ...Shadows.elevated,
  },
  priceBadge: {
    backgroundColor: Colors.dark.secondary,
    paddingHorizontal: Spacing.lg,
    paddingVertical: Spacing.xs,
    borderRadius: BorderRadius.full,
    marginBottom: Spacing.lg,
  },
  popularText: {
    ...Typography.small,
    fontWeight: "600",
    color: Colors.dark.buttonText,
  },
  planName: {
    ...Typography.h4,
    color: Colors.dark.text,
    marginBottom: Spacing.md,
  },
  priceRow: {
    flexDirection: "row",
    alignItems: "baseline",
  },
  rupee: {
    ...Typography.h4,
    color: Colors.dark.accent,
  },
  price: {
    fontSize: 48,
    fontWeight: "700",
    color: Colors.dark.accent,
  },
  period: {
    ...Typography.body,
    color: Colors.dark.textSecondary,
    marginLeft: Spacing.xs,
  },
  upiNote: {
    ...Typography.small,
    color: Colors.dark.textSecondary,
    marginTop: Spacing.sm,
  },
  featuresSection: {
    marginBottom: Spacing["3xl"],
  },
  featureItem: {
    flexDirection: "row",
    alignItems: "center",
    marginBottom: Spacing.lg,
  },
  featureText: {
    ...Typography.body,
    color: Colors.dark.text,
    marginLeft: Spacing.md,
  },
  subscribeButton: {
    height: Spacing.buttonHeight,
    borderRadius: BorderRadius.md,
    flexDirection: "row",
    justifyContent: "center",
    alignItems: "center",
    marginBottom: Spacing.lg,
  },
  buttonPressed: {
    opacity: 0.7,
  },
  buttonText: {
    ...Typography.body,
    fontWeight: "600",
    color: Colors.dark.buttonText,
  },
  freeTrialButton: {
    height: Spacing.buttonHeight,
    borderRadius: BorderRadius.md,
    borderWidth: 2,
    justifyContent: "center",
    alignItems: "center",
    marginBottom: Spacing["2xl"],
  },
  freeTrialText: {
    ...Typography.body,
    fontWeight: "600",
  },
  disclaimer: {
    ...Typography.small,
    color: Colors.dark.textSecondary,
    textAlign: "center",
  },
});
