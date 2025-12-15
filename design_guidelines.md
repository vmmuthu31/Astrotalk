# Design Guidelines: Daily Astrology & Luck App

## Architecture Decisions

### Authentication
**Auth Required** - Multi-device sync for personalized predictions and subscription management.

**Implementation:**
- SSO with Google Sign-In (primary for tier 2/3/4 city users)
- Apple Sign-In for iOS users
- Mock auth flow simulating account persistence
- Login/signup screens with privacy policy & terms links
- Account deletion nested under Settings > Account > Delete Account with double confirmation

### Navigation
**Tab Navigation (3 tabs):**
- **Home** (Daily Luck Dashboard) - Left tab
- **Nakshatra** (Birth Chart & Predictions) - Center tab
- **Profile** (Settings & Subscription) - Right tab

### Screen Specifications

#### Onboarding Flow (Stack-Only)
1. **Welcome Screen**
   - Purpose: Introduce app value proposition
   - Layout: Full-screen with animated constellation background
   - Components: App logo, tagline in Hindi/English, "Get Started" CTA button
   - Safe area: Top inset = insets.top + Spacing.xl, Bottom inset = insets.bottom + Spacing.xl

2. **Birth Details Form**
   - Purpose: Collect date, time, location of birth
   - Header: Transparent with back button (left)
   - Layout: Scrollable form
   - Components: Date picker, time picker, location autocomplete input
   - Submit button: "Continue" button below form
   - Safe area: Top inset = headerHeight + Spacing.xl, Bottom inset = insets.bottom + Spacing.xl

3. **Nakshatra Mapping Animation**
   - Purpose: Create magical moment showing constellation mapping
   - Layout: Full-screen animated view
   - Components: Animated star field connecting into nakshatra pattern, loading text "Mapping your stars..."
   - Duration: 3-4 seconds before proceeding
   - Safe area: Full screen (no insets needed)

4. **Subscription Screen**
   - Purpose: UPI autopay subscription signup
   - Header: Transparent with skip option (right)
   - Layout: Scrollable content
   - Components: Feature list with checkmarks, pricing card, UPI autopay button (mock), "Start Free Trial" CTA
   - Safe area: Top inset = headerHeight + Spacing.xl, Bottom inset = insets.bottom + Spacing.xl

#### Home Tab
**Daily Luck Dashboard**
- Purpose: Display today's personalized predictions
- Header: Custom transparent header with greeting "Namaste, [Name]" and notification bell icon (right)
- Layout: Scrollable content with cards
- Components:
  - Date display with lunar phase icon
  - Large "Lucky Color" card with color swatch and outfit suggestions
  - "Lucky Number" card with animated number reveal
  - "Lucky Direction" card with compass visual
  - "Lucky Time" card with clock visual
  - "Today's Mantra" card
- Safe area: Top inset = headerHeight + Spacing.xl, Bottom inset = tabBarHeight + Spacing.xl

#### Nakshatra Tab
**Birth Chart & Detailed Predictions**
- Purpose: View natal chart and detailed astrological insights
- Header: Default with title "Your Nakshatra"
- Layout: Scrollable content
- Components:
  - Circular birth chart visualization (static asset or generated)
  - Nakshatra details card
  - Planetary positions list
  - Weekly predictions section
- Safe area: Top inset = Spacing.xl, Bottom inset = tabBarHeight + Spacing.xl

#### Profile Tab
**Settings & Subscription**
- Purpose: Manage account, subscription, and app settings
- Header: Default with title "Profile"
- Layout: Scrollable list
- Components:
  - User avatar (constellation-themed presets) with name
  - Subscription status card with renewal date
  - Settings sections: Notifications, Language (Hindi/English toggle), Theme
  - Birth details (with edit option)
  - Help & Support
  - Log Out button
  - Settings > Account > Delete Account (nested)
- Safe area: Top inset = Spacing.xl, Bottom inset = tabBarHeight + Spacing.xl

#### Modal Screens
**Notification Settings**
- Native modal presentation
- Header: Default with "Cancel" (left) and "Save" (right)
- Layout: Scrollable form
- Components: Time picker for daily notification, notification toggle switches
- Safe area: Top inset = Spacing.xl, Bottom inset = insets.bottom + Spacing.xl

## Design System

### Color Palette
**Primary Theme: Cosmic Mystical**
- Primary: Deep cosmic purple `#4A148C` (for main actions, headers)
- Secondary: Warm saffron `#FF6F00` (for accents, CTAs - culturally relevant)
- Accent: Celestial gold `#FFD700` (for highlights, lucky elements)
- Background: Deep navy `#0A0E27` (night sky)
- Surface: Lighter navy `#1A1F3A` (cards, elevated surfaces)
- Text Primary: Off-white `#F5F5F5`
- Text Secondary: Light gray `#B0B0B0`
- Success: Auspicious green `#4CAF50`
- Warning: Alert orange `#FF9800`

### Typography
- **Headers (Hindi/English)**: System bold, 24-28pt
- **Body**: System regular, 16pt
- **Captions**: System regular, 14pt
- **Card Titles**: System semibold, 18pt
- Language support: Devanagari for Hindi, Latin for English

### Visual Design
- **Icons**: Feather icons from @expo/vector-icons for standard UI, custom constellation icons for astrology features
- **Cards**: Rounded corners (16px radius), subtle gradient overlays on cosmic backgrounds
- **Floating Elements**: Daily luck cards should have subtle drop shadow:
  - shadowOffset: {width: 0, height: 2}
  - shadowOpacity: 0.10
  - shadowRadius: 2
- **Touchable Feedback**: Opacity change to 0.7 on press for all interactive elements
- **Animations**: Gentle fade-ins, constellation star twinkle effects, number reveal animations

### Critical Assets
1. **Constellation Backgrounds** (3-5 variations):
   - Animated star field for onboarding
   - Static constellation patterns for app backgrounds
   - Style: Deep space aesthetic with scattered stars

2. **Nakshatra Mapping Animation**:
   - Connecting dots forming constellation pattern
   - Birth nakshatra highlight effect

3. **User Avatar Presets** (6-8 options):
   - Constellation-themed minimalist icons
   - Each representing different nakshatra symbols
   - Circular format with cosmic glow effect

4. **Lucky Color Swatches**:
   - Vibrant color circles with subtle shine effect
   - Display within color prediction cards

5. **Compass Direction Visual**:
   - Traditional Indian compass rose design
   - Animated pointer for lucky direction

6. **App Logo**:
   - Combines star/constellation with auspicious symbol
   - Works on dark backgrounds

### Accessibility
- Minimum touch target: 44x44pt
- Contrast ratio: 4.5:1 for text on backgrounds
- Support dynamic type sizing
- VoiceOver labels for all interactive elements in both Hindi and English
- Color is not the only indicator (use icons + text)

### Push Notifications
- Daily notification at user-configured time (default 7:00 AM)
- Format: "🌟 Today's Lucky Color: [Color Name]. Your lucky number is [Number]."
- Deep link directly to Home tab