#!/bin/bash
# ── BRE4CH Secure Build Script ────────────────────────────────────
# SECURITY FIX: HIGH-03 — Dart obfuscation + split debug info.
# SECURITY FIX: CRIT-03 — Google Maps API key via --dart-define.
#
# Usage:
#   GOOGLE_MAPS_API_KEY=<key> ./build_secure.sh [android|ios]
#
# Requirements:
#   - GOOGLE_MAPS_API_KEY env var must be set
#   - Flutter SDK in PATH
# ──────────────────────────────────────────────────────────────────

set -euo pipefail

PLATFORM="${1:-android}"
BUILD_DIR="build/debug-info"

# Validate required env vars
if [ -z "${GOOGLE_MAPS_API_KEY:-}" ]; then
  echo "ERROR: GOOGLE_MAPS_API_KEY environment variable is required."
  echo "  export GOOGLE_MAPS_API_KEY=<your-key>"
  exit 1
fi

# Create debug info directory
mkdir -p "$BUILD_DIR"

echo "Building BRE4CH ($PLATFORM) with security hardening..."
echo "  - Obfuscation: ENABLED"
echo "  - Split debug info: $BUILD_DIR"
echo "  - API key: via --dart-define (not in source)"

COMMON_ARGS=(
  --release
  --obfuscate                                   # HIGH-03: Obfuscate Dart code
  --split-debug-info="$BUILD_DIR"               # HIGH-03: Split debug symbols
  --dart-define="GOOGLE_MAPS_API_KEY=$GOOGLE_MAPS_API_KEY"  # CRIT-03: Inject API key
)

if [ "$PLATFORM" = "android" ]; then
  flutter build appbundle "${COMMON_ARGS[@]}"
  echo "Android App Bundle built successfully."
  echo "  Output: build/app/outputs/bundle/release/app-release.aab"
elif [ "$PLATFORM" = "ios" ]; then
  flutter build ios "${COMMON_ARGS[@]}"
  echo "iOS build completed successfully."
else
  echo "Unknown platform: $PLATFORM (use 'android' or 'ios')"
  exit 1
fi

echo ""
echo "Debug symbols stored in: $BUILD_DIR"
echo "  Keep these for crash symbolication. Do NOT distribute."
