# Assets Directory

This directory contains app assets like images and icons.

## Structure
- `images/` - App images, logos, splash screens
- `icons/` - App icons

## Placeholder Assets

For now, the app uses Material Design icons. In production, you should add:
- App icon (1024x1024px)
- Splash screen assets
- KasiCash avatar/logo
- Custom illustrations for onboarding slides
- Game card backgrounds

## App Icon

To set up the app icon:
1. Generate app icon using a tool like `flutter_launcher_icons`
2. Add icon files to `assets/icons/`
3. Update `pubspec.yaml` to reference the icon
4. Run `flutter pub run flutter_launcher_icons`

## Splash Screen

To set up the splash screen:
1. Create splash screen images for different densities
2. Add to `assets/images/`
3. Configure in `android/app/src/main/res/` and `ios/Runner/Assets.xcassets/`


