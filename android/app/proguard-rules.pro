# Flutter Wrapper Rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Google Play Core & Deferred Components (R8 warning suppression)
-dontwarn com.google.android.play.core.**

# MapLibre GL Native SDK & Mapbox Engine
-keep class org.maplibre.** { *; }
-keep interface org.maplibre.** { *; }
-keep class com.mapbox.** { *; }
-keep interface com.mapbox.** { *; }
-dontwarn org.maplibre.**
-dontwarn com.mapbox.**

# Geolocator Android Native Plugin
-keep class com.baseflow.geolocator.** { *; }
-dontwarn com.baseflow.geolocator.**
