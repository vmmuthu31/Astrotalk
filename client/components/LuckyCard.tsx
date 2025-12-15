import React, { useEffect } from "react";
import { View, StyleSheet, Pressable } from "react-native";
import { Feather } from "@expo/vector-icons";
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withTiming,
  withDelay,
  withRepeat,
  withSequence,
  Easing,
  interpolate,
} from "react-native-reanimated";
import { ThemedText } from "@/components/ThemedText";
import { Colors, Spacing, BorderRadius, Shadows, Typography } from "@/constants/theme";

const AnimatedPressable = Animated.createAnimatedComponent(Pressable);

interface LuckyCardProps {
  title: string;
  value: string;
  icon: keyof typeof Feather.glyphMap;
  color?: string;
  colorHex?: string;
  onPress?: () => void;
  index?: number;
  animateShimmer?: boolean;
}

export default function LuckyCard({ 
  title, 
  value, 
  icon, 
  color, 
  colorHex, 
  onPress,
  index = 0,
  animateShimmer = true,
}: LuckyCardProps) {
  const theme = Colors.dark;
  
  const translateY = useSharedValue(30);
  const opacity = useSharedValue(0);
  const scale = useSharedValue(0.95);
  const shimmerPosition = useSharedValue(-1);
  const glowOpacity = useSharedValue(0.3);
  const iconRotate = useSharedValue(0);

  useEffect(() => {
    const delay = index * 150;
    
    translateY.value = withDelay(delay, withTiming(0, { duration: 500, easing: Easing.out(Easing.back(1.5)) }));
    opacity.value = withDelay(delay, withTiming(1, { duration: 400 }));
    scale.value = withDelay(delay, withTiming(1, { duration: 500, easing: Easing.out(Easing.back(1.2)) }));
    
    if (animateShimmer) {
      shimmerPosition.value = withDelay(
        delay + 500,
        withRepeat(
          withSequence(
            withTiming(2, { duration: 2000, easing: Easing.inOut(Easing.ease) }),
            withTiming(-1, { duration: 0 })
          ),
          -1,
          false
        )
      );
    }

    glowOpacity.value = withDelay(
      delay + 300,
      withRepeat(
        withSequence(
          withTiming(0.6, { duration: 2000, easing: Easing.inOut(Easing.ease) }),
          withTiming(0.3, { duration: 2000, easing: Easing.inOut(Easing.ease) })
        ),
        -1,
        true
      )
    );

    iconRotate.value = withDelay(
      delay + 200,
      withSequence(
        withTiming(10, { duration: 200 }),
        withTiming(-10, { duration: 200 }),
        withTiming(0, { duration: 200 })
      )
    );
  }, []);

  const cardStyle = useAnimatedStyle(() => ({
    transform: [
      { translateY: translateY.value },
      { scale: scale.value },
    ],
    opacity: opacity.value,
  }));

  const shimmerStyle = useAnimatedStyle(() => ({
    transform: [{ translateX: interpolate(shimmerPosition.value, [-1, 2], [-200, 400]) }],
    opacity: interpolate(shimmerPosition.value, [-1, 0, 1, 2], [0, 0.3, 0.3, 0]),
  }));

  const glowStyle = useAnimatedStyle(() => ({
    opacity: glowOpacity.value,
  }));

  const iconStyle = useAnimatedStyle(() => ({
    transform: [{ rotate: `${iconRotate.value}deg` }],
  }));

  return (
    <AnimatedPressable
      onPress={onPress}
      style={[
        styles.card,
        { backgroundColor: theme.cardBackground },
        cardStyle,
      ]}
    >
      <Animated.View style={[styles.shimmerOverlay, shimmerStyle]} />
      
      <Animated.View style={[styles.glowBorder, glowStyle]} />
      
      <View style={styles.iconContainer}>
        <View style={[styles.iconCircle, { backgroundColor: theme.primary }]}>
          <Animated.View style={iconStyle}>
            <Feather name={icon} size={24} color={theme.accent} />
          </Animated.View>
        </View>
      </View>
      <View style={styles.content}>
        <ThemedText style={styles.title}>{title}</ThemedText>
        <View style={styles.valueRow}>
          {colorHex ? (
            <Animated.View style={[styles.colorSwatch, { backgroundColor: colorHex }, glowStyle]} />
          ) : null}
          <ThemedText style={[styles.value, color ? { color } : null]}>{value}</ThemedText>
        </View>
      </View>
      <View style={styles.chevronContainer}>
        <Feather name="chevron-right" size={20} color={theme.textSecondary} />
      </View>
    </AnimatedPressable>
  );
}

const styles = StyleSheet.create({
  card: {
    flexDirection: "row",
    alignItems: "center",
    padding: Spacing.lg,
    borderRadius: BorderRadius.md,
    marginBottom: Spacing.md,
    overflow: "hidden",
    borderWidth: 1,
    borderColor: "rgba(255, 215, 0, 0.1)",
  },
  shimmerOverlay: {
    position: "absolute",
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    width: 100,
    backgroundColor: "rgba(255, 215, 0, 0.15)",
    transform: [{ skewX: "-20deg" }],
  },
  glowBorder: {
    position: "absolute",
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    borderRadius: BorderRadius.md,
    borderWidth: 1,
    borderColor: Colors.dark.accent,
  },
  iconContainer: {
    marginRight: Spacing.lg,
  },
  iconCircle: {
    width: 48,
    height: 48,
    borderRadius: 24,
    justifyContent: "center",
    alignItems: "center",
  },
  content: {
    flex: 1,
  },
  title: {
    ...Typography.small,
    color: Colors.dark.textSecondary,
    marginBottom: Spacing.xs,
  },
  valueRow: {
    flexDirection: "row",
    alignItems: "center",
  },
  colorSwatch: {
    width: 20,
    height: 20,
    borderRadius: 10,
    marginRight: Spacing.sm,
    borderWidth: 2,
    borderColor: "rgba(255,255,255,0.3)",
  },
  value: {
    ...Typography.cardTitle,
    color: Colors.dark.text,
  },
  chevronContainer: {
    marginLeft: Spacing.sm,
  },
});
