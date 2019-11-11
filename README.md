# mapbox_gl_example

Demonstrates how to use the mapbox_gl plugin.

#### Mapbox Access Token

This project uses Mapbox vector tiles, which requires a Mapbox account and a Mapbox access token. Obtain a free access token on [your Mapbox account page](https://www.mapbox.com/account/access-tokens/).

##### Android
Add Mapbox read token value in the application manifest ```android/app/src/main/AndroidManifest.xml:```

```<manifest ...
  <application ...
    <meta-data android:name="com.mapbox.token" android:value="YOUR_TOKEN_HERE" />
```

#### iOS
Add these lines to your Info.plist

```plist
<key>io.flutter.embedded_views_preview</key>
<true/>
<key>MGLMapboxAccessToken</key>
<string>YOUR_TOKEN_HERE</string>
```

Note: ios is having trouble adding places (https://github.com/tobrun/flutter-mapbox-gl/issues/56)

## Getting Started
This project is a starting point for a Flutter application.
This project was taken to modify from (https://github.com/mapbox/flutter-mapbox-gl) to experience the features of the flutter-mapbox-gl package

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.io/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.io/docs/cookbook)

For help getting started with Flutter, view our 
[online documentation](https://flutter.io/docs), which offers tutorials, 
samples, guidance on mobile development, and a full API reference.
