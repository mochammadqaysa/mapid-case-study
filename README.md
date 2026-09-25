# MAPID Mobile GIS Application

Enterprise-grade mobile Geographic Information System (GIS) client built with Flutter, rendering OpenFreeMap Liberty vector tiles, remote GeoJSON layer ingestion from GEO MAPID, interactive feature attributes inspection, and on-demand GPS location tracking.

---

## 🏗️ Architecture Overview

The project is structured according to **Feature-First Clean Architecture**:

- `lib/core/`: Application-wide configuration (`env_config.dart`, `app_constants.dart`), domain failures & exceptions, design tokens (`AppColors`, `AppTextStyles`), and pure Dart spatial math utilities (`DistanceCalculator`).
- `lib/features/map/`:
  - `domain/`: Pure business models (`MapFeatureEntity`, `UserLocationEntity`), repository interfaces (`MapRepository`), and use cases (`GetLayerDataUseCase`, `GetUserLocationUseCase`). Zero Flutter UI or MapLibre dependencies.
  - `data/`: REST data sources (`GeoMapidRemoteDataSource`), hardware GPS data sources (`LocationDataSource`), GeoJSON DTO models (`LayerResponseModel`), and repository implementations (`MapRepositoryImpl`).
  - `presentation/`: BLoC/Cubit state management (`MapCubit`, `MapState`), main screen scaffold (`MapPage`), and modular interactive widgets (`MapViewWidget`, `PoiDetailSheet`, `UserLocationButton`, `ReturnToYogyakartaChip`).

---

## 🚀 Getting Started

### 1. Prerequisites
- Flutter SDK `^3.12.2` (tested with Flutter 3.29+)
- Android Studio / Android SDK (compileSdk 34+)

### 2. Environment Setup
Copy the environment template and provide your GEO MAPID credentials:
```bash
cp .env.example .env
```

Edit `.env`:
```properties
MAPID_API_KEY=your_mapid_api_key_here
MAPID_LAYER_ID=your_mapid_layer_id_here
MAPID_PROJECT_ID=your_mapid_project_id_here
MAPID_GEOSERVER_URL=https://geoserver.mapid.io/layers_new/get_layer
MAPID_BASEMAP_STYLE_URL=https://tiles.openfreemap.org/styles/liberty
```

### 3. Install Dependencies & Run
```bash
flutter pub get
flutter run
```

---

## 🔒 Security & Production Release Guidance (SEC-001)

### Local Development vs. Production Release
- **Local Development:** The app reads credentials from `.env` via `flutter_dotenv`. Ensure `.env` is never committed to version control (guarded by `.gitignore`).
- **Production Release Builds:** 
  > [!WARNING]
  > Bundling `.env` as a Flutter asset in release builds packages the plaintext file into the APK (`assets/.env`).
  > For production releases, **do NOT bundle production secrets in `.env`**.

Instead, compile credentials securely using `--dart-define` or `--dart-define-from-file`:
```bash
flutter build apk --release \
  --dart-define=MAPID_API_KEY=production_key \
  --dart-define=MAPID_LAYER_ID=production_layer \
  --dart-define=MAPID_PROJECT_ID=production_project
```
`EnvConfig` automatically resolves compile-time environment flags when runtime `.env` values are absent.

---

## 🧪 Testing & Verification

Run the test suite and static analysis:
```bash
flutter analyze
flutter test --coverage
```

