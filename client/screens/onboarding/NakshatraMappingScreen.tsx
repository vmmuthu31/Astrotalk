import React, { useEffect, useState } from "react";
import { View, StyleSheet, Dimensions } from "react-native";
import { useNavigation, useRoute, RouteProp } from "@react-navigation/native";
import { NativeStackNavigationProp } from "@react-navigation/native-stack";
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withTiming,
  withDelay,
  withSequence,
  Easing,
  runOnJS,
} from "react-native-reanimated";
import Svg, { Circle, Line, G } from "react-native-svg";
import { ThemedText } from "@/components/ThemedText";
import { Colors, Spacing, Typography } from "@/constants/theme";
import { OnboardingStackParamList } from "@/navigation/OnboardingStackNavigator";
import { useMutation } from "@tanstack/react-query";
import { apiRequest } from "@/lib/query-client";
import { useAuth } from "@/lib/auth";

const { width, height } = Dimensions.get("window");
const AnimatedSvg = Animated.createAnimatedComponent(Svg);

type NavigationProp = NativeStackNavigationProp<OnboardingStackParamList, "NakshatraMapping">;
type RouteProps = RouteProp<OnboardingStackParamList, "NakshatraMapping">;

const NAKSHATRAS = [
  "Ashwini", "Bharani", "Krittika", "Rohini", "Mrigashira",
  "Ardra", "Punarvasu", "Pushya", "Ashlesha", "Magha",
  "Purva Phalguni", "Uttara Phalguni", "Hasta", "Chitra", "Swati",
  "Vishakha", "Anuradha", "Jyeshtha", "Mula", "Purva Ashadha",
  "Uttara Ashadha", "Shravana", "Dhanishta", "Shatabhisha", "Purva Bhadrapada",
  "Uttara Bhadrapada", "Revati",
];

const RASHIS = [
  "Aries", "Taurus", "Gemini", "Cancer", "Leo", "Virgo",
  "Libra", "Scorpio", "Sagittarius", "Capricorn", "Aquarius", "Pisces",
];

function calculateNakshatra(birthDate: string): { nakshatra: string; rashi: string } {
  const date = new Date(birthDate);
  const dayOfYear = Math.floor((date.getTime() - new Date(date.getFullYear(), 0, 0).getTime()) / 86400000);
  const nakshatraIndex = dayOfYear % 27;
  const rashiIndex = Math.floor(nakshatraIndex / 2.25) % 12;
  return {
    nakshatra: NAKSHATRAS[nakshatraIndex],
    rashi: RASHIS[rashiIndex],
  };
}

const CONSTELLATION_POINTS = [
  { x: 0.5, y: 0.2 },
  { x: 0.35, y: 0.35 },
  { x: 0.65, y: 0.35 },
  { x: 0.3, y: 0.5 },
  { x: 0.7, y: 0.5 },
  { x: 0.4, y: 0.65 },
  { x: 0.6, y: 0.65 },
  { x: 0.5, y: 0.8 },
];

const CONSTELLATION_LINES = [
  [0, 1], [0, 2], [1, 3], [2, 4], [1, 2],
  [3, 5], [4, 6], [5, 6], [5, 7], [6, 7],
];

export default function NakshatraMappingScreen() {
  const navigation = useNavigation<NavigationProp>();
  const route = useRoute<RouteProps>();
  const { name, birthDate, birthTime, birthPlace } = route.params;
  const { setUser } = useAuth();

  const [phase, setPhase] = useState(0);
  const [nakshatra, setNakshatra] = useState("");
  const [rashi, setRashi] = useState("");

  const containerOpacity = useSharedValue(1);
  const starsOpacity = useSharedValue(0);
  const linesOpacity = useSharedValue(0);
  const textOpacity = useSharedValue(0);
  const glowScale = useSharedValue(0.8);

  const createUserMutation = useMutation({
    mutationFn: async () => {
      const { nakshatra: n, rashi: r } = calculateNakshatra(birthDate);
      setNakshatra(n);
      setRashi(r);
      const response = await apiRequest("POST", "/api/users", {
        name,
        birthDate,
        birthTime,
        birthPlace,
      });
      return response.json();
    },
    onSuccess: async (user) => {
      await setUser({ ...user, nakshatra, rashi });
      setTimeout(() => {
        navigation.navigate("Subscription", { userId: user.id });
      }, 2000);
    },
  });

  useEffect(() => {
    const { nakshatra: n, rashi: r } = calculateNakshatra(birthDate);
    setNakshatra(n);
    setRashi(r);

    starsOpacity.value = withDelay(500, withTiming(1, { duration: 1000 }));
    linesOpacity.value = withDelay(1500, withTiming(1, { duration: 1000 }));

    glowScale.value = withDelay(
      2500,
      withSequence(
        withTiming(1.2, { duration: 500 }),
        withTiming(1, { duration: 300 })
      )
    );

    textOpacity.value = withDelay(2800, withTiming(1, { duration: 800 }));

    setTimeout(() => setPhase(1), 500);
    setTimeout(() => setPhase(2), 1500);
    setTimeout(() => setPhase(3), 2800);

    createUserMutation.mutate();
  }, []);

  const containerStyle = useAnimatedStyle(() => ({
    opacity: containerOpacity.value,
  }));

  const starsStyle = useAnimatedStyle(() => ({
    opacity: starsOpacity.value,
  }));

  const linesStyle = useAnimatedStyle(() => ({
    opacity: linesOpacity.value,
  }));

  const textStyle = useAnimatedStyle(() => ({
    opacity: textOpacity.value,
    transform: [{ scale: glowScale.value }],
  }));

  const theme = Colors.dark;
  const centerX = width / 2;
  const centerY = height * 0.4;
  const scale = Math.min(width, height) * 0.4;

  return (
    <Animated.View style={[styles.container, { backgroundColor: theme.backgroundRoot }, containerStyle]}>
      <View style={styles.svgContainer}>
        <Svg width={width} height={height * 0.7}>
          <G>
            <Animated.View style={linesStyle}>
              {CONSTELLATION_LINES.map(([from, to], index) => (
                <Line
                  key={`line-${index}`}
                  x1={centerX + (CONSTELLATION_POINTS[from].x - 0.5) * scale}
                  y1={centerY + (CONSTELLATION_POINTS[from].y - 0.5) * scale}
                  x2={centerX + (CONSTELLATION_POINTS[to].x - 0.5) * scale}
                  y2={centerY + (CONSTELLATION_POINTS[to].y - 0.5) * scale}
                  stroke={theme.accent}
                  strokeWidth={1.5}
                  strokeOpacity={0.6}
                />
              ))}
            </Animated.View>
            <Animated.View style={starsStyle}>
              {CONSTELLATION_POINTS.map((point, index) => (
                <Circle
                  key={`star-${index}`}
                  cx={centerX + (point.x - 0.5) * scale}
                  cy={centerY + (point.y - 0.5) * scale}
                  r={index === 0 ? 8 : 5}
                  fill={index === 0 ? theme.accent : theme.text}
                />
              ))}
            </Animated.View>
          </G>
        </Svg>
      </View>

      <View style={styles.textContainer}>
        <ThemedText style={styles.mappingText}>
          {phase < 3 ? "Mapping your stars..." : "Your Nakshatra"}
        </ThemedText>
        <Animated.View style={textStyle}>
          {phase >= 3 ? (
            <>
              <ThemedText style={styles.nakshatraName}>{nakshatra}</ThemedText>
              <ThemedText style={styles.rashiText}>Rashi: {rashi}</ThemedText>
            </>
          ) : null}
        </Animated.View>
      </View>
    </Animated.View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: "center",
    alignItems: "center",
  },
  svgContainer: {
    position: "absolute",
    top: 0,
    left: 0,
    right: 0,
  },
  textContainer: {
    position: "absolute",
    bottom: Spacing["5xl"] * 2,
    alignItems: "center",
    paddingHorizontal: Spacing["2xl"],
  },
  mappingText: {
    ...Typography.body,
    color: Colors.dark.textSecondary,
    marginBottom: Spacing.lg,
  },
  nakshatraName: {
    ...Typography.h2,
    color: Colors.dark.accent,
    textAlign: "center",
    marginBottom: Spacing.sm,
  },
  rashiText: {
    ...Typography.body,
    color: Colors.dark.text,
    textAlign: "center",
  },
});
