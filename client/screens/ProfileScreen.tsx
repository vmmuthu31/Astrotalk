import React from "react";
import { View, StyleSheet, ScrollView, Pressable, Alert, Platform } from "react-native";
import { useBottomTabBarHeight } from "@react-navigation/bottom-tabs";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import { useNavigation, CommonActions } from "@react-navigation/native";
import { NativeStackNavigationProp } from "@react-navigation/native-stack";
import { Feather } from "@expo/vector-icons";
import { ThemedText } from "@/components/ThemedText";
import { Colors, Spacing, BorderRadius, Typography, Shadows } from "@/constants/theme";
import { useAuth } from "@/lib/auth";
import { RootStackParamList } from "@/navigation/RootStackNavigator";

type NavigationProp = NativeStackNavigationProp<RootStackParamList>;

export default function ProfileScreen() {
  const tabBarHeight = useBottomTabBarHeight();
  const insets = useSafeAreaInsets();
  const navigation = useNavigation<NavigationProp>();
  const { user, logout } = useAuth();
  const theme = Colors.dark;

  const handleLogout = () => {
    if (Platform.OS === "web") {
      logout();
    } else {
      Alert.alert(
        "Logout",
        "Are you sure you want to logout?",
        [
          { text: "Cancel", style: "cancel" },
          { text: "Logout", style: "destructive", onPress: logout },
        ]
      );
    }
  };

  const handleDeleteAccount = () => {
    if (Platform.OS === "web") {
      logout();
    } else {
      Alert.alert(
        "Delete Account",
        "This will permanently delete your account and all data. This action cannot be undone.",
        [
          { text: "Cancel", style: "cancel" },
          {
            text: "Delete",
            style: "destructive",
            onPress: () => {
              Alert.alert(
                "Confirm Deletion",
                "Are you absolutely sure? This is your last chance.",
                [
                  { text: "Cancel", style: "cancel" },
                  { text: "Yes, Delete", style: "destructive", onPress: logout },
                ]
              );
            },
          },
        ]
      );
    }
  };

  return (
    <View style={[styles.container, { backgroundColor: theme.backgroundRoot }]}>
      <ScrollView
        contentContainerStyle={[
          styles.content,
          { paddingTop: Spacing.xl, paddingBottom: tabBarHeight + Spacing.xl },
        ]}
        showsVerticalScrollIndicator={false}
      >
        <View style={[styles.profileCard, { backgroundColor: theme.cardBackground }]}>
          <View style={[styles.avatar, { backgroundColor: theme.primary }]}>
            <Feather name="star" size={32} color={theme.accent} />
          </View>
          <ThemedText style={styles.userName}>{user?.name || "User"}</ThemedText>
          <ThemedText style={styles.nakshatra}>
            {user?.nakshatra || "Nakshatra"} - {user?.rashi || "Rashi"}
          </ThemedText>
        </View>

        <View style={[styles.subscriptionCard, { backgroundColor: theme.primary }]}>
          <View style={styles.subscriptionHeader}>
            <Feather name="award" size={24} color={theme.accent} />
            <ThemedText style={styles.subscriptionTitle}>
              {user?.isSubscribed ? "Premium Member" : "Free Trial"}
            </ThemedText>
          </View>
          <ThemedText style={styles.subscriptionText}>
            {user?.isSubscribed
              ? "You have full access to all features"
              : "Upgrade to unlock all premium features"}
          </ThemedText>
          {!user?.isSubscribed ? (
            <Pressable
              style={({ pressed }) => [
                styles.upgradeButton,
                { backgroundColor: theme.secondary },
                pressed && styles.buttonPressed,
              ]}
            >
              <ThemedText style={styles.upgradeText}>Upgrade Now</ThemedText>
            </Pressable>
          ) : null}
        </View>

        <ThemedText style={styles.sectionTitle}>Settings</ThemedText>

        <View style={[styles.settingsCard, { backgroundColor: theme.cardBackground }]}>
          <SettingsRow
            icon="bell"
            label="Notifications"
            onPress={() => navigation.navigate("NotificationSettings")}
          />
          <SettingsRow
            icon="globe"
            label="Language"
            value="English"
          />
          <SettingsRow
            icon="moon"
            label="Theme"
            value="Dark"
          />
        </View>

        <ThemedText style={styles.sectionTitle}>Account</ThemedText>

        <View style={[styles.settingsCard, { backgroundColor: theme.cardBackground }]}>
          <SettingsRow
            icon="help-circle"
            label="Help & Support"
          />
          <SettingsRow
            icon="file-text"
            label="Terms of Service"
          />
          <SettingsRow
            icon="shield"
            label="Privacy Policy"
          />
        </View>

        <Pressable
          style={({ pressed }) => [
            styles.logoutButton,
            { backgroundColor: theme.backgroundSecondary },
            pressed && styles.buttonPressed,
          ]}
          onPress={handleLogout}
        >
          <Feather name="log-out" size={20} color={theme.warning} />
          <ThemedText style={[styles.logoutText, { color: theme.warning }]}>Logout</ThemedText>
        </Pressable>

        <Pressable
          style={({ pressed }) => [
            styles.deleteButton,
            pressed && styles.buttonPressed,
          ]}
          onPress={handleDeleteAccount}
        >
          <ThemedText style={styles.deleteText}>Delete Account</ThemedText>
        </Pressable>
      </ScrollView>
    </View>
  );
}

function SettingsRow({
  icon,
  label,
  value,
  onPress,
}: {
  icon: string;
  label: string;
  value?: string;
  onPress?: () => void;
}) {
  const theme = Colors.dark;
  return (
    <Pressable
      style={({ pressed }) => [
        styles.settingsRow,
        pressed && onPress && { opacity: 0.7 },
      ]}
      onPress={onPress}
      disabled={!onPress}
    >
      <View style={styles.settingsLeft}>
        <Feather name={icon as any} size={20} color={theme.text} />
        <ThemedText style={styles.settingsLabel}>{label}</ThemedText>
      </View>
      <View style={styles.settingsRight}>
        {value ? (
          <ThemedText style={styles.settingsValue}>{value}</ThemedText>
        ) : null}
        <Feather name="chevron-right" size={20} color={theme.textSecondary} />
      </View>
    </Pressable>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  content: {
    paddingHorizontal: Spacing.lg,
  },
  profileCard: {
    alignItems: "center",
    padding: Spacing["2xl"],
    borderRadius: BorderRadius.lg,
    marginBottom: Spacing["2xl"],
    ...Shadows.card,
  },
  avatar: {
    width: 80,
    height: 80,
    borderRadius: 40,
    justifyContent: "center",
    alignItems: "center",
    marginBottom: Spacing.lg,
  },
  userName: {
    ...Typography.h3,
    color: Colors.dark.text,
    marginBottom: Spacing.xs,
  },
  nakshatra: {
    ...Typography.body,
    color: Colors.dark.textSecondary,
  },
  subscriptionCard: {
    padding: Spacing["2xl"],
    borderRadius: BorderRadius.lg,
    marginBottom: Spacing["2xl"],
    ...Shadows.elevated,
  },
  subscriptionHeader: {
    flexDirection: "row",
    alignItems: "center",
    marginBottom: Spacing.md,
  },
  subscriptionTitle: {
    ...Typography.h4,
    color: Colors.dark.accent,
    marginLeft: Spacing.md,
  },
  subscriptionText: {
    ...Typography.body,
    color: Colors.dark.textSecondary,
    marginBottom: Spacing.lg,
  },
  upgradeButton: {
    height: 44,
    borderRadius: BorderRadius.sm,
    justifyContent: "center",
    alignItems: "center",
  },
  upgradeText: {
    ...Typography.body,
    fontWeight: "600",
    color: Colors.dark.buttonText,
  },
  buttonPressed: {
    opacity: 0.7,
  },
  sectionTitle: {
    ...Typography.cardTitle,
    color: Colors.dark.text,
    marginBottom: Spacing.md,
  },
  settingsCard: {
    borderRadius: BorderRadius.md,
    marginBottom: Spacing["2xl"],
    ...Shadows.card,
  },
  settingsRow: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    padding: Spacing.lg,
    borderBottomWidth: 1,
    borderBottomColor: "rgba(255,255,255,0.1)",
  },
  settingsLeft: {
    flexDirection: "row",
    alignItems: "center",
  },
  settingsLabel: {
    ...Typography.body,
    color: Colors.dark.text,
    marginLeft: Spacing.md,
  },
  settingsRight: {
    flexDirection: "row",
    alignItems: "center",
  },
  settingsValue: {
    ...Typography.body,
    color: Colors.dark.textSecondary,
    marginRight: Spacing.sm,
  },
  logoutButton: {
    flexDirection: "row",
    height: Spacing.buttonHeight,
    borderRadius: BorderRadius.md,
    justifyContent: "center",
    alignItems: "center",
    marginBottom: Spacing.lg,
  },
  logoutText: {
    ...Typography.body,
    fontWeight: "600",
    marginLeft: Spacing.sm,
  },
  deleteButton: {
    height: 44,
    justifyContent: "center",
    alignItems: "center",
    marginBottom: Spacing["2xl"],
  },
  deleteText: {
    ...Typography.small,
    color: Colors.dark.textSecondary,
    textDecorationLine: "underline",
  },
});
