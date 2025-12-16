# Bhagya - Daily Astrology & Luck App

## Overview
Bhagya is a daily astrology and luck prediction app designed for tier 2/3/4 cities of Bharat. The app provides personalized daily predictions including lucky color, lucky number, lucky direction, lucky time, and daily mantras based on the user's birth details and nakshatra.

## Tech Stack
- **Frontend**: React Native with Expo SDK 54
- **Backend**: Express.js with TypeScript
- **Database**: PostgreSQL with Drizzle ORM
- **State Management**: TanStack React Query
- **Navigation**: React Navigation 7
- **Styling**: Cosmic/mystical dark theme with iOS liquid glass design influence

## Project Structure
```
client/
├── App.tsx                 # Root app component with providers
├── components/             # Reusable UI components
│   ├── StarField.tsx       # Animated star background
│   ├── LuckyCard.tsx       # Card for lucky predictions
│   └── ...
├── constants/theme.ts      # Design system colors, spacing, typography
├── lib/
│   ├── auth.tsx            # Authentication context and hooks
│   └── query-client.ts     # React Query configuration
├── navigation/             # Navigation configuration
│   ├── RootStackNavigator.tsx
│   ├── MainTabNavigator.tsx
│   ├── OnboardingStackNavigator.tsx
│   └── ...
└── screens/
    ├── onboarding/         # Welcome, LanguageSelection, BirthDetails, NakshatraMapping, Subscription
    ├── HomeScreen.tsx      # Daily luck dashboard
    ├── NakshatraScreen.tsx # Birth chart and nakshatra details
    └── ProfileScreen.tsx   # User settings and subscription

server/
├── index.ts                # Express server entry
├── routes.ts               # API endpoints
├── storage.ts              # Database storage layer
└── db.ts                   # Drizzle database connection

shared/
└── schema.ts               # Drizzle schema (users, dailyPredictions)
```

## Key Features
1. **Onboarding Flow**: Language selection, birth details collection, and animated nakshatra constellation mapping
2. **Daily Predictions**: Lucky color, number, direction, time, and mantra
3. **Nakshatra Chart**: Visual birth chart with detailed nakshatra information
4. **UPI AutoPay Subscription**: Mock integration for recurring payments (Rs. 99/month)
5. **Push Notifications**: Daily luck notifications (settings available)

## API Endpoints
- `POST /api/users` - Create new user with birth details
- `GET /api/users/:id` - Get user details
- `PATCH /api/users/:id` - Update user details
- `GET /api/predictions/:userId?date=YYYY-MM-DD` - Get daily predictions

## Design System
- **Primary**: Deep cosmic purple (#4A148C)
- **Secondary**: Warm saffron (#FF6F00)
- **Accent**: Celestial gold (#FFD700)
- **Background**: Deep navy (#0A0E27)
- Dark theme with animated star backgrounds and glass-effect cards

## Running the App
The app runs on port 5000 (Express server) and port 8081 (Expo Metro bundler).
Users can scan the QR code with Expo Go to test on physical devices.

## User Preferences
- Language: User selects during onboarding (12 Indian languages supported: English, Hindi, Bengali, Telugu, Marathi, Tamil, Gujarati, Kannada, Malayalam, Punjabi, Odia, Assamese)
- Theme: Dark mode only
- Notification time: Default 7:00 AM

## Recent Changes
- December 2024: Added language selection during onboarding with 12 Indian language options
- December 2024: Initial MVP with onboarding, daily predictions, nakshatra chart, and profile screens
