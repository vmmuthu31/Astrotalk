import React, { useState } from "react";
import { View, StyleSheet, ScrollView, Pressable } from "react-native";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import { useNavigation } from "@react-navigation/native";
import { NativeStackNavigationProp } from "@react-navigation/native-stack";
import { Feather } from "@expo/vector-icons";
import * as Haptics from "expo-haptics";
import { ThemedText } from "@/components/ThemedText";
import StarField from "@/components/StarField";
import { Colors, Spacing, BorderRadius, Typography } from "@/constants/theme";
import type { OnboardingStackParamList } from "@/navigation/OnboardingStackNavigator";

type NavigationProp = NativeStackNavigationProp<OnboardingStackParamList, "LanguageSelection">;

interface Language {
  code: string;
  name: string;
  nativeName: string;
}

const LANGUAGES: Language[] = [
  { code: "en", name: "English", nativeName: "English" },
  { code: "hi", name: "Hindi", nativeName: "हिन्दी" },
  { code: "bn", name: "Bengali", nativeName: "বাংলা" },
  { code: "te", name: "Telugu", nativeName: "తెలుగు" },
  { code: "mr", name: "Marathi", nativeName: "मराठी" },
  { code: "ta", name: "Tamil", nativeName: "தமிழ்" },
  { code: "gu", name: "Gujarati", nativeName: "ગુજરાતી" },
  { code: "kn", name: "Kannada", nativeName: "ಕನ್ನಡ" },
  { code: "ml", name: "Malayalam", nativeName: "മലയാളം" },
  { code: "pa", name: "Punjabi", nativeName: "ਪੰਜਾਬੀ" },
  { code: "or", name: "Odia", nativeName: "ଓଡ଼ିଆ" },
  { code: "as", name: "Assamese", nativeName: "অসমীয়া" },
];

export default function LanguageSelectionScreen() {
  const insets = useSafeAreaInsets();
  const navigation = useNavigation<NavigationProp>();
  const theme = Colors.dark;
  const [selectedLanguage, setSelectedLanguage] = useState("en");

  const handleSelectLanguage = (code: string) => {
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    setSelectedLanguage(code);
  };

  const handleContinue = () => {
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
    navigation.navigate("BirthDetails", { language: selectedLanguage });
  };

  return (
    <View style={[styles.container, { backgroundColor: theme.backgroundRoot }]}>
      <StarField count={50} />
      <ScrollView
        contentContainerStyle={[
          styles.content,
          { paddingTop: insets.top + Spacing.xl, paddingBottom: insets.bottom + Spacing.xl },
        ]}
        showsVerticalScrollIndicator={false}
      >
        <View style={styles.header}>
          <ThemedText style={styles.title}>Choose Your Language</ThemedText>
          <ThemedText style={styles.subtitle}>अपनी भाषा चुनें</ThemedText>
        </View>

        <View style={styles.languageGrid}>
          {LANGUAGES.map((lang) => (
            <Pressable
              key={lang.code}
              style={[
                styles.languageCard,
                { 
                  backgroundColor: selectedLanguage === lang.code 
                    ? theme.secondary 
                    : theme.cardBackground,
                  borderColor: selectedLanguage === lang.code 
                    ? theme.secondary 
                    : theme.backgroundSecondary,
                },
              ]}
              onPress={() => handleSelectLanguage(lang.code)}
            >
              <ThemedText 
                style={[
                  styles.nativeName,
                  { color: selectedLanguage === lang.code ? "#FFFFFF" : theme.text }
                ]}
              >
                {lang.nativeName}
              </ThemedText>
              <ThemedText 
                style={[
                  styles.englishName,
                  { color: selectedLanguage === lang.code ? "rgba(255,255,255,0.8)" : theme.textSecondary }
                ]}
              >
                {lang.name}
              </ThemedText>
              {selectedLanguage === lang.code ? (
                <View style={styles.checkmark}>
                  <Feather name="check" size={16} color="#FFFFFF" />
                </View>
              ) : null}
            </Pressable>
          ))}
        </View>

        <Pressable
          style={({ pressed }) => [
            styles.continueButton,
            { backgroundColor: theme.secondary },
            pressed && styles.buttonPressed,
          ]}
          onPress={handleContinue}
        >
          <ThemedText style={styles.continueButtonText}>Continue</ThemedText>
          <Feather name="arrow-right" size={20} color="#FFFFFF" />
        </Pressable>
      </ScrollView>
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
  header: {
    alignItems: "center",
    marginBottom: Spacing["2xl"],
  },
  title: {
    ...Typography.h2,
    color: Colors.dark.text,
    textAlign: "center",
  },
  subtitle: {
    ...Typography.h4,
    color: Colors.dark.accent,
    marginTop: Spacing.sm,
  },
  languageGrid: {
    flexDirection: "row",
    flexWrap: "wrap",
    justifyContent: "space-between",
    gap: Spacing.md,
  },
  languageCard: {
    width: "47%",
    paddingVertical: Spacing.lg,
    paddingHorizontal: Spacing.md,
    borderRadius: BorderRadius.md,
    borderWidth: 1,
    alignItems: "center",
    position: "relative",
  },
  nativeName: {
    ...Typography.h4,
    fontWeight: "600",
  },
  englishName: {
    ...Typography.small,
    marginTop: Spacing.xs,
  },
  checkmark: {
    position: "absolute",
    top: Spacing.sm,
    right: Spacing.sm,
    width: 24,
    height: 24,
    borderRadius: 12,
    backgroundColor: "rgba(255,255,255,0.3)",
    alignItems: "center",
    justifyContent: "center",
  },
  continueButton: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "center",
    padding: Spacing.lg,
    borderRadius: BorderRadius.md,
    marginTop: Spacing["2xl"],
    gap: Spacing.sm,
  },
  buttonPressed: {
    opacity: 0.9,
    transform: [{ scale: 0.98 }],
  },
  continueButtonText: {
    ...Typography.body,
    color: "#FFFFFF",
    fontWeight: "600",
  },
});
