import React, { useEffect, useState } from "react";
import { View, StyleSheet, Dimensions } from "react-native";
import { useNavigation, useRoute, RouteProp } from "@react-navigation/native";
import { NativeStackNavigationProp } from "@react-navigation/native-stack";
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  useAnimatedProps,
  withTiming,
  withDelay,
  withSequence,
  withRepeat,
  withSpring,
  Easing,
} from "react-native-reanimated";
import Svg, { Circle, Line, G, Defs, RadialGradient, Stop } from "react-native-svg";
import { ThemedText } from "@/components/ThemedText";
import { Colors, Spacing, Typography } from "@/constants/theme";
import { OnboardingStackParamList } from "@/navigation/OnboardingStackNavigator";
import { useMutation } from "@tanstack/react-query";
import { apiRequest } from "@/lib/query-client";
import { useAuth } from "@/lib/auth";

const { width, height } = Dimensions.get("window");
const AnimatedCircle = Animated.createAnimatedComponent(Circle);
const AnimatedLine = Animated.createAnimatedComponent(Line);
const AnimatedG = Animated.createAnimatedComponent(G);

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

const ZODIAC_SYMBOLS = ["♈", "♉", "♊", "♋", "♌", "♍", "♎", "♏", "♐", "♑", "♒", "♓"];

function calculateNakshatra(birthDate: string): { nakshatra: string; rashi: string; rashiIndex: number } {
  const date = new Date(birthDate);
  const dayOfYear = Math.floor((date.getTime() - new Date(date.getFullYear(), 0, 0).getTime()) / 86400000);
  const nakshatraIndex = dayOfYear % 27;
  const rashiIndex = Math.floor(nakshatraIndex / 2.25) % 12;
  return {
    nakshatra: NAKSHATRAS[nakshatraIndex],
    rashi: RASHIS[rashiIndex],
    rashiIndex,
  };
}

const centerX = width / 2;
const centerY = height * 0.38;
const outerRadius = Math.min(width, height) * 0.38;
const innerRadius = outerRadius * 0.6;
const coreRadius = outerRadius * 0.25;

function OrbitingStar({ index, orbitProgress }: { index: number; orbitProgress: Animated.SharedValue<number> }) {
  const radius = coreRadius + 30 + index * 18;
  const speed = 1 + index * 0.4;
  const startAngle = index * 45;
  const size = 4 - index * 0.4;

  const animatedProps = useAnimatedProps(() => {
    const angle = ((startAngle + orbitProgress.value * 360 * speed) % 360) * (Math.PI / 180);
    return {
      cx: centerX + Math.cos(angle) * radius,
      cy: centerY + Math.sin(angle) * radius,
    };
  });

  return (
    <AnimatedCircle
      animatedProps={animatedProps}
      r={size}
      fill={Colors.dark.accent}
      opacity={0.8}
    />
  );
}

function ScannerBeam({ rotation }: { rotation: Animated.SharedValue<number> }) {
  const lineProps = useAnimatedProps(() => {
    const angle = rotation.value * (Math.PI / 180);
    return {
      x2: centerX + Math.cos(angle - Math.PI / 2) * outerRadius * 0.9,
      y2: centerY + Math.sin(angle - Math.PI / 2) * outerRadius * 0.9,
    };
  });

  const dotProps = useAnimatedProps(() => {
    const angle = rotation.value * (Math.PI / 180);
    return {
      cx: centerX + Math.cos(angle - Math.PI / 2) * outerRadius * 0.9,
      cy: centerY + Math.sin(angle - Math.PI / 2) * outerRadius * 0.9,
    };
  });

  return (
    <G>
      <AnimatedLine
        x1={centerX}
        y1={centerY}
        animatedProps={lineProps}
        stroke={Colors.dark.accent}
        strokeWidth={2}
        strokeOpacity={0.7}
      />
      <AnimatedCircle
        animatedProps={dotProps}
        r={5}
        fill={Colors.dark.accent}
      />
    </G>
  );
}

function PulsingCore({ glowOpacity, pulseScale }: { glowOpacity: Animated.SharedValue<number>; pulseScale: Animated.SharedValue<number> }) {
  const outerCircleProps = useAnimatedProps(() => ({
    r: coreRadius * pulseScale.value,
    fillOpacity: glowOpacity.value,
  }));

  return (
    <G>
      <AnimatedCircle
        cx={centerX}
        cy={centerY}
        animatedProps={outerCircleProps}
        fill="url(#coreGradient)"
      />
      <Circle
        cx={centerX}
        cy={centerY}
        r={coreRadius * 0.4}
        fill={Colors.dark.accent}
      />
    </G>
  );
}

function AnimatedStar({ point, isHighlighted, opacity }: { point: { x: number; y: number }; isHighlighted: boolean; opacity: Animated.SharedValue<number> }) {
  const animatedProps = useAnimatedProps(() => ({
    opacity: opacity.value * (isHighlighted ? 1 : 0.6),
  }));

  return (
    <AnimatedCircle
      cx={point.x}
      cy={point.y}
      r={isHighlighted ? 6 : 3}
      fill={isHighlighted ? Colors.dark.accent : Colors.dark.text}
      animatedProps={animatedProps}
    />
  );
}

function AnimatedConstellationLine({ from, to, opacity }: { from: { x: number; y: number }; to: { x: number; y: number }; opacity: Animated.SharedValue<number> }) {
  const animatedProps = useAnimatedProps(() => ({
    strokeOpacity: opacity.value * 0.4,
  }));

  return (
    <AnimatedLine
      x1={from.x}
      y1={from.y}
      x2={to.x}
      y2={to.y}
      stroke={Colors.dark.accent}
      strokeWidth={1}
      animatedProps={animatedProps}
    />
  );
}

export default function NakshatraMappingScreen() {
  const navigation = useNavigation<NavigationProp>();
  const route = useRoute<RouteProps>();
  const { name, birthDate, birthTime, birthPlace } = route.params;
  const { setUser } = useAuth();

  const [phase, setPhase] = useState(0);
  const [nakshatra, setNakshatra] = useState("");
  const [rashi, setRashi] = useState("");
  const [rashiIndex, setRashiIndex] = useState(0);

  const scannerRotation = useSharedValue(0);
  const orbitProgress = useSharedValue(0);
  const starsOpacity = useSharedValue(0);
  const linesOpacity = useSharedValue(0);
  const coreGlow = useSharedValue(0.3);
  const corePulse = useSharedValue(1);
  const textOpacity = useSharedValue(0);
  const textScale = useSharedValue(0.8);

  const createUserMutation = useMutation({
    mutationFn: async () => {
      const { nakshatra: n, rashi: r, rashiIndex: ri } = calculateNakshatra(birthDate);
      setNakshatra(n);
      setRashi(r);
      setRashiIndex(ri);
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
      }, 2500);
    },
  });

  useEffect(() => {
    const { nakshatra: n, rashi: r, rashiIndex: ri } = calculateNakshatra(birthDate);
    setNakshatra(n);
    setRashi(r);
    setRashiIndex(ri);

    scannerRotation.value = withRepeat(
      withTiming(360, { duration: 3000, easing: Easing.linear }),
      -1,
      false
    );

    orbitProgress.value = withRepeat(
      withTiming(1, { duration: 8000, easing: Easing.linear }),
      -1,
      false
    );

    starsOpacity.value = withDelay(300, withTiming(1, { duration: 800 }));
    linesOpacity.value = withDelay(1000, withTiming(1, { duration: 1000 }));

    coreGlow.value = withDelay(
      1500,
      withRepeat(
        withSequence(
          withTiming(1, { duration: 1500, easing: Easing.inOut(Easing.ease) }),
          withTiming(0.3, { duration: 1500, easing: Easing.inOut(Easing.ease) })
        ),
        -1,
        true
      )
    );

    corePulse.value = withDelay(
      1500,
      withRepeat(
        withSequence(
          withTiming(1.15, { duration: 1500, easing: Easing.inOut(Easing.ease) }),
          withTiming(1, { duration: 1500, easing: Easing.inOut(Easing.ease) })
        ),
        -1,
        true
      )
    );

    textOpacity.value = withDelay(2800, withTiming(1, { duration: 800 }));
    textScale.value = withDelay(2800, withSpring(1, { damping: 12, stiffness: 100 }));

    setTimeout(() => setPhase(1), 500);
    setTimeout(() => setPhase(2), 1500);
    setTimeout(() => setPhase(3), 2800);

    createUserMutation.mutate();
  }, []);

  const textStyle = useAnimatedStyle(() => ({
    opacity: textOpacity.value,
    transform: [{ scale: textScale.value }],
  }));

  const theme = Colors.dark;

  const zodiacPoints = Array.from({ length: 12 }, (_, i) => {
    const angle = (i * 30 - 90) * (Math.PI / 180);
    return {
      x: centerX + Math.cos(angle) * outerRadius,
      y: centerY + Math.sin(angle) * outerRadius,
      innerX: centerX + Math.cos(angle) * innerRadius,
      innerY: centerY + Math.sin(angle) * innerRadius,
    };
  });

  const nakshatraPoints = Array.from({ length: 27 }, (_, i) => {
    const angle = (i * (360 / 27) - 90) * (Math.PI / 180);
    const radius = innerRadius + (outerRadius - innerRadius) * 0.5;
    return {
      x: centerX + Math.cos(angle) * radius,
      y: centerY + Math.sin(angle) * radius,
    };
  });

  const userNakshatraIndex = new Date(birthDate).getDate() % 27;

  return (
    <View style={[styles.container, { backgroundColor: theme.backgroundRoot }]}>
      <View style={styles.svgContainer}>
        <Svg width={width} height={height * 0.75}>
          <Defs>
            <RadialGradient id="coreGradient" cx="50%" cy="50%" r="50%">
              <Stop offset="0%" stopColor={theme.accent} stopOpacity="1" />
              <Stop offset="50%" stopColor={theme.secondary} stopOpacity="0.6" />
              <Stop offset="100%" stopColor={theme.primary} stopOpacity="0" />
            </RadialGradient>
          </Defs>

          <Circle
            cx={centerX}
            cy={centerY}
            r={outerRadius}
            stroke={theme.primary}
            strokeWidth={1}
            fill="none"
            strokeOpacity={0.3}
          />
          <Circle
            cx={centerX}
            cy={centerY}
            r={innerRadius}
            stroke={theme.secondary}
            strokeWidth={1}
            fill="none"
            strokeOpacity={0.4}
          />
          <Circle
            cx={centerX}
            cy={centerY}
            r={coreRadius}
            stroke={theme.accent}
            strokeWidth={2}
            fill="none"
            strokeOpacity={0.5}
          />

          {zodiacPoints.map((point, i) => (
            <Line
              key={`zodiac-${i}`}
              x1={point.innerX}
              y1={point.innerY}
              x2={point.x}
              y2={point.y}
              stroke={i === rashiIndex ? theme.accent : theme.primary}
              strokeWidth={i === rashiIndex ? 2 : 1}
              strokeOpacity={i === rashiIndex ? 1 : 0.3}
            />
          ))}

          {nakshatraPoints.map((point, i) => (
            <AnimatedStar
              key={`nakshatra-${i}`}
              point={point}
              isHighlighted={i === userNakshatraIndex}
              opacity={starsOpacity}
            />
          ))}

          {nakshatraPoints.slice(0, 9).map((point, i) => {
            const next = nakshatraPoints[(i + 1) % 9];
            return (
              <AnimatedConstellationLine
                key={`line-${i}`}
                from={point}
                to={next}
                opacity={linesOpacity}
              />
            );
          })}

          {[0, 1, 2, 3, 4, 5].map((i) => (
            <OrbitingStar key={`orbit-${i}`} index={i} orbitProgress={orbitProgress} />
          ))}

          <ScannerBeam rotation={scannerRotation} />

          <PulsingCore glowOpacity={coreGlow} pulseScale={corePulse} />
        </Svg>
      </View>

      <View style={styles.textContainer}>
        <ThemedText style={styles.mappingText}>
          {phase < 2 ? "Scanning the cosmos..." : phase < 3 ? "Mapping your nakshatras..." : "Your Celestial Identity"}
        </ThemedText>
        <Animated.View style={textStyle}>
          {phase >= 3 ? (
            <>
              <ThemedText style={styles.nakshatraName}>{nakshatra}</ThemedText>
              <View style={styles.rashiContainer}>
                <ThemedText style={styles.zodiacSymbol}>{ZODIAC_SYMBOLS[rashiIndex]}</ThemedText>
                <ThemedText style={styles.rashiText}>{rashi}</ThemedText>
              </View>
            </>
          ) : null}
        </Animated.View>
      </View>
    </View>
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
    letterSpacing: 1,
  },
  nakshatraName: {
    ...Typography.h2,
    color: Colors.dark.accent,
    textAlign: "center",
    marginBottom: Spacing.md,
    letterSpacing: 2,
  },
  rashiContainer: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "center",
  },
  zodiacSymbol: {
    fontSize: 28,
    color: Colors.dark.secondary,
    marginRight: Spacing.sm,
  },
  rashiText: {
    ...Typography.h4,
    color: Colors.dark.text,
    textAlign: "center",
  },
});
