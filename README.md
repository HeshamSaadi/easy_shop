# EasyShop

EasyShop is an e-commerce training project from Easy Learn Academy. It is built as **two Flutter apps from one repository**, sharing one `core` (network, errors, storage, theme, shared widgets, location picker):

- **Admin app** for store owners: register, login with an email OTP, profile, categories, products and orders.
- **Client app** for customers: browse products, cart, checkout with a delivery location picked on a map, orders and favorites.

Design: [Figma file](https://www.figma.com/design/7mTJfdcUlavMtVHAB05a8K/Easy-Shop?node-id=1-329&t=7DYxDqTg5Giz3v9O-0)

## Status

| App | State |
|---|---|
| Admin | Done: auth (register, login, OTP, session restore, logout), profile, home dashboard, categories, products and orders. |
| Client | Not implemented yet. The entry point (`lib/main_client.dart`) and the `client` flavor exist. |

## Admin app features

- Register in 3 steps (personal, business, security) with document and picture upload and an optional store location on a map
- Login with email and password, then a 6-digit OTP (valid 10 minutes, resend supported)
- Session saved securely and restored on app start, logout
- View and edit profile
- Categories: list, add, edit, delete
- Products: list, details, add, edit, delete, image upload, visible toggle
- Orders: list and details (customer, delivery address with "View on Map", payment). Order status is read-only.

## Tech stack

| Area | Package |
|---|---|
| State management | `flutter_bloc` (Cubit) |
| Dependency injection | `get_it` |
| Routing | `go_router` |
| Networking | `dio` |
| Functional results (`Either`) | `dartz` |
| Token storage | `flutter_secure_storage` |
| Local cache | `shared_preferences` |
| Connectivity | `connectivity_plus` |
| Config (`.env`) | `flutter_dotenv` |
| Maps and location | `flutter_map` with OpenStreetMap (no API key needed), `latlong2`, `geolocator`, `geocoding` |
| Images | `image_picker` |
| Formatting | `intl` |
| Tests | `flutter_test` with hand-written fakes (no mocking packages) |

Built with Flutter 3.47.7 and Dart 3.13.5.

## Architecture

Clean Architecture, feature-first. Each feature has three layers, plus a shared `core`:

```
lib/
├── main_client.dart        # entry point: Client app
├── main_admin.dart         # entry point: Admin app
├── core/                   # shared: network, errors, storage, DI, theme, location, widgets
├── apps/
│   ├── client/             # root widget, router, DI of the Client app
│   └── admin/              # root widget, router, DI of the Admin app
└── features/
    ├── client/<feature>/
    └── admin/<feature>/
        ├── data/           # models, Dio data sources, repository implementations
        ├── domain/         # entities, repository contracts, use cases
        └── presentation/   # Cubits, screens, widgets
```

Rules:

- `presentation -> domain <- data`. The domain layer is pure Dart.
- Screens talk to Cubits, Cubits talk to use cases. No Dio or data source is used from the UI.
- `features/client` and `features/admin` never import each other. They share code only through `core`.
- Errors: the data source throws an exception, the repository returns a `Failure`, the Cubit emits an error state with a readable message.
- Every API-backed screen has loading, empty and error-with-retry states.

More details are in `docs/`.

## Getting started

Requirements: Flutter 3.47.7 (Dart 3.13.5) and an Android device or emulator.

```bash
git clone https://github.com/HeshamSaadi/easy_shop.git
cd easy_shop
git checkout develop
cp .env.example .env          # Windows PowerShell: Copy-Item .env.example .env
flutter pub get
```

Open `.env` and fill in the values (the base URL and API key are given by the course mentor). **Never commit `.env`.**

Run an app:

```bash
flutter run --flavor admin  -t lib/main_admin.dart
flutter run --flavor client -t lib/main_client.dart
```

Build an APK:

```bash
flutter build apk --flavor admin  -t lib/main_admin.dart
flutter build apk --flavor client -t lib/main_client.dart
```

The two flavors have different application IDs, so both apps can be installed on the same phone.

## Admin sign-in flow

Register -> Login -> OTP verification -> token -> Home.

- Register does **not** send an OTP and does not return a token. After registering, the user goes to login.
- Every login sends a new OTP by email. Login never returns a token.
- Verifying the OTP returns the token. An OTP can be used once.
- The token is a JWT valid for **1 hour**. It is saved in secure storage, added to requests by an interceptor, checked for expiry on app start, and deleted on logout.
- When the server answers 401 to a request that carried a token, the session is treated as expired and the user goes back to login. A 401 on the login or OTP screens only shows the error message.

## Tests

```bash
flutter test
flutter test --coverage
```

Tests live under `test/` and mirror the structure of `lib/`. They cover the validators, the phone and JWT helpers, API error parsing, and the use cases, repositories, models and Cubits of the Admin features (auth, profile, categories, products, orders, home) and of the session.

## Code quality and Git

```bash
dart format .
flutter analyze
```

Branches: `main` (always runs), `develop` (integration) and short `feature/*` or `fix/*` branches, merged into `develop` through reviewed pull requests. Commit messages follow `feat:`, `fix:`, `refactor:`, `docs:`, `test:`, `chore:`.

## Known limitations

- OTP is delivered by email only. The SMS part of the API is not working yet.
- The token lasts 1 hour and the API has no refresh endpoint, so the user logs in again (with a new OTP) after it expires.
- Order status is read-only in the Admin app, because the API has no endpoint to change it.
- Categories are shared by all admins. The app does not stop an admin from editing a category created by someone else.
- The API is not paginated, so lists are loaded in full.
- The server does not read form-data sent with a real `PUT` (profile and product updates). The app sends a `POST` with the field `_method=PUT` instead.
- The base URL and API key are read from `.env`, which is bundled with the app as an asset. They are not in Git, but they are inside the built APK. This is acceptable for a training project; a production app would call a backend instead.
- Client app: not implemented yet.

## Team

- TODO-NAME: core network, admin shell, auth, profile
- TODO-NAME: core UI, categories, home dashboard
- TODO-NAME: setup, flavors, CI, location, products, orders