import React from "react";
import { createNativeStackNavigator } from "@react-navigation/native-stack";
import { useScreenOptions } from "@/hooks/useScreenOptions";
import WelcomeScreen from "@/screens/onboarding/WelcomeScreen";
import LanguageSelectionScreen from "@/screens/onboarding/LanguageSelectionScreen";
import BirthDetailsScreen from "@/screens/onboarding/BirthDetailsScreen";
import NakshatraMappingScreen from "@/screens/onboarding/NakshatraMappingScreen";
import SubscriptionScreen from "@/screens/onboarding/SubscriptionScreen";

export type OnboardingStackParamList = {
  Welcome: undefined;
  LanguageSelection: undefined;
  BirthDetails: { language: string };
  NakshatraMapping: { name: string; birthDate: string; birthTime: string; birthPlace: string; language: string };
  Subscription: { userId: string };
};

const Stack = createNativeStackNavigator<OnboardingStackParamList>();

export default function OnboardingStackNavigator() {
  const screenOptions = useScreenOptions();

  return (
    <Stack.Navigator screenOptions={{ ...screenOptions, headerShown: false }}>
      <Stack.Screen name="Welcome" component={WelcomeScreen} />
      <Stack.Screen name="LanguageSelection" component={LanguageSelectionScreen} />
      <Stack.Screen name="BirthDetails" component={BirthDetailsScreen} />
      <Stack.Screen name="NakshatraMapping" component={NakshatraMappingScreen} />
      <Stack.Screen name="Subscription" component={SubscriptionScreen} />
    </Stack.Navigator>
  );
}
