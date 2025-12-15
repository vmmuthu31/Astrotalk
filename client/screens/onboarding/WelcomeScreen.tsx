import React from "react";
import { View, StyleSheet, Pressable, Image } from "react-native";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import { useNavigation } from "@react-navigation/native";
import { NativeStackNavigationProp } from "@react-navigation/native-stack";
import { ThemedText } from "@/components/ThemedText";
import StarField from "@/components/StarField";
import { Colors, Spacing, BorderRadius, Typography } from "@/constants/theme";
import { OnboardingStackParamList } from "@/navigation/OnboardingStackNavigator";

type NavigationProp = NativeStackNavigationProp<OnboardingStackParamList, "Welcome">;

export default function WelcomeScreen() {
  const insets = useSafeAreaInsets();
  const navigation = useNavigation<NavigationProp>();
  const theme = Colors.dark;

  return (
    <View style={[styles.container, { backgroundColor: theme.backgroundRoot }]}>
      <StarField count={80} />
      <View style={[styles.content, { paddingTop: insets.top + Spacing.xl, paddingBottom: insets.bottom + Spacing.xl }]}>
        <View style={styles.logoSection}>
          <Image
            source={require("../../../assets/images/icon.png")}
            style={styles.logo}
            resizeMode="contain"
          />
          <ThemedText style={styles.appName}>Bhagya</ThemedText>
          <ThemedText style={styles.tagline}>Your Daily Cosmic Guide</ThemedText>
          <ThemedText style={styles.taglineHindi}>आपका दैनिक भाग्य मार्गदर्शक</ThemedText>
        </View>

        <View style={styles.featureSection}>
          <FeatureItem icon="star" text="Daily Lucky Color & Number" />
          <FeatureItem icon="compass" text="Auspicious Directions" />
          <FeatureItem icon="clock" text="Lucky Time Predictions" />
          <FeatureItem icon="bell" text="Daily Notifications" />
        </View>

        <Pressable
          style={({ pressed }) => [
            styles.button,
            { backgroundColor: theme.secondary },
            pressed && styles.buttonPressed,
          ]}
          onPress={() => navigation.navigate("BirthDetails")}
        >
          <ThemedText style={styles.buttonText}>Get Started</ThemedText>
        </Pressable>
      </View>
    </View>
  );
}

function FeatureItem({ icon, text }: { icon: string; text: string }) {
  const { Feather } = require("@expo/vector-icons");
  return (
    <View style={styles.featureItem}>
      <View style={styles.featureIcon}>
        <Feather name={icon} size={20} color={Colors.dark.accent} />
      </View>
      <ThemedText style={styles.featureText}>{text}</ThemedText>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  content: {
    flex: 1,
    paddingHorizontal: Spacing["2xl"],
    justifyContent: "space-between",
  },
  logoSection: {
    alignItems: "center",
    marginTop: Spacing["4xl"],
  },
  logo: {
    width: 120,
    height: 120,
    marginBottom: Spacing.lg,
  },
  appName: {
    ...Typography.h1,
    color: Colors.dark.accent,
    marginBottom: Spacing.sm,
  },
  tagline: {
    ...Typography.h4,
    color: Colors.dark.text,
    textAlign: "center",
  },
  taglineHindi: {
    ...Typography.body,
    color: Colors.dark.textSecondary,
    marginTop: Spacing.xs,
  },
  featureSection: {
    marginVertical: Spacing["3xl"],
  },
  featureItem: {
    flexDirection: "row",
    alignItems: "center",
    marginBottom: Spacing.lg,
  },
  featureIcon: {
    width: 44,
    height: 44,
    borderRadius: 22,
    backgroundColor: Colors.dark.primary,
    justifyContent: "center",
    alignItems: "center",
    marginRight: Spacing.lg,
  },
  featureText: {
    ...Typography.body,
    color: Colors.dark.text,
  },
  button: {
    height: Spacing.buttonHeight,
    borderRadius: BorderRadius.md,
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
});
