# BRE4CH — Architecture Technique & Fonctionnelle

**Version :** 1.6 | **Mars 2026**
**Nom de code :** Operation Roar of the Lion
**Codebase :** ~21 500 lignes Dart | 76 fichiers
**Plateformes :** iOS (TestFlight) + Android

---

## 1. Vue d'ensemble

**BRE4CH** (Battlefield Real-time Event Assessment & Crisis Hub) est un tableau de bord mobile de renseignement opérationnel conçu pour le monitoring en temps réel de crises au Moyen-Orient. L'application agrège 31 sources d'information, les classifie automatiquement et fournit une interface tactique pour la prise de décision en situation de crise.

---

## 2. Architecture Fonctionnelle

### 2.1 Les 5 modules principaux

L'application est organisée en **5 onglets** via une barre de navigation inférieure :

| Tab | Route | Fonction |
|-----|-------|----------|
| **BRIEF** | `/delta-s` | Dashboard de synthèse — stats temps réel, fil d'événements, alertes prioritaires, sparklines |
| **TRUST** | `/crisis-filter` | Filtrage des menaces — évaluation multi-niveaux, scoring crédibilité sources, analyse régionale |
| **EVAC** | `/evac` | Évacuation — abris, hôpitaux, ambassades, aéroports sur carte avec navigation GPS |
| **CONFLICT** | `/war-state` | Carte de combat — disposition des forces NATO APP-6, symbologie couleur/forme |
| **SETTINGS** | `/settings` | Configuration — sources, notifications push, cartes offline, roadmap |

### 2.2 Fonctionnalités clés

#### Intelligence en temps réel
- Agrégation de **31 sources OSINT** (journaux GCC, agences de presse, wire services)
- Classification automatique par mots-clés : type d'attaque, statut, priorité
- Déduplication des événements par hash de titre
- Fil d'événements limité à 50 items avec rotation FIFO

#### Alertes d'urgence
- Détection automatique par 3 niveaux de mots-clés (extreme / severe / moderate)
- TTL par niveau : 2 min (extreme), 1.5 min (severe), 1 min (moderate)
- Autorités supportées : NCEMA, MOI, MOD, CENTCOM, IDF, Coalition
- Support bilingue anglais / arabe

#### Cartographie & Navigation
- Carte interactive Flutter Map (OpenStreetMap / CartoDB dark tiles)
- Cache de tuiles persistant (Hive) avec téléchargement par région
- Navigation GPS temps réel avec boussole et bearing
- Calcul de distance Haversine + ETA piéton/véhicule

#### Données statiques embarquées
- **131 hôpitaux** avec services d'urgence et capacités
- **100+ abris civils** répartis sur 8 pays
- **50+ ambassades** avec contacts d'urgence
- **30+ aéroports** avec codes ICAO/IATA et liens NOTAM

#### Notifications push
- Firebase Cloud Messaging (FCM)
- Abonnement par topics : pays, ville, type d'attaque, sévérité
- Format topic : `breach_{dimension}_{value}`
- Persistance via SharedPreferences

---

## 3. Architecture Technique

### 3.1 Stack technologique

| Couche | Technologie | Version |
|--------|-------------|---------|
| Framework | Flutter | 3.41 / Dart 3.11 |
| State Management | Riverpod | 2.6.1 |
| Routing | GoRouter | 14.8.1 |
| HTTP Client | Dio | 5.8.0 |
| Cache HTTP | DioCacheInterceptor + Hive | 3.5.0 / 3.2.1 |
| Cartes | Flutter Map + latlong2 | 7.0.2 / 0.9.1 |
| GPS | Geolocator | 13.0.2 |
| Boussole | flutter_compass | 0.8.1 |
| Charts | fl_chart | 0.70.2 |
| Animations | flutter_animate | 4.5.2 |
| Notifications | Firebase Messaging | 15.2.4 |
| Polices | Google Fonts (JetBrains Mono, Inter) | 6.2.1 |
| Persistance locale | SharedPreferences + path_provider | 2.5.3 / 2.1.5 |
| Backend | Express.js / Node 20 | — |
| Hébergement | Hetzner VPS | — |
| Process Manager | PM2 | — |
| CI/CD | GitHub Actions | — |

### 3.2 Structure du projet

```
lib/
├── main.dart                    # Point d'entrée (Firebase, cache, FCM)
├── app.dart                     # Configuration GoRouter + shell 5 tabs
├── config/                      # Configuration (3 fichiers)
│   ├── api.dart                 # Endpoints, intervalles, TTL
│   ├── constants.dart           # Phases opération, niveaux menace
│   └── theme.dart               # Palette Palantir, styles texte, NATO APP-6
├── models/                      # Modèles de données (10 fichiers, ~1 380 lignes)
│   ├── attack_event.dart        # AttackType, EventStatus enums
│   ├── attack_stats.dart        # Stats + history + country feeds
│   ├── attack_corridor.dart     # Trajectoires d'attaque (Norse-style)
│   ├── emergency_alert.dart     # Niveaux d'alerte, autorités
│   ├── centcom_briefing.dart    # Parsing RFC 2822, classification priorité
│   ├── infrastructure.dart      # Types infra, niveaux défense
│   ├── military_position.dart   # Symbologie NATO APP-6
│   ├── osint_item.dart          # 30 sources OSINT
│   ├── socmint_item.dart        # Plateformes social media
│   └── shelter.dart             # 8 pays, 5 types d'abris
├── providers/                   # State management Riverpod (15 fichiers, ~2 520 lignes)
│   ├── auth_provider.dart       # Authentification simple
│   ├── event_feed_provider.dart # Headlines + LiveUAMap, max 50 events
│   ├── realtime_stats_provider.dart  # Baseline + delta live
│   ├── emergency_alerts_provider.dart # Détection multi-niveaux
│   ├── osint_provider.dart      # Fil OSINT 30+ sources
│   ├── socmint_provider.dart    # Monitoring Telegram, X, Snapchat
│   ├── centcom_provider.dart    # Briefings CENTCOM
│   ├── liveuamap_provider.dart  # Événements LiveUAMap
│   ├── attack_flow_provider.dart # Corridors d'attaque visuels
│   ├── airport_provider.dart    # Statut aéroports + NOTAM
│   ├── offline_map_provider.dart # État cache tuiles
│   ├── connectivity_provider.dart # Détection réseau
│   ├── mission_clock_provider.dart # Horloge mission
│   ├── notification_preferences_provider.dart # Abonnements FCM
│   └── source_refresh_provider.dart # Coordination polling
├── screens/                     # Écrans UI (14 fichiers, ~10 600 lignes)
│   ├── splash_screen.dart       # Logo fade-in (4s)
│   ├── login_screen.dart        # Gate authentification
│   ├── delta_s_screen.dart      # Tab BRIEF (1 015 lignes)
│   ├── crisis_filter_screen.dart # Tab TRUST (1 375 lignes)
│   ├── evac_screen.dart         # Tab EVAC (2 720 lignes) — plus gros écran
│   ├── war_state_screen.dart    # Tab CONFLICT (1 169 lignes)
│   ├── roadmap_screen.dart      # Tab SETTINGS (415 lignes)
│   ├── notification_settings_screen.dart # Abonnements push
│   ├── offline_maps_screen.dart # Gestion cache cartes
│   ├── alerts_screen.dart       # Liste alertes d'urgence
│   ├── civil_safety_screen.dart # Infrastructures civiles
│   ├── airports_screen.dart     # Annuaire aéroports
│   ├── embassies_screen.dart    # Annuaire consulaire
│   └── live_nav_screen.dart     # Navigation GPS temps réel
├── services/                    # Services API & métier (11 fichiers, ~980 lignes)
│   ├── api_service.dart         # Singleton Dio + cache (50 entrées, 7j stale)
│   ├── push_notification_service.dart # Singleton FCM
│   ├── headlines_service.dart   # API headlines
│   ├── centcom_service.dart     # API CENTCOM
│   ├── liveuamap_service.dart   # API LiveUAMap
│   ├── stats_service.dart       # Baseline stats + fallback
│   ├── forces_service.dart      # Positions militaires
│   ├── cyber_service.dart       # Threat actors
│   ├── sources_service.dart     # Santé des sources
│   ├── offline_map_service.dart # Téléchargement tuiles
│   └── cached_tile_provider.dart # Init provider tuiles
├── data/                        # Bases de données statiques (10 fichiers, ~2 100 lignes)
│   ├── airports.dart            # 30+ aéroports régionaux
│   ├── embassies.dart           # 50+ ambassades
│   ├── shelters.dart            # 100+ abris civils
│   ├── hospitals.dart           # 131 hôpitaux
│   ├── attack_corridors.dart    # Trajectoires d'attaque
│   ├── axis_feeds.dart          # Sources axe
│   ├── coalition_feeds.dart     # Sources coalition
│   ├── cyber_ops.dart           # Opérations cyber
│   ├── map_regions.dart         # Régions géographiques
│   └── mock_data.dart           # Données de test
├── widgets/common/              # Composants réutilisables (13 fichiers, ~2 550 lignes)
│   ├── header_bar.dart          # Navigation supérieure + drawer
│   ├── alert_drawer.dart        # Menu hamburger
│   ├── alert_banner.dart        # Bannière d'alerte
│   ├── compass_nav_sheet.dart   # Overlay navigation boussole
│   ├── mission_clock_widget.dart # Timer mission
│   ├── palantir_card.dart       # Container carte stylisé
│   ├── palantir_text.dart       # Styles texte custom
│   ├── severity_badge.dart      # Badge sévérité
│   ├── priority_badge.dart      # Badge priorité
│   ├── status_badge.dart        # Badge statut
│   ├── pulsing_dot.dart         # Animation pulse
│   ├── filter_chip_row.dart     # Chips multi-select
│   └── collapsible_section.dart # Section dépliable
└── utils/                       # Utilitaires (4 fichiers, ~200 lignes)
    ├── formatters.dart          # Formatage timestamp, nombres, durée
    ├── geo_utils.dart           # Haversine, bearing, ETA
    ├── bezier.dart              # Courbes bézier (animation attaques)
    └── conflict_keywords.dart   # Listes mots-clés menace
```

### 3.3 Pattern architectural — Flux de données

```
Backend Express.js (Hetzner)
        ↓ HTTP (Dio + Cache)
Services (HeadlinesService, CentcomService, etc.)
        ↓ Données brutes
Notifiers (EventFeedNotifier, AlertNotifier, etc.)
        ↓ État transformé
Providers Riverpod (StateNotifierProvider)
        ↓ ref.watch()
Screens & Widgets (ConsumerWidget)
        ↓ Render
UI Flutter (animations, charts, cartes)
```

### 3.4 StateNotifier Pattern (Riverpod)

Chaque feature utilise un `StateNotifier<T>` avec :
- État immutable (data class)
- Logique métier encapsulée dans le notifier
- Timers de polling intégrés (30s à 90s selon la source)
- Cleanup automatique via `dispose()`

---

## 4. Modèles de données (10 fichiers)

### 4.1 Modèles d'attaque

| Modèle | Champs clés | Enums |
|--------|-------------|-------|
| `AttackEvent` | id, type, status, lat/lng, timestamp | AttackType (ballistic, drone, cyber, artillery, cruise, sabotage), EventStatus (intercepted, impact, ongoing, neutralized) |
| `AttackStats` | total, par type, 24h, sorties | — |
| `AttackCorridor` | source → target, type, path | Trajectoire source/cible |

### 4.2 Modèles de renseignement

| Modèle | Champs clés | Enums |
|--------|-------------|-------|
| `OsintItem` | source, title, summary, priority, region, url | OsintSource (30 valeurs), OsintPriority (flash/immediate/priority/routine) |
| `SocmintItem` | platform, content, severity, location | SocmintPlatform (Telegram, Snapchat, X), SocmintSeverity |
| `CentcomBriefing` | title, content, category, priority, date | CentcomCategory, CentcomPriority |

### 4.3 Modèles opérationnels

| Modèle | Champs clés | Enums |
|--------|-------------|-------|
| `MilitaryPosition` | name, force, unit, lat/lng, strength, readiness | ForceType (allied/hostile/neutral/unknown) |
| `Infrastructure` | name, type, status, defenseLevel, lat/lng | InfraType (9 types), InfraStatus |
| `EmergencyAlert` | title, level, authority, bilingue, expiry | AlertLevel (3 niveaux), AlertAuthority (6 autorités) |
| `Shelter` | name, country, type, status, capacity, lat/lng | ShelterCountry (8 pays), ShelterType (5 types) |

---

## 5. Providers Riverpod (15 providers)

| Provider | Polling | Rôle |
|----------|---------|------|
| `authProvider` | — | Authentification simple (admin/admin) |
| `eventFeedProvider` | 30s | Agrégation headlines + LiveUAMap, max 50 events |
| `realtimeStatsProvider` | 4s | Stats combinées baseline + delta live |
| `emergencyAlertsProvider` | via feed | Détection alertes par mots-clés multi-niveaux |
| `osintProvider` | 30s | Fil OSINT 31 sources avec classification |
| `socmintProvider` | 30s | Monitoring Telegram, X, Snapchat |
| `centcomProvider` | 60s | Briefings CENTCOM (press releases, statements) |
| `liveuamapProvider` | 90s | Événements LiveUAMap géolocalisés |
| `attackFlowProvider` | — | Corridors d'attaque visuels (Norse-style) |
| `airportProvider` | 90s | Statut opérationnel aéroports + NOTAM |
| `offlineMapProvider` | — | État cache tuiles carte offline |
| `connectivityProvider` | — | Détection réseau (online/offline) |
| `missionClockProvider` | 1s | Horloge mission depuis 28 fév 2026 02:00 UTC |
| `notificationPreferencesProvider` | — | Abonnements FCM par pays/ville/type/sévérité |
| `sourceRefreshProvider` | — | Coordination des cycles de polling |

---

## 6. Services (11 services)

| Service | Lignes | Rôle |
|---------|--------|------|
| `ApiService` | 122 | Singleton Dio avec cache interceptor (50 entrées, 7j stale) |
| `PushNotificationService` | 210 | Singleton FCM — token, topics, background handler |
| `HeadlinesService` | 37 | Wrapper API headlines |
| `CentcomService` | 38 | Wrapper API CENTCOM briefings |
| `LiveuamapService` | 34 | Wrapper API LiveUAMap events |
| `StatsService` | 28 | Baseline stats avec fallback hardcodé |
| `ForcesService` | 54 | Positions militaires (axis + coalition) |
| `CyberService` | 52 | Renseignement cyber (threat actors) |
| `SourcesService` | 38 | Santé des sources (status, event counts) |
| `OfflineMapService` | 208 | Téléchargement et cache tuiles carte |
| `CachedTileProvider` | 38 | Initialisation provider tuiles persistant |

---

## 7. Backend (Express.js / Hetzner)

### 7.1 Infrastructure

| Composant | Détail |
|-----------|--------|
| Serveur | Hetzner VPS |
| Runtime | Node.js 20 |
| Framework | Express.js |
| Process Manager | PM2 (`bre4ch-api`) |
| Port | 3002 |
| Domaine | api.bre4ch.com |
| Code source | `/opt/bre4ch/backend/src/` |

### 7.2 Architecture modulaire

```
/opt/bre4ch/backend/src/
├── server.mjs           # Point d'entrée Express
├── routes/
│   ├── sources.mjs      # RSS aggregator (31 sources)
│   ├── alerts.mjs       # Alertes
│   ├── forces.mjs       # Positions militaires
│   ├── centcom.mjs      # CENTCOM briefings
│   ├── cyber.mjs        # Cyber intel
│   ├── liveuamap.mjs    # LiveUAMap proxy
│   ├── notifications.mjs # FCM management
│   └── stats.mjs        # Stats baseline
```

### 7.3 Endpoints API

| Endpoint | Méthode | Poll | Cache TTL | Rôle |
|----------|---------|------|-----------|------|
| `/api/sources/headlines` | GET | 30s | 5m | Headlines agrégés (~280 articles) |
| `/api/sources/status` | GET | 60s | 1m | Santé des 31 sources |
| `/api/sources/refresh` | POST | — | — | Forcer un refresh RSS |
| `/api/liveuamap` | GET | 90s | 5m | Événements LiveUAMap |
| `/api/centcom/briefings` | GET | 60s | 10m | Briefings CENTCOM |
| `/api/forces/axis` | GET | — | 15m | Positions forces axe |
| `/api/forces/coalition` | GET | — | 15m | Positions forces coalition |
| `/api/cyber` | GET | — | 10m | Menaces cyber |
| `/api/stats/baseline` | GET | — | 5m | Stats baseline |
| `/api/airports/status` | GET | 90s | 5m | Statut aéroports |
| `/api/notifications/register` | POST | — | — | Enregistrement token FCM |
| `/api/health` | GET | — | — | Health check |

### 7.4 Pipeline RSS (31 sources)

**Stratégie d'agrégation :**
- **RSS direct** : quand le site expose un flux RSS fonctionnel
- **Google News proxy** : `news.google.com/rss/search?q=site:DOMAIN` comme fallback
- **Refresh** : toutes les 5 minutes
- **Résultat** : ~280 headlines par cycle

**Sources par catégorie :**

| Catégorie | Sources | Méthode |
|-----------|---------|---------|
| Journaux GCC — UAE | Khaleej Times, Gulf News, The National, Gulf Today, Emirates 24\|7 | RSS direct / Google News |
| Journaux GCC — Saudi | Arab News, Saudi Gazette | Google News |
| Journaux GCC — Qatar | Gulf Times, The Peninsula Qatar, Qatar Tribune | Google News |
| Journaux GCC — Bahrain | Gulf Daily News, Daily Tribune Bahrain | Google News |
| Journaux GCC — Oman | Times of Oman, Oman Observer | Google News |
| Wire services | Reuters, AP, Al Jazeera, BBC, Bloomberg | RSS direct |
| Militaire | CENTCOM, DoD.gov | RSS direct |
| Agences GCC | WAM, SPA, QNA, BNA, KUNA, ONA | Google News |
| Israël | Times of Israel, Jerusalem Post | RSS direct |
| Conflict tracking | LiveUAMap API | API REST |

---

## 8. Stratégie de cache

### 8.1 Cache HTTP (Dio)
- Mémoire : 50 entrées max
- Stale-While-Revalidate : 7 jours
- Politique : `refreshForceCache` (réseau d'abord, fallback cache)
- TTL par endpoint : 1 min à 15 min

### 8.2 Cache tuiles carte (Hive)
- Stockage persistant sur disque (path_provider)
- Téléchargement par région (bounding box)
- Provider : CartoDB Dark All (`{s}.basemaps.cartocdn.com/dark_all`)
- Zoom levels : 5 à 13
- Stale max : 365 jours

### 8.3 Persistance locale
- SharedPreferences : abonnements FCM, préférences utilisateur
- path_provider : cache tuiles, données offline

---

## 9. Intégrations OSINT & SOCMINT

### 9.1 Comptes X/Twitter monitorés

| Compte | Spécialité |
|--------|------------|
| @Conflicts | Conflits globaux |
| @IntelCrab | Renseignement OSINT |
| @sentdefender | Défense & sécurité |
| @OSINTdefender | OSINT défense |
| @ELINTNews | Renseignement électronique |
| @GeoConfirmed | Géolocalisation OSINT |
| @AuroraIntel | Intel aviation & maritime |
| @FaytuksNetwork | Réseau Moyen-Orient |
| @criticalthreats | Analyse menaces |
| @RALee85 | Analyse militaire |

### 9.2 Canaux Telegram

| Canal | Contenu |
|-------|---------|
| OSINTdefender | Flux OSINT temps réel |
| Abu Ali Express | Renseignement terrain |
| Rybar (English) | Analyse militaire |

---

## 10. Design System — Palette Palantir

### 10.1 Couleurs principales

| Variable | Hex | Usage |
|----------|-----|-------|
| `bg` | #060A10 | Fond principal |
| `surface` | #0B1018 | Cartes, surfaces |
| `accent` | #F59E0B | Accent (ambre) |
| `text` | #E6EDF3 | Texte principal |
| `textMuted` | #6E7681 | Texte secondaire |
| `border` | #1A2030 | Bordures |
| `success` | #22C55E | Statut OK / en ligne |
| `danger` | #EF4444 | Critique / hostile |
| `cyan` | #06B6D4 | Accents secondaires |

### 10.2 Symbologie NATO APP-6

| Affiliation | Couleur | Forme | Hex |
|-------------|---------|-------|-----|
| Friendly | Bleu | Rectangle | #3B82F6 |
| Hostile | Rouge | Losange | #EF4444 |
| Neutral | Vert | Carré | #22C55E |
| Unknown | Jaune | Trèfle | #EAB308 |

### 10.3 Typographie

| Police | Usage |
|--------|-------|
| **JetBrains Mono** | Données, labels, badges, stats, code |
| **Inter** | Corps de texte, descriptions, paragraphes |

---

## 11. Diagramme de déploiement

```
┌─────────────────────┐     ┌──────────────────────────┐
│   App Flutter iOS    │────▶│  api.bre4ch.com (HTTPS)  │
│   (TestFlight)       │     │  Hetzner VPS             │
│                      │     │  Port 3002               │
│  ┌────────────────┐  │     │                          │
│  │ Dio + Cache    │──┼────▶│  Express.js + PM2        │
│  │ FCM Client     │──┼──┐  │  ├── sources.mjs (RSS)   │
│  │ Flutter Map    │  │  │  │  ├── centcom.mjs         │
│  │ Geolocator     │  │  │  │  ├── forces.mjs          │
│  │ SharedPrefs    │  │  │  │  ├── cyber.mjs           │
│  └────────────────┘  │  │  │  ├── liveuamap.mjs       │
└─────────────────────┘  │  └── notifications.mjs   │
                          │  └──────────────────────────┘
                          │
                          ▼
                ┌──────────────────┐
                │ Firebase Cloud   │
                │ Messaging (FCM)  │
                │ Topics:          │
                │ breach_country_* │
                │ breach_city_*    │
                │ breach_type_*    │
                │ breach_severity_*│
                └──────────────────┘
```

---

## 12. Métriques du projet

| Métrique | Valeur |
|----------|--------|
| Fichiers Dart | 76 |
| Lignes de code | ~21 535 |
| Modèles | 10 |
| Providers Riverpod | 15 |
| Écrans | 14 |
| Services | 11 |
| Widgets réutilisables | 13 |
| Sources OSINT intégrées | 31 |
| Points d'intérêt embarqués | 310+ |
| Endpoints API | 12 |
| Plus gros écran | evac_screen.dart (2 720 lignes) |

---

## 13. Roadmap

| Version | Description | Statut |
|---------|-------------|--------|
| Alpha | Tests internes | ✅ Complété |
| Beta | TestFlight / Internal Track | 🔄 En cours |
| v1.0 | App Store + Google Play | ⏳ Prévu |
| v1.1 | Push notifications + alertes | 🔄 En cours |
| v1.2 | Écran EVAC unifié | ✅ Complété |
| v1.3 | Offline mode + caching | 🔄 En cours |
| v1.4 | Intégration agent IA | ⏳ Prévu |
| v1.5 | Overlays carte temps réel | ⏳ Prévu |
