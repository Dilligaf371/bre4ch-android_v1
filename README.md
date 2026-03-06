# BRE4CH Android v1

**Battlefield Real-time Event Assessment & Crisis Hub**

Operation: Roar of the Lion | Android Edition

## Overview

BRE4CH is a mobile operational intelligence dashboard for real-time crisis monitoring in the Middle East. This repository contains the Android-specific build of the Flutter application.

## Modules

| Tab | Route | Function |
|-----|-------|----------|
| BRIEF | /delta-s | Real-time stats, event feed, priority alerts |
| TRUST | /crisis-filter | Threat filtering, source credibility, regional analysis |
| EVAC | /evac | Shelters, hospitals, embassies, airports on GPS map |
| CONFLICT | /war-state | NATO APP-6 force disposition map |
| SETTINGS | /settings | Sources, push notifications, offline maps |

## Tech Stack

- **Framework**: Flutter 3.41 / Dart 3.11
- **State**: Riverpod 2.6.1
- **Routing**: GoRouter 14.8.1
- **HTTP**: Dio + Cache Interceptor (Hive)
- **Maps**: Flutter Map + CartoDB Dark Tiles
- **GPS**: Geolocator + Compass
- **Push**: Firebase Cloud Messaging
- **Backend**: Express.js on Hetzner VPS (api.bre4ch.com)

## Build

```bash
# Get dependencies
flutter pub get

# Build release APK
flutter build apk --release

# Build App Bundle (for Play Store)
flutter build appbundle --release
```

## Setup

1. Place `google-services.json` in `android/app/`
2. Create `android/key.properties` with signing config
3. Create `android/local.properties` with SDK paths

## Architecture

```
Backend (Hetzner) -> Dio+Cache -> Services -> Notifiers -> Providers -> UI
```

31 OSINT sources | 310+ POIs | 15 Riverpod providers | 14 screens
