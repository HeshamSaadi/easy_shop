# EasyShop

EasyShop is an e-commerce training project from Easy Learn Academy, built with Flutter as a real product rather than a collection of screens: Clean Architecture, Bloc/Cubit, REST API integration with Dio, maps and location, and tests.

It is **two apps in one repo**, sharing one `core`:

- **Client app:** register, OTP, login, browse categories and products, product details, favorites, cart, checkout with the delivery address picked on a map, orders list and details, profile.
- **Admin app:** register, login with OTP, manage categories and products, view orders, profile.

## Getting started

### 1. Configuration

The base URL and API key are never committed. Create your local config:

```bash
cp .env.example .env
```

Then fill in the values you received from the mentor. Do not commit `.env`.

### 2. Run the apps

```bash
flutter pub get

# Client app
flutter run --flavor client -t lib/main_client.dart

# Admin app
flutter run --flavor admin -t lib/main_admin.dart
```

Both flavors have their own `applicationId`, so both can be installed on one phone.

### 3. Build APKs

```bash
flutter build apk --flavor client -t lib/main_client.dart
flutter build apk --flavor admin -t lib/main_admin.dart
```

## Architecture

Feature-first Clean Architecture with a shared `core`.

```
lib/
├── main_client.dart / main_admin.dart   # entry points
├── core/                                # shared: network, errors, storage, DI, theme, location, widgets
├── apps/
│   ├── client/                          # router, root widget, DI for the Client app
│   └── admin/                           # same for the Admin app
└── features/
    ├── client/<feature>/{data,domain,presentation}
    └── admin/<feature>/{data,domain,presentation}
```

Each feature has three layers:

- **presentation:** screens, widgets, Cubit and its states.
- **domain:** entities, repository contracts, use cases. Pure Dart.
- **data:** models, remote data sources (Dio), repository implementations.

**Dependency rule:**

```
presentation  ->  domain  <-  data
```

- Domain never imports from data or presentation, and has no Flutter or Dio imports.
- Cubits call use cases only. Widgets never touch Dio or data sources.
- `core` never imports from `features` or `apps`.
- Client and admin features never import each other. They share code only through `core`.

Data flow: Screen -> Cubit -> UseCase -> Repository -> RepositoryImpl -> RemoteDataSource -> Dio -> API.
Errors: the data source throws, the repository returns a `Failure`, the Cubit emits an error state with a readable message.

## Main packages

| Package | Why we use it |
|---|---|
| `flutter_bloc` | Bloc/Cubit state management, one Cubit per screen or small flow |
| `dio` | HTTP client with a central base URL, headers and token interceptor |
| `get_it` | Dependency injection |
| `go_router` | Routing with a session guard for protected screens |
| `flutter_secure_storage` | Stores the auth token securely |
| `file_picker` | Picks images and documents for uploads |
| _(map and location packages)_ | Location picker and viewer |

## Testing

```bash
flutter test
```

Currently **621 tests pass**. They cover validators, utils, error handling, use cases, data sources, repositories and Cubits for both apps. Tests use hand-written fakes (no `bloc_test` or `mocktail`) and check states with `expectLater(cubit.stream, emitsInOrder([...]))`.

Before every push:

```bash
dart format .
flutter analyze
flutter test
```

<!-- Known limitations section: leave for later, see below -->