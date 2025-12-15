import React from "react";
import { createNativeStackNavigator } from "@react-navigation/native-stack";
import { useScreenOptions } from "@/hooks/useScreenOptions";
import NakshatraScreen from "@/screens/NakshatraScreen";

export type NakshatraStackParamList = {
  Nakshatra: undefined;
};

const Stack = createNativeStackNavigator<NakshatraStackParamList>();

export default function NakshatraStackNavigator() {
  const screenOptions = useScreenOptions({ transparent: false });

  return (
    <Stack.Navigator screenOptions={screenOptions}>
      <Stack.Screen
        name="Nakshatra"
        component={NakshatraScreen}
        options={{ headerTitle: "Your Nakshatra" }}
      />
    </Stack.Navigator>
  );
}
