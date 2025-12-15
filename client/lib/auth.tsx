import React, { createContext, useContext, useState, useEffect, ReactNode } from "react";
import AsyncStorage from "@react-native-async-storage/async-storage";
import type { User } from "@shared/schema";

interface AuthContextType {
  user: User | null;
  isLoading: boolean;
  isOnboarded: boolean;
  setUser: (user: User | null) => void;
  setIsOnboarded: (value: boolean) => void;
  logout: () => Promise<void>;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

const USER_KEY = "@bhagya_user";
const ONBOARDED_KEY = "@bhagya_onboarded";

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUserState] = useState<User | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [isOnboarded, setIsOnboardedState] = useState(false);

  useEffect(() => {
    loadUser();
  }, []);

  const loadUser = async () => {
    try {
      const [userJson, onboarded] = await Promise.all([
        AsyncStorage.getItem(USER_KEY),
        AsyncStorage.getItem(ONBOARDED_KEY),
      ]);
      if (userJson) {
        setUserState(JSON.parse(userJson));
      }
      setIsOnboardedState(onboarded === "true");
    } catch (error) {
      console.error("Error loading user:", error);
    } finally {
      setIsLoading(false);
    }
  };

  const setUser = async (newUser: User | null) => {
    try {
      if (newUser) {
        await AsyncStorage.setItem(USER_KEY, JSON.stringify(newUser));
      } else {
        await AsyncStorage.removeItem(USER_KEY);
      }
      setUserState(newUser);
    } catch (error) {
      console.error("Error saving user:", error);
    }
  };

  const setIsOnboarded = async (value: boolean) => {
    try {
      await AsyncStorage.setItem(ONBOARDED_KEY, value.toString());
      setIsOnboardedState(value);
    } catch (error) {
      console.error("Error saving onboarded state:", error);
    }
  };

  const logout = async () => {
    try {
      await AsyncStorage.multiRemove([USER_KEY, ONBOARDED_KEY]);
      setUserState(null);
      setIsOnboardedState(false);
    } catch (error) {
      console.error("Error logging out:", error);
    }
  };

  return (
    <AuthContext.Provider
      value={{
        user,
        isLoading,
        isOnboarded,
        setUser,
        setIsOnboarded,
        logout,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error("useAuth must be used within an AuthProvider");
  }
  return context;
}
