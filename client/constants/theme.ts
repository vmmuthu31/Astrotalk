import { Platform } from "react-native";

const cosmicPurple = "#4A148C";
const warmSaffron = "#FF6F00";
const celestialGold = "#FFD700";
const deepNavy = "#0A0E27";
const lighterNavy = "#1A1F3A";
const auspiciousGreen = "#4CAF50";
const alertOrange = "#FF9800";

export const Colors = {
  light: {
    text: "#F5F5F5",
    textSecondary: "#B0B0B0",
    buttonText: "#FFFFFF",
    tabIconDefault: "#687076",
    tabIconSelected: celestialGold,
    link: warmSaffron,
    backgroundRoot: deepNavy,
    backgroundDefault: lighterNavy,
    backgroundSecondary: "#252A4A",
    backgroundTertiary: "#303560",
    primary: cosmicPurple,
    secondary: warmSaffron,
    accent: celestialGold,
    success: auspiciousGreen,
    warning: alertOrange,
    cardBackground: "rgba(26, 31, 58, 0.9)",
  },
  dark: {
    text: "#F5F5F5",
    textSecondary: "#B0B0B0",
    buttonText: "#FFFFFF",
    tabIconDefault: "#9BA1A6",
    tabIconSelected: celestialGold,
    link: warmSaffron,
    backgroundRoot: deepNavy,
    backgroundDefault: lighterNavy,
    backgroundSecondary: "#252A4A",
    backgroundTertiary: "#303560",
    primary: cosmicPurple,
    secondary: warmSaffron,
    accent: celestialGold,
    success: auspiciousGreen,
    warning: alertOrange,
    cardBackground: "rgba(26, 31, 58, 0.9)",
  },
};

export const Spacing = {
  xs: 4,
  sm: 8,
  md: 12,
  lg: 16,
  xl: 20,
  "2xl": 24,
  "3xl": 32,
  "4xl": 40,
  "5xl": 48,
  inputHeight: 48,
  buttonHeight: 52,
};

export const BorderRadius = {
  xs: 8,
  sm: 12,
  md: 16,
  lg: 24,
  xl: 30,
  "2xl": 40,
  "3xl": 50,
  full: 9999,
};

export const Typography = {
  h1: {
    fontSize: 32,
    fontWeight: "700" as const,
  },
  h2: {
    fontSize: 28,
    fontWeight: "700" as const,
  },
  h3: {
    fontSize: 24,
    fontWeight: "600" as const,
  },
  h4: {
    fontSize: 20,
    fontWeight: "600" as const,
  },
  body: {
    fontSize: 16,
    fontWeight: "400" as const,
  },
  small: {
    fontSize: 14,
    fontWeight: "400" as const,
  },
  link: {
    fontSize: 16,
    fontWeight: "400" as const,
  },
  cardTitle: {
    fontSize: 18,
    fontWeight: "600" as const,
  },
};

export const Shadows = {
  card: {
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.10,
    shadowRadius: 2,
    elevation: 3,
  },
  elevated: {
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.15,
    shadowRadius: 8,
    elevation: 5,
  },
};

export const Fonts = Platform.select({
  ios: {
    sans: "system-ui",
    serif: "ui-serif",
    rounded: "ui-rounded",
    mono: "ui-monospace",
  },
  default: {
    sans: "normal",
    serif: "serif",
    rounded: "normal",
    mono: "monospace",
  },
  web: {
    sans: "system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif",
    serif: "Georgia, 'Times New Roman', serif",
    rounded:
      "'SF Pro Rounded', 'Hiragino Maru Gothic ProN', Meiryo, 'MS PGothic', sans-serif",
    mono: "SFMono-Regular, Menlo, Monaco, Consolas, 'Liberation Mono', 'Courier New', monospace",
  },
});
