# EasyShop - E-commerce Mobile Application

A complete e-commerce mobile application built with **Flutter**, featuring separate Admin and Client applications with Clean Architecture.

---

## 📱 Project Overview

EasyShop is a full-featured e-commerce platform with two distinct applications:

- **Admin App**: Manage products, categories, orders, and profile
- **Client App**: Browse products, manage cart, place orders, and profile management

Both apps share core infrastructure while maintaining separate feature implementations and business logic.

---

## 🏗️ Architecture

The project follows **Clean Architecture** principles with clear separation of concerns:

```
lib/
├── apps/
│   ├── admin/          # Admin app entry point, routing, session
│   └── client/         # Client app entry point, routing, session
├── core/
│   ├── databases/      # API consumer, endpoints
│   ├── errors/         # Error handling, exceptions, failures
│   ├── media/          # Image picker service
│   ├── theme/          # App theme, colors, spacing
│   ├── utils/          # Validators, JSON parsers
│   └── widgets/        # Shared UI components
└── features/
    ├── admin/          # Admin-specific features
    │   ├── auth/       # Authentication (login, OTP, register)
    │   ├── categories/ # Category management
    │   ├── products/   # Product management
    │   ├── orders/     # Order management
    │   └── profile/    # Admin profile
    └── client/         # Client-specific features
        ├── auth/       # Authentication (login, OTP, register)
        ├── categories/ # Browse categories
        ├── profile/    # Client profile
        └── [upcoming]  # Products, Cart, Orders, Favorites
```

### Clean Architecture Layers

Each feature follows a three-layer architecture:

1. **Domain Layer** (Business Logic)
   - Entities: Pure business objects
   - Repositories: Abstract interfaces
   - Use Cases: Single-responsibility business operations

2. **Data Layer** (External Data)
   - Models: Data transfer objects with JSON serialization
   - Data Sources: Remote API implementations
   - Repository Implementations: Concrete repository logic

3. **Presentation Layer** (UI)
   - Cubits/Blocs: State management
   - States: UI state representations
   - Screens: Flutter widgets
   - Widgets: Reusable UI components

---

## 🚀 How to Run

### Prerequisites

- Flutter SDK: `>=3.5.4 <4.0.0`
- Dart SDK: `>=3.5.4 <4.0.0`
- Android Studio / Xcode (for mobile development)
- Backend API running (see API documentation)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd easy_shop
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure environment**
   
   Create a `.env` file in the project root:
   ```env
   BASE_URL=http://your-api-url.com/api
   ```

### Running the Apps

#### Admin App
```bash
# Android
flutter run --flavor admin -t lib/apps/admin/main_admin.dart

# iOS
flutter run --flavor admin -t lib/apps/admin/main_admin.dart
```

#### Client App
```bash
# Android
flutter run --flavor client -t lib/apps/client/main_client.dart

# iOS
flutter run --flavor client -t lib/apps/client/main_client.dart
```

### Building for Production

```bash
# Admin APK
flutter build apk --flavor admin -t lib/apps/admin/main_admin.dart

# Client APK
flutter build apk --flavor client -t lib/apps/client/main_client.dart
```

---

## 📦 Main Packages

### State Management & Architecture
- **flutter_bloc (^8.1.6)**: State management using BLoC pattern
- **get_it (^8.0.3)**: Dependency injection
- **dartz (^0.10.1)**: Functional programming (Either for error handling)

### Networking
- **dio (^5.7.0)**: HTTP client for API calls
- **flutter_dotenv (^5.2.1)**: Environment configuration
- **connectivity_plus (^6.1.1)**: Network connectivity monitoring

### Navigation
- **go_router (^14.6.2)**: Declarative routing with deep linking support

### Location & Maps
- **geolocator (^13.0.2)**: Device location services
- **geocoding (^3.0.0)**: Address to coordinates conversion
- **flutter_map (^7.0.2)**: Interactive maps display

### Media
- **image_picker (^1.1.2)**: Camera and gallery image selection

### UI & Utilities
- **intl (^0.20.1)**: Internationalization and date formatting

---

## ✅ Completed Features

### Admin App
- ✅ **Authentication**: Login, OTP verification, Register
- ✅ **Session Management**: Token-based authentication with auto-restore
- ✅ **Categories**: Create, Read, Update, Delete categories
- ✅ **Products**: Full CRUD operations with images
- ✅ **Orders**: View and manage orders
- ✅ **Profile**: View and edit admin profile with location picker
- ✅ **Dashboard**: Overview statistics (categories, products, orders count)

### Client App (Person A - Auth, Session, Profile)
- ✅ **Authentication**: Login, OTP verification, Register with picture upload
- ✅ **Session Management**: Token-based authentication with route guards
- ✅ **Profile**: 
  - View profile with personal information and delivery address
  - Edit profile with all fields
  - Picture upload
  - Location picker (placeholder)
- ✅ **API Documentation**: Complete endpoint documentation in `docs/`

---

## 🚧 Incomplete Features

### Client App - Remaining Work
The following features are planned but not yet implemented:

#### By Person B (Products & Categories)
- ⏳ **Home Screen**: Categories preview with carousel
- ⏳ **Categories Screen**: Full categories list with grid layout
- ⏳ **Products Listing**: Browse products by category
- ⏳ **Product Details**: Full product information with images
- ⏳ **Search**: Product search functionality

#### By Person C (Cart, Orders, Favorites)
- ⏳ **Shopping Cart**: Add/remove items, quantity management
- ⏳ **Favorites**: Save favorite products
- ⏳ **Orders**: Place orders, view order history, order details
- ⏳ **Checkout**: Order placement with delivery address

### Both Apps
- ⏳ **Comprehensive Testing**: Unit tests, widget tests, integration tests
- ⏳ **Offline Support**: Local caching with connectivity handling
- ⏳ **Push Notifications**: Order updates and announcements
- ⏳ **Advanced Search**: Filters, sorting, price ranges
- ⏳ **Reviews & Ratings**: Product reviews system
- ⏳ **Payment Integration**: Payment gateway integration
- ⏳ **Multi-language Support**: Localization (currently English only)
- ⏳ **Dark Mode**: Full dark theme support

---

## 🎨 Design Patterns Used

- **Clean Architecture**: Separation of concerns across domain, data, and presentation layers
- **Repository Pattern**: Abstract data layer from business logic
- **BLoC Pattern**: Predictable state management with Cubits
- **Dependency Injection**: Loose coupling with GetIt
- **Single Responsibility**: Each class has one reason to change
- **Factory Pattern**: Object creation (Models, Use Cases)
- **Observer Pattern**: Reactive state updates with streams

---

## 🔐 Authentication Flow

### Admin & Client Apps (Similar Flow)

1. **Login**: User enters email & password → Backend sends OTP
2. **OTP Verification**: User enters 6-digit code → Backend returns JWT token
3. **Session Storage**: Token saved securely for API authentication
4. **Auto-Restore**: App checks token validity on startup
5. **Route Guards**: Protected routes redirect to login if unauthenticated
6. **Logout**: Token cleared, user redirected to login

**Note**: Registration also triggers OTP verification before account activation.

---

## 📡 API Integration

### Base URL Configuration
Set in `.env` file:
```env
BASE_URL=http://your-api-url.com/api
```

### API Documentation
Complete API shapes and endpoint documentation available in:
- `docs/admin-api-shapes.md`
- `docs/client_api_shapes.md`

### Error Handling
- Network errors with user-friendly messages
- Field-specific validation errors
- Automatic retry mechanisms
- Connectivity monitoring

---

## 🎯 Project Goals

This project was built with the following goals:

1. **Learning**: Demonstrate Clean Architecture in Flutter
2. **Scalability**: Easy to add new features and maintain code
3. **Separation of Concerns**: Clear boundaries between layers
4. **Code Reusability**: Shared core infrastructure between apps
5. **Best Practices**: Follow Flutter and Dart conventions
6. **Real-world Application**: Production-ready e-commerce platform

---

## 👥 Team Structure (5-Day Plan)

The Client App was developed collaboratively:

- **Person A**: Authentication, Session Management, Profile (Days 1-5)
- **Person B**: Home, Categories, Products (Days 2-5)
- **Person C**: Cart, Orders, Favorites (Days 3-5)

### Work Distribution

| Day | Person A | Person B | Person C |
|-----|----------|----------|----------|
| 1 | Auth Domain + Data | - | - |
| 2 | Login + OTP Screens | Home + Categories UI | - |
| 3 | Register + Session | Products Listing | Cart Foundation |
| 4 | Profile Feature | Product Details | Orders + Favorites |
| 5 | Edit Profile + README | Testing + Polish | Checkout Flow |

---

## 🛠️ Development Notes

### Theme Differentiation
- **Admin App**: Primary Color `#F5821F` (Orange)
- **Client App**: Primary Color `#FF6900` (Darker Orange)

### Code Style
- Follow Dart effective guidelines
- Use `flutter format` before committing
- Run `flutter analyze` to catch issues
- Keep files under 300 lines when possible

### Shared vs. Feature-Specific
- **Shared**: Core utilities, widgets, theme, API consumer
- **Feature-Specific**: Business logic, screens, feature-specific widgets

---

## 📝 Additional Documentation

- **Admin API Shapes**: `docs/admin-api-shapes.md`
- **Client API Shapes**: `docs/client_api_shapes.md`
- **Design Tokens**: `docs/design-tokens.md`
- **Architecture Diagram**: `docs/architecture.md` (if exists)

---

## 🤝 Contributing

If working on this project:

1. Create feature branches: `feature/feature-name`
2. Follow existing architecture patterns
3. Write meaningful commit messages
4. Test thoroughly before merging
5. Update documentation as needed

---

## 📄 License

[Specify your license here]

---

## 🙏 Acknowledgments

Built with ❤️ using Flutter and Clean Architecture principles.

Special thanks to the team for collaborative development and clean code practices.

---

**Happy Coding! 🚀**
