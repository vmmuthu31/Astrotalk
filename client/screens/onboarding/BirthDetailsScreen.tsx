import React, { useState } from "react";
import { View, StyleSheet, Pressable, TextInput, Platform } from "react-native";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import { useNavigation, useRoute, RouteProp } from "@react-navigation/native";
import { NativeStackNavigationProp } from "@react-navigation/native-stack";
import { Feather } from "@expo/vector-icons";
import DateTimePicker from "@react-native-community/datetimepicker";
import { ThemedText } from "@/components/ThemedText";
import { KeyboardAwareScrollViewCompat } from "@/components/KeyboardAwareScrollViewCompat";
import StarField from "@/components/StarField";
import { Colors, Spacing, BorderRadius, Typography } from "@/constants/theme";
import { OnboardingStackParamList } from "@/navigation/OnboardingStackNavigator";

type NavigationProp = NativeStackNavigationProp<OnboardingStackParamList, "BirthDetails">;
type RouteProps = RouteProp<OnboardingStackParamList, "BirthDetails">;

export default function BirthDetailsScreen() {
  const insets = useSafeAreaInsets();
  const navigation = useNavigation<NavigationProp>();
  const route = useRoute<RouteProps>();
  const language = route.params?.language ?? "en";
  const theme = Colors.dark;

  const [name, setName] = useState("");
  const [birthDate, setBirthDate] = useState(new Date(1995, 0, 1));
  const [birthTime, setBirthTime] = useState(new Date(1995, 0, 1, 6, 0));
  const [birthPlace, setBirthPlace] = useState("");
  const [showDatePicker, setShowDatePicker] = useState(false);
  const [showTimePicker, setShowTimePicker] = useState(false);

  const handleContinue = () => {
    if (!name.trim() || !birthPlace.trim()) {
      return;
    }
    navigation.navigate("NakshatraMapping", {
      name: name.trim(),
      birthDate: birthDate.toISOString().split("T")[0],
      birthTime: birthTime.toTimeString().slice(0, 5),
      birthPlace: birthPlace.trim(),
      language,
    });
  };

  const formatDate = (date: Date) => {
    return date.toLocaleDateString("en-IN", {
      day: "numeric",
      month: "long",
      year: "numeric",
    });
  };

  const formatTime = (date: Date) => {
    return date.toLocaleTimeString("en-IN", {
      hour: "2-digit",
      minute: "2-digit",
      hour12: true,
    });
  };

  const isFormValid = name.trim() && birthPlace.trim();

  return (
    <View style={[styles.container, { backgroundColor: theme.backgroundRoot }]}>
      <StarField count={40} />
      <KeyboardAwareScrollViewCompat
        contentContainerStyle={[
          styles.content,
          { paddingTop: insets.top + Spacing.xl, paddingBottom: insets.bottom + Spacing.xl },
        ]}
      >
        <Pressable
          style={styles.backButton}
          onPress={() => navigation.goBack()}
          hitSlop={12}
        >
          <Feather name="arrow-left" size={24} color={theme.text} />
        </Pressable>

        <View style={styles.header}>
          <ThemedText style={styles.title}>Your Birth Details</ThemedText>
          <ThemedText style={styles.subtitle}>
            We use this to calculate your personalized daily predictions
          </ThemedText>
        </View>

        <View style={styles.form}>
          <View style={styles.inputGroup}>
            <ThemedText style={styles.label}>Your Name</ThemedText>
            <TextInput
              style={[styles.input, { backgroundColor: theme.backgroundDefault, color: theme.text }]}
              placeholder="Enter your name"
              placeholderTextColor={theme.textSecondary}
              value={name}
              onChangeText={setName}
            />
          </View>

          <View style={styles.inputGroup}>
            <ThemedText style={styles.label}>Date of Birth</ThemedText>
            <Pressable
              style={[styles.pickerButton, { backgroundColor: theme.backgroundDefault }]}
              onPress={() => setShowDatePicker(true)}
            >
              <Feather name="calendar" size={20} color={theme.accent} />
              <ThemedText style={styles.pickerText}>{formatDate(birthDate)}</ThemedText>
            </Pressable>
          </View>

          <View style={styles.inputGroup}>
            <ThemedText style={styles.label}>Time of Birth</ThemedText>
            <Pressable
              style={[styles.pickerButton, { backgroundColor: theme.backgroundDefault }]}
              onPress={() => setShowTimePicker(true)}
            >
              <Feather name="clock" size={20} color={theme.accent} />
              <ThemedText style={styles.pickerText}>{formatTime(birthTime)}</ThemedText>
            </Pressable>
          </View>

          <View style={styles.inputGroup}>
            <ThemedText style={styles.label}>Place of Birth</ThemedText>
            <TextInput
              style={[styles.input, { backgroundColor: theme.backgroundDefault, color: theme.text }]}
              placeholder="e.g., Lucknow, Uttar Pradesh"
              placeholderTextColor={theme.textSecondary}
              value={birthPlace}
              onChangeText={setBirthPlace}
            />
          </View>
        </View>

        <Pressable
          style={({ pressed }) => [
            styles.button,
            { backgroundColor: isFormValid ? theme.secondary : theme.backgroundSecondary },
            pressed && isFormValid && styles.buttonPressed,
          ]}
          onPress={handleContinue}
          disabled={!isFormValid}
        >
          <ThemedText style={[styles.buttonText, !isFormValid && { color: theme.textSecondary }]}>
            Continue
          </ThemedText>
        </Pressable>

        {showDatePicker && (
          <DateTimePicker
            value={birthDate}
            mode="date"
            display={Platform.OS === "ios" ? "spinner" : "default"}
            onChange={(event, date) => {
              setShowDatePicker(Platform.OS === "ios");
              if (date) setBirthDate(date);
            }}
            maximumDate={new Date()}
            minimumDate={new Date(1920, 0, 1)}
          />
        )}

        {showTimePicker && (
          <DateTimePicker
            value={birthTime}
            mode="time"
            display={Platform.OS === "ios" ? "spinner" : "default"}
            onChange={(event, date) => {
              setShowTimePicker(Platform.OS === "ios");
              if (date) setBirthTime(date);
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
    paddingHorizontal: Spacing["2xl"],
    flexGrow: 1,
  },
  backButton: {
    width: 44,
    height: 44,
    justifyContent: "center",
  },
  header: {
    marginTop: Spacing.lg,
    marginBottom: Spacing["3xl"],
  },
  title: {
    ...Typography.h2,
    color: Colors.dark.text,
    marginBottom: Spacing.sm,
  },
  subtitle: {
    ...Typography.body,
    color: Colors.dark.textSecondary,
  },
  form: {
    flex: 1,
  },
  inputGroup: {
    marginBottom: Spacing["2xl"],
  },
  label: {
    ...Typography.small,
    color: Colors.dark.text,
    marginBottom: Spacing.sm,
  },
  input: {
    height: Spacing.inputHeight,
    borderRadius: BorderRadius.sm,
    paddingHorizontal: Spacing.lg,
    ...Typography.body,
  },
  pickerButton: {
    height: Spacing.inputHeight,
    borderRadius: BorderRadius.sm,
    paddingHorizontal: Spacing.lg,
    flexDirection: "row",
    alignItems: "center",
  },
  pickerText: {
    ...Typography.body,
    color: Colors.dark.text,
    marginLeft: Spacing.md,
  },
  button: {
    height: Spacing.buttonHeight,
    borderRadius: BorderRadius.md,
    justifyContent: "center",
    alignItems: "center",
    marginTop: Spacing.xl,
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
