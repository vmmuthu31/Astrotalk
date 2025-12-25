#!/bin/bash
# Build script with Razorpay keys from .env file

# Load from .env file
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
fi

# Check if keys are set
if [ -z "$RAZORPAY_KEY_ID" ] || [ -z "$RAZORPAY_KEY_SECRET" ]; then
  echo "Error: RAZORPAY_KEY_ID and RAZORPAY_KEY_SECRET must be set"
  echo "Create a .env file with your keys (copy from .env.example)"
  exit 1
fi

# Build command
flutter build apk --release \
  --dart-define=RAZORPAY_KEY_ID="$RAZORPAY_KEY_ID" \
  --dart-define=RAZORPAY_KEY_SECRET="$RAZORPAY_KEY_SECRET"

echo ""
echo "✅ APK built at: build/app/outputs/flutter-apk/app-release.apk"
