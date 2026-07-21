# Softverse — Project Instructions

Flutter app using **GetX** for state management/routing and **flutter_screenutil** for
responsive sizing. Follow the conventions below for every new feature or screen,
whether it comes from a Figma flow or a plain text description.

## Feature folder structure

Every distinct flow (auth, home, profile, etc.) gets its own folder under
`lib/features/<feature_name>/`, following the existing `lib/features/home/` layout:

```
lib/features/<feature_name>/
  controller/
    <feature_name>_controller.dart   // GetxController
  views/
    screens/
      <screen_name>_screen.dart      // e.g. login_screen.dart, signup_screen.dart
  widgets/
    <specific_widget>.dart           // widgets used only by this feature
  models/
    <specific_model>.dart           // model used only by this feature
```

Example for an `auth` feature with multiple screens:

```
lib/features/auth/
  controller/
    auth_controller.dart
  views/
    screens/
      login_screen.dart
      signup_screen.dart
      forgot_password_screen.dart
      reset_password_screen.dart
  widgets/
    login_form_fields.dart
  models/
    login_response_model.dart
```

- One feature = one folder. Don't split a single flow (e.g. auth) across multiple
  top-level feature folders — login, signup, forgot/reset password all live under
  `features/auth/`.
- `controller/` holds the `GetxController` subclass(es) for that feature only.
- `views/screens/` holds the top-level screens for that feature (the things routed to).
- `widgets/` holds widgets that are specific to that feature and reused across its
  own screens (e.g. a combined email+password field group for auth). Don't put
  feature-specific widgets in `core/common/widgets`.

## Widgets

- **Every screen and every custom widget is a `StatelessWidget`.** State lives in the
  GetX controller, not in widget state. Use `Obx(...)` / `GetX<T>(...)` to react to
  observables, and `GetView<T>` for screens bound to a single controller (see
  `home_screen.dart` for the pattern).
- If a screen needs a specific composed widget (e.g. the email+password field group
  on the login screen), extract it into `lib/features/<feature_name>/widgets/` rather
  than inlining it in the screen file.
- **Reusable, cross-feature widgets belong in `lib/core/common/widgets/`.** Before
  building a new button, text field, dialog, etc., check that folder first — reuse
  what's there instead of creating a near-duplicate.
- Build reusable widgets to be configurable via parameters instead of hardcoding
  variants. For example:
  - A shared text field widget should accept params like `backgroundColor`,
    `prefixIcon`, `suffixIcon`, `hasBorder` (or `border`), `contentPadding`,
    `obscureText`, `hintText`, `validator`, etc.
  - A shared primary/submit button widget should accept params like `label`,
    `onPressed`, `isLoading`, `backgroundColor`, `textColor`, `width`, `height`,
    so every submit button in the app looks and behaves consistently.
  - Don't create a second "primary button" or "app text field" widget if an
    existing one in `core/common/widgets` can be extended with a new parameter.

## Controllers (GetX)

- One controller per feature in `lib/features/<feature_name>/controller/`, e.g.
  `AuthController extends GetxController`.
- Register it in `lib/core/bindings/controller_binder.dart` via
  `Get.lazyPut<XController>(() => XController(), fenix: true)`, following the
  existing `HomeController` registration.
- Screens consume the controller via `GetView<XController>` (like `HomeScreen`)
  and access it through `controller.xyz`, wrapping reactive parts in `Obx(...)`.

## Routing

- Add new screens to `lib/routes/app_routes.dart` following the existing pattern:
  a named route string constant + a `GetPage` entry in `AppRoute.routes`.

## Colors & theming

- **Never hardcode a `Color(0x...)` value in a screen or widget.** Every color used
  in the app must be defined once in [`lib/core/utils/constants/colors.dart`](lib/core/utils/constants/colors.dart)
  (the `AppColors` class) and referenced from there.
- If a new color is needed for a feature (e.g. a specific accent), add it as a new
  static const on `AppColors` first, then use it — don't inline a new `Color(...)`.
- For light/dark-aware colors, check `lib/core/utils/theme/app_colors_extension.dart`
  and use `context.appColors` (as `home_screen.dart` does) instead of
  `Theme.of(context)` raw values or hardcoded colors.
- Text styles go through `getTextStyle(...)` in
  `lib/core/common/styles/global_text_style.dart` — don't inline `TextStyle(...)`
  with raw colors/weights when an equivalent helper exists.

## General

- Use `flutter_screenutil` (`.w`, `.h`, `.r`, `.sp`) for sizes, matching existing code.
- Check `lib/core/` (`common/widgets`, `utils/constants`, `utils/theme`, `services`,
  `models`) before adding something new — it likely already has a place for it.

## Building screens from Figma (MCP Magic)

Use both the screenshot and the JSON node data — they answer different
questions:

- **Screenshot (`export_node_as_image` / `read_my_design`)** → the design
  idea. Decode the returned base64 PNG with a Python script
  (`base64.b64decode(...)` to a `.png`, then view it) to see overall layout,
  what an `IMAGE`-type fill actually depicts, and which asset (e.g. a white vs
  colored logo variant) matches it. This is for visual understanding only.
- **`get_node_info` / `get_nodes_info` (JSON)** → the actual content. Use a
  Python script to pull the exact `absoluteBoundingBox` (x/y/width/height),
  `fontSize`, `fontWeight`, `letterSpacing`, `cornerRadius`, and fill/stroke
  colors for every element on the screen — buttons, text, images, containers,
  everything. Never estimate a dimension, color, or font size by eye off the
  screenshot when the JSON already has the exact value for it.
- Convert Figma px to this app's `flutter_screenutil` design size (390×844)
  proportionally before applying `.w`/`.h`/`.sp`: scale factor =
  `390 / <figma frame width>` (and check the frame's height ratio matches,
  since screens with a different aspect ratio need separate width/height
  factors).

## Verifying changes

- Do not launch the app in a simulator/emulator to verify changes. Use
  `flutter analyze` (and `flutter pub get` if dependencies/assets changed) to
  confirm correctness instead. Only run the app on a device/simulator if the
  user explicitly asks for it.
