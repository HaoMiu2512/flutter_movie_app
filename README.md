# 🎬 Flick - Modern Movie & TV Series Discovery App

<div align="center">
  <img src="assets/images/Flick.jpg" alt="Flick Logo" width="200"/>

  [![Flutter](https://img.shields.io/badge/Flutter-3.9.2+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
  [![Firebase](https://img.shields.io/badge/Firebase-Latest-FFCA28?logo=firebase&logoColor=white)](https://firebase.google.com)
  [![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
  [![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
</div>

<p align="center">
  <strong>A beautiful, feature-rich movie and TV series discovery app built with Flutter and Firebase</strong>
</p>

## 📱 About Flick

Flick is a modern mobile application that allows users to discover, browse, and manage their favorite movies and TV series. Built with Flutter for cross-platform compatibility and powered by Firebase for backend services, Flick provides a seamless entertainment browsing experience with a stunning dark-themed UI.

---

## ✨ Features Implemented

### 🔐 **Authentication System**
- ✅ **Email & Password Authentication** - Traditional registration and login
- ✅ **Google Sign-In** - Quick authentication with Google account
- ✅ **Facebook Login** - Sign in using Facebook credentials
- ✅ **Phone Authentication** - SMS-based OTP verification (requires Firebase Blaze Plan)
- ✅ **Forgot Password** - Email-based password reset with verification
- ✅ **Auto Login** - Persistent session management
- ✅ **Secure Logout** - Clean session termination

### 🎥 **Content Discovery**
- ✅ **Trending Content** - Daily and weekly trending movies/TV shows
- ✅ **Popular Movies** - Browse most popular movies with ratings
- ✅ **Now Playing** - Current theatrical releases
- ✅ **Top Rated** - Highest-rated movies and TV series
- ✅ **Upcoming Movies** - See what's coming soon to theaters
- ✅ **TV Series Categories** - Popular, top-rated, and on-the-air shows
- ✅ **View All Pages** - Grid view with infinite scroll pagination for all categories
- ✅ **Carousel Slider** - Swipeable trending content on homepage

### 🔍 **Search & Filter**
- ✅ **Real-time Search** - Instant search for movies and TV shows
- ✅ **Search UI** - Beautiful search interface with results
- ✅ **Combined Results** - Movies and TV series in one search

### 📺 **Detail Pages**
#### Movies Detail:
- ✅ **Comprehensive Info Cards** - Release date, budget, revenue with icons
- ✅ **Ratings Display** - Star rating with visual card
- ✅ **Runtime** - Movie duration with clock icon
- ✅ **Genre Chips** - Purple gradient genre tags
- ✅ **Overview Section** - Styled with cyan accent bar
- ✅ **Video Trailers** - YouTube player integration
- ✅ **User Reviews** - Display user ratings and reviews
- ✅ **Similar Movies** - Horizontal slider of similar content
- ✅ **Recommended Movies** - AI-suggested content

#### TV Series Detail:
- ✅ **Series Information** - Status, seasons, air dates
- ✅ **Episode Count** - Total seasons with purple icon
- ✅ **First Air Date** - Show premiere date
- ✅ **Similar Series** - Related TV shows
- ✅ **Recommended Series** - Suggested content

### ❤️ **Favorites System**
- ✅ **Add to Favorites** - Heart icon toggle on detail pages
- ✅ **Cloud Sync** - Favorites stored in Firebase Firestore
- ✅ **Favorites Page** - Dedicated page to view all saved items
- ✅ **Remove from Favorites** - Easy removal with confirmation
- ✅ **Cross-Device Sync** - Access favorites from any device
- ✅ **No Page Reload** - Instant UI update without refreshing

### 🕒 **Recently Viewed**
- ✅ **Auto-Tracking** - Automatically saves movies/TV shows when viewed
- ✅ **Profile Integration** - Recently viewed section in profile page
- ✅ **Cloud Storage** - Synced via Firebase Firestore
- ✅ **Media Type Badges** - Visual distinction between MOVIE and TV
- ✅ **See All Page** - Full grid view of recently viewed content
- ✅ **Clear All** - Option to clear viewing history
- ✅ **Limit Management** - Auto-cleanup keeps only 20 most recent items
- ✅ **Mixed Content** - Supports both Movies and TV Series
- ✅ **Real-time Updates** - StreamBuilder for live data synchronization

### 📤 **Share Functionality**
- ✅ **Share Button** - Share icon in movie/TV series detail pages
- ✅ **Bottom Sheet UI** - Modern modal bottom sheet interface
- ✅ **Copy Link** - Copy TMDB URL to clipboard with success notification
- ✅ **Share via Apps** - Native share dialog for WhatsApp, Messenger, Email, etc.
- ✅ **TMDB Links** - Direct links to content on The Movie Database
- ✅ **Both Media Types** - Works for both Movies and TV Series
- ✅ **Styled Interface** - Custom themed bottom sheet matching app design

### 👤 **Profile Management**
- ✅ **User Profile Page** - Display user information
- ✅ **Avatar Upload Options**:
  - Upload from device (file picker)
  - Enter image URL
  - Dual option dialog
- ✅ **Avatar Display** - Circular avatar with gradient border
- ✅ **Change Password** - Secure password update (email auth only)
- ✅ **Provider Detection** - Show/hide password change based on login method
- ✅ **User Info Display** - Email, display name, join date
- ✅ **Logout Function** - Clean session termination

### ⚙️ **Settings Page**
- ✅ **Dark Mode Toggle** - UI-only (for future implementation)
- ✅ **Language Selection** - 5 languages (English, Vietnamese, Spanish, French, German)
- ✅ **Notifications Toggle** - Enable/disable notifications
- ✅ **App Version Display** - Show current version and build number
- ✅ **About Dialog** - App information with logo
- ✅ **Open Source Licenses** - View all package licenses
- ✅ **Beautiful Footer** - Flick logo with version info

### 🎨 **UI/UX Enhancements**

#### Splash Screen:
- ✅ **Animated Logo** - Flick logo with scale and fade animation
- ✅ **Loading Progress** - Linear progress indicator (0-100%)
- ✅ **Gradient Background** - Ocean blue gradient
- ✅ **Smooth Transition** - Fade transition to login page
- ✅ **3-Second Duration** - Perfect timing for initialization

#### Design System:
- ✅ **Consistent Color Palette**:
  - Primary: Cyan (#00BCD4)
  - Secondary: Teal Accent
  - Background: Dark Blue Gradient (#0A1929 → #001E3C)
  - Surface: #0A1929

- ✅ **Typography Hierarchy**:
  - Titles: 28-32px Bold
  - Subtitles: 16-20px Semi-bold
  - Body: 14-15px Regular
  - Captions: 12-13px Regular

- ✅ **Spacing System**: Multiples of 8 (8px, 16px, 24px, 32px)

- ✅ **Border Radius**:
  - Cards/Buttons: 12px
  - Logos: 15-20px
  - Genre Chips: 20px (pill shape)

- ✅ **Component Styling**:
  - Info cards with gradient backgrounds
  - Cyan glow shadows on interactive elements
  - Consistent button heights (56px)
  - Form fields with cyan accents

#### Branding:
- ✅ **Logo Integration**:
  - Splash Screen: Flick logo (with text)
  - Login Page: Flick_NoInfo logo (clean)
  - Register Page: Flick_NoInfo logo
  - Forgot Password: Flick_NoInfo logo
  - HomePage Drawer: Flick logo (circular)
  - Settings: Flick logo (2 locations)

- ✅ **App Name**: Changed from "Movie App" to "Flick" throughout

#### Authentication Pages:
- ✅ **Consistent Design** - All auth pages use same gradient and styling
- ✅ **Logo Placement** - Centered logo with proper sizing
- ✅ **Form Validation** - Real-time input validation
- ✅ **Error Handling** - Beautiful error messages with SnackBars
- ✅ **Loading States** - CircularProgressIndicator during operations

#### Detail Pages Redesign:
- ✅ **Info Cards** - Card-based layout with icons and gradients
- ✅ **Section Headers** - Cyan accent bar with bold titles
- ✅ **Improved Spacing** - Consistent padding and margins
- ✅ **Currency Formatting** - $1.23B, $4.56M format for budget/revenue
- ✅ **Conditional Rendering** - Show reviews only if available

### 🚀 **Performance Optimizations**
- ✅ **No Page Reload on Favorite Toggle** - Instant UI update
- ✅ **Lazy Loading** - Load data once on page init
- ✅ **Efficient State Management** - No unnecessary rebuilds
- ✅ **Image Caching** - TMDB images cached automatically
- ✅ **Pagination** - Load more items on scroll

---

## 🔄 Features Need to Be Updated

### 🌓 **Theme System**
- ⏳ **Light Mode Implementation** - Currently dark mode only
- ⏳ **Theme Persistence** - Save user's theme preference
- ⏳ **Automatic Theme Switch** - Based on system settings

### 🔔 **Notifications**
- ⏳ **Push Notifications** - Firebase Cloud Messaging integration
- ⏳ **New Release Alerts** - Notify users of new movies/shows
- ⏳ **Favorite Updates** - Alert when favorite content gets new episodes

### 🎬 **Enhanced Content Features**
- ⏳ **Continue Watching** - Resume from where you left off
- ⏳ **Personalized Recommendations** - AI-based suggestions
- ⏳ **Rating System** - Allow users to rate content
- ⏳ **User Reviews** - Write and share reviews

### 🔍 **Search Improvements**
- ⏳ **Search History** - Save recent searches
- ⏳ **Advanced Filters** - Genre, year, rating filters
- ⏳ **Search Suggestions** - Auto-complete search queries
- ⏳ **Voice Search** - Search using voice input

### 📱 **Social Features**
- ⏳ **Friend System** - Connect with other users
- ⏳ **Activity Feed** - See what friends are watching
- ⏳ **Comments** - Discuss movies with other users

### 💾 **Offline Features**
- ⏳ **Download Content Info** - Save for offline viewing
- ⏳ **Offline Favorites** - Access favorites without internet
- ⏳ **Sync on Reconnect** - Auto-sync when online

### 👥 **User Experience**
- ⏳ **Multi-Profile Support** - Multiple user profiles per account
- ⏳ **Parental Controls** - Content restrictions
- ⏳ **Watchlist Organization** - Custom lists and categories

### 📺 **Video Features**
- ⏳ **Chromecast Support** - Cast to TV
- ⏳ **Picture-in-Picture** - Watch while browsing
- ⏳ **Multiple Trailer Sources** - YouTube, Vimeo support
- ⏳ **Full-Screen Mode** - Landscape video player

---

## 🎨 UI/UX Improvements Needed

### 📱 **Mobile Responsiveness**
- ⏳ **Tablet Layout** - Optimize for larger screens
- ⏳ **Landscape Mode** - Better landscape support
- ⏳ **Adaptive Layouts** - Responsive grid columns

### 🎭 **Animations**
- ⏳ **Page Transitions** - Smooth navigation animations
- ⏳ **Hero Animations** - Image transitions between pages
- ⏳ **Micro-interactions** - Button press, card hover effects
- ⏳ **Loading Skeletons** - Skeleton screens while loading

### 🎨 **Visual Enhancements**
- ⏳ **Glassmorphism** - Frosted glass effects on cards
- ⏳ **Parallax Scrolling** - Depth effect on scroll
- ⏳ **Gradient Animations** - Animated background gradients
- ⏳ **Custom Illustrations** - Empty state illustrations

### 📊 **Data Visualization**
- ⏳ **Rating Charts** - Visual rating breakdown
- ⏳ **Statistics Page** - User watching statistics
- ⏳ **Genre Distribution** - Pie chart of favorite genres
- ⏳ **Watch Time Analytics** - Time spent watching

### 🔧 **Accessibility**
- ⏳ **Screen Reader Support** - VoiceOver/TalkBack support
- ⏳ **High Contrast Mode** - For visually impaired
- ⏳ **Font Size Options** - Adjustable text size
- ⏳ **Color Blind Mode** - Alternative color schemes

### 🎯 **User Onboarding**
- ⏳ **Welcome Tour** - First-time user guide
- ⏳ **Feature Highlights** - Showcase new features
- ⏳ **Tutorial Videos** - How-to guides
- ⏳ **Interactive Tutorial** - Step-by-step walkthrough

---

## 🚀 Getting Started

### Prerequisites

Before you begin, ensure you have installed:
- **Flutter SDK** (version 3.9.2 or higher) - [Install Flutter](https://flutter.dev/docs/get-started/install)
- **Dart SDK** (comes with Flutter)
- **Android Studio** or **VS Code** with Flutter extensions
- **Git** for version control
- **Firebase Account** - [Create Firebase Account](https://firebase.google.com/)
- **TMDB Account** - [Get TMDB API Key](https://www.themoviedb.org/settings/api)

### Installation Steps

#### 1️⃣ Clone the Repository

```bash
# Clone the project
git clone https://github.com/yourusername/flutter_movie_app.git

# Navigate to project directory
cd flutter_movie_app
```

#### 2️⃣ Install Dependencies

```bash
# Get all Flutter packages
flutter pub get

# Verify Flutter installation
flutter doctor
```

#### 3️⃣ Setup TMDB API Key

1. Visit [The Movie Database (TMDB)](https://www.themoviedb.org/)
2. Create an account and navigate to Settings → API
3. Request an API key (free for non-commercial use)
4. Create a file: `lib/apikey/apikey.dart`

```dart
// lib/apikey/apikey.dart
const String apikey = 'YOUR_TMDB_API_KEY_HERE';
```

⚠️ **Important**: Never commit your API key to Git. Add `lib/apikey/apikey.dart` to `.gitignore`

#### 4️⃣ Setup Firebase

##### A. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **"Add Project"**
3. Enter project name (e.g., "Flick Movie App")
4. Enable Google Analytics (optional)
5. Click **"Create Project"**

##### B. Enable Firebase Services

**Authentication:**
1. Go to **Authentication** → **Sign-in method**
2. Enable the following providers:
   - ✅ Email/Password
   - ✅ Google
   - ✅ Facebook (requires Facebook App setup)
   - ⚠️ Phone (requires Blaze Plan - paid tier)

**Firestore Database:**
1. Go to **Firestore Database**
2. Click **"Create Database"**
3. Start in **Test Mode** (for development)
4. Choose a location close to your users

**Firebase Storage (Optional):**
1. Go to **Storage**
2. Click **"Get Started"**
3. Use default security rules
4. ⚠️ Note: Requires Blaze Plan for production

##### C. Configure Android

1. In Firebase Console, click **"Add App"** → Android icon
2. Enter Android package name: `com.example.flutter_movie_app`
3. Download `google-services.json`
4. Place it in: `android/app/google-services.json`

Update `android/app/build.gradle.kts`:
```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services") // Add this line
}

android {
    namespace = "com.example.flutter_movie_app"
    compileSdk = 34

    defaultConfig {
        applicationId = "com.example.flutter_movie_app"
        minSdk = 21  // Required for image_picker
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
    }
}
```

Update `android/build.gradle.kts`:
```kotlin
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.1.0")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.0")
        classpath("com.google.gms:google-services:4.4.0") // Add this
    }
}
```

Update `android/app/src/main/AndroidManifest.xml`:
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Add permissions -->
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.CAMERA"/>
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"
        android:maxSdkVersion="32" />
    <uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>

    <application
        android:label="Flick"
        android:icon="@mipmap/ic_launcher">
        <!-- Your activities here -->
    </application>
</manifest>
```

##### D. Configure iOS

1. In Firebase Console, click **"Add App"** → iOS icon
2. Enter iOS Bundle ID: `com.example.flutterMovieApp`
3. Download `GoogleService-Info.plist`
4. Open Xcode: `open ios/Runner.xcworkspace`
5. Drag `GoogleService-Info.plist` into `Runner` folder

Update `ios/Runner/Info.plist`:
```xml
<dict>
    <!-- Add these permissions -->
    <key>NSPhotoLibraryUsageDescription</key>
    <string>This app needs access to your photo library to update your profile picture.</string>

    <key>NSCameraUsageDescription</key>
    <string>This app needs access to your camera to take a profile picture.</string>

    <!-- Other keys... -->
</dict>
```

##### E. Firestore Security Rules

Go to Firestore Database → Rules and paste:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;

      // Favorites subcollection
      match /favorites/{movieId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }

      // Recently viewed subcollection
      match /recently_viewed/{movieId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

##### F. Google Sign-In Setup

1. Get SHA-1 fingerprint:
```bash
cd android
./gradlew signingReport
```

2. Copy the SHA-1 key from the output
3. Go to Firebase Console → Project Settings → Your apps → Android app
4. Click **"Add Fingerprint"** and paste SHA-1

##### G. Facebook Login Setup (Optional)

1. Create a Facebook App at [Facebook Developers](https://developers.facebook.com/)
2. Add **Facebook Login** product
3. Get **App ID** and **App Secret**
4. In Firebase Console → Authentication → Sign-in method → Facebook:
   - Paste App ID and App Secret
   - Copy the OAuth redirect URI
5. In Facebook App Settings → Facebook Login:
   - Add OAuth redirect URI
   - Add package name and key hash

#### 5️⃣ Generate Firebase Configuration

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase
flutterfire configure
```

This will generate `lib/firebase_options.dart` automatically.

#### 6️⃣ Run the App

```bash
# Check connected devices
flutter devices

# Run on specific device
flutter run -d <device-id>

# Run in debug mode
flutter run

# Run in release mode (optimized)
flutter run --release

# Build APK for Android
flutter build apk --release

# Build IPA for iOS
flutter build ios --release
```

### Troubleshooting

#### Common Issues:

**1. "No Firebase App has been created"**
```bash
# Make sure you ran flutterfire configure
flutterfire configure
```

**2. "MissingPluginException"**
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

**3. "Gradle build failed"**
```bash
cd android
./gradlew clean
cd ..
flutter run
```

**4. "CocoaPods not installed" (iOS)**
```bash
sudo gem install cocoapods
cd ios
pod install
cd ..
```

---

## 📦 Dependencies

### Core Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter

  # Firebase Backend
  firebase_core: ^4.1.1          # Firebase initialization
  firebase_auth: ^6.1.0          # Authentication
  cloud_firestore: ^6.0.2        # Cloud database
  firebase_storage: ^13.0.2      # File storage

  # Authentication Providers
  google_sign_in: ^6.2.2         # Google OAuth
  flutter_facebook_auth: ^7.1.2  # Facebook Login

  # UI Components
  carousel_slider: ^5.1.1        # Image carousels
  font_awesome_flutter: ^10.10.0 # Icon library

  # Networking
  http: ^1.5.0                   # HTTP requests

  # Media Players
  youtube_player_flutter: ^9.1.3 # YouTube videos
  webview_flutter: ^4.13.0       # Web views

  # Local Storage
  shared_preferences: ^2.3.4     # Key-value storage

  # State Management
  provider: ^6.1.2               # State management

  # Utilities
  image_picker: ^1.1.2           # Pick images
  package_info_plus: ^8.1.2      # App info
  fluttertoast: ^9.0.0          # Toast messages
  share_plus: ^10.1.3            # Share content

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0          # Linting
```

---

## 🏗️ Project Structure

```
flutter_movie_app/
├── android/                    # Android native code
│   ├── app/
│   │   ├── src/main/
│   │   │   ├── AndroidManifest.xml
│   │   │   └── kotlin/
│   │   ├── build.gradle.kts
│   │   └── google-services.json    # Firebase config (not in Git)
│   └── build.gradle.kts
│
├── ios/                        # iOS native code
│   ├── Runner/
│   │   ├── Info.plist
│   │   └── GoogleService-Info.plist # Firebase config (not in Git)
│   └── Podfile
│
├── lib/                        # Flutter Dart code
│   ├── apikey/
│   │   └── apikey.dart        # TMDB API key (not in Git)
│   │
│   ├── details/               # Detail pages
│   │   ├── checker.dart       # Media type checker
│   │   ├── moviesdetail.dart  # Movie details
│   │   └── tvseriesdetail.dart # TV series details
│   │
│   ├── HomePage/              # Home screen
│   │   ├── HomePage.dart      # Main home page
│   │   └── SectionPage/
│   │       ├── movies.dart    # Movies section
│   │       ├── tvseries.dart  # TV series section
│   │       └── upcoming.dart  # Upcoming movies
│   │
│   ├── LoginPage/             # Authentication screens
│   │   ├── login_page.dart            # Email login
│   │   ├── register_page.dart         # Sign up
│   │   ├── forgot_password_page.dart  # Password reset
│   │   ├── phone_auth_page.dart       # Phone auth
│   │   └── otp_verification_page.dart # OTP input
│   │
│   ├── models/                # Data models
│   │   └── movie.dart         # Movie/TV model
│   │
│   ├── pages/                 # Other pages
│   │   ├── favorites_page.dart        # Favorites list
│   │   ├── profile_page.dart          # User profile
│   │   ├── settings_page.dart         # App settings
│   │   ├── change_password_page.dart  # Password change
│   │   ├── view_all_page.dart         # Grid view page
│   │   └── recently_viewed_all_page.dart # Recently viewed grid
│   │
│   ├── reapeatedfunction/     # Reusable widgets
│   │   ├── slider.dart                # Horizontal slider
│   │   ├── searchbarfunction.dart     # Search widget
│   │   ├── trailerui.dart             # Video player
│   │   └── userreview.dart            # Review display
│   │
│   ├── services/              # Business logic
│   │   ├── auth_service.dart          # Auth operations
│   │   ├── favorites_service.dart     # Favorites CRUD
│   │   └── recently_viewed_service.dart # Recently viewed tracking
│   │
│   ├── firebase_options.dart  # Firebase config (auto-generated)
│   ├── main.dart              # App entry point
│   └── splash_screen.dart     # Splash screen
│
├── assets/                    # Static assets
│   └── images/
│       ├── Flick.jpg          # Logo with text
│       └── Flick_NoInfo.jpg   # Logo without text
│
├── pubspec.yaml               # Dependencies
├── .gitignore                 # Git ignore rules
└── README.md                  # This file
```

---

## 🎯 API Integration

### TMDB API Endpoints Used

```dart
// Trending
GET https://api.themoviedb.org/3/trending/all/week?api_key={API_KEY}
GET https://api.themoviedb.org/3/trending/all/day?api_key={API_KEY}

// Movies
GET https://api.themoviedb.org/3/movie/popular?api_key={API_KEY}&page={PAGE}
GET https://api.themoviedb.org/3/movie/now_playing?api_key={API_KEY}
GET https://api.themoviedb.org/3/movie/top_rated?api_key={API_KEY}
GET https://api.themoviedb.org/3/movie/upcoming?api_key={API_KEY}
GET https://api.themoviedb.org/3/movie/{MOVIE_ID}?api_key={API_KEY}
GET https://api.themoviedb.org/3/movie/{MOVIE_ID}/videos?api_key={API_KEY}
GET https://api.themoviedb.org/3/movie/{MOVIE_ID}/reviews?api_key={API_KEY}
GET https://api.themoviedb.org/3/movie/{MOVIE_ID}/similar?api_key={API_KEY}
GET https://api.themoviedb.org/3/movie/{MOVIE_ID}/recommendations?api_key={API_KEY}

// TV Series
GET https://api.themoviedb.org/3/tv/popular?api_key={API_KEY}
GET https://api.themoviedb.org/3/tv/top_rated?api_key={API_KEY}
GET https://api.themoviedb.org/3/tv/on_the_air?api_key={API_KEY}
GET https://api.themoviedb.org/3/tv/{TV_ID}?api_key={API_KEY}
GET https://api.themoviedb.org/3/tv/{TV_ID}/videos?api_key={API_KEY}
GET https://api.themoviedb.org/3/tv/{TV_ID}/reviews?api_key={API_KEY}
GET https://api.themoviedb.org/3/tv/{TV_ID}/similar?api_key={API_KEY}
GET https://api.themoviedb.org/3/tv/{TV_ID}/recommendations?api_key={API_KEY}

// Search
GET https://api.themoviedb.org/3/search/multi?api_key={API_KEY}&query={QUERY}
```

### Image URLs
```dart
// Poster Images
https://image.tmdb.org/t/p/w500{poster_path}

// Backdrop Images
https://image.tmdb.org/t/p/original{backdrop_path}
```

---

## 🔒 Security & Best Practices

### Environment Variables
Never commit sensitive data:
```
# .gitignore
lib/apikey/apikey.dart
android/app/google-services.json
ios/Runner/GoogleService-Info.plist
*.env
```

### Firestore Rules (Production)
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;

      match /favorites/{movieId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }

      match /recently_viewed/{movieId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

### API Key Protection
- Use environment variables for production
- Implement API key rotation
- Monitor API usage in TMDB dashboard

---

## 🐛 Known Issues & Limitations

### Firebase Limitations
1. **Phone Authentication**
   - ⚠️ Requires Firebase Blaze Plan (pay-as-you-go)
   - Free: 10,000 verifications/month
   - After limit: $0.05 per verification

2. **Firebase Storage**
   - ⚠️ File uploads require Blaze Plan
   - Workaround: Using URL-based avatars

3. **Cloud Firestore**
   - Free tier: 1 GiB storage, 50K reads/day, 20K writes/day
   - May need upgrade for production

### App Limitations
1. **Theme**: Only dark mode available (light mode coming soon)
2. **Offline Mode**: Limited offline functionality
3. **Performance**: Large lists may lag on older devices
4. **Video Playback**: YouTube only (no native video player)

---

## 📱 Supported Platforms

| Platform | Minimum Version | Status |
|----------|----------------|---------|
| Android  | API 21 (5.0)   | ✅ Fully Supported |
| iOS      | iOS 12.0       | ✅ Fully Supported |
| Web      | -              | ⏳ Not Yet |
| Desktop  | -              | ⏳ Not Yet |

---

## 🤝 Contributing

Contributions are welcome! Here's how you can help:

### Reporting Bugs
1. Check if the issue already exists
2. Create a detailed bug report with:
   - Steps to reproduce
   - Expected vs actual behavior
   - Screenshots/videos
   - Device and OS version

### Suggesting Features
1. Open an issue with the "enhancement" label
2. Describe the feature and use case
3. Add mockups or examples if possible

### Submitting Pull Requests
1. Fork the repository
2. Create a feature branch:
   ```bash
   git checkout -b feature/amazing-feature
   ```
3. Make your changes
4. Test thoroughly
5. Commit with clear messages:
   ```bash
   git commit -m "Add: Amazing feature description"
   ```
6. Push to your fork:
   ```bash
   git push origin feature/amazing-feature
   ```
7. Open a Pull Request

### Code Style Guidelines
- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use meaningful variable names
- Add comments for complex logic
- Keep functions small and focused
- Write unit tests for new features

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2024 Flick

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

## 🙏 Acknowledgments

### APIs & Services
- [TMDB (The Movie Database)](https://www.themoviedb.org/) - For the comprehensive movie/TV API
- [Firebase](https://firebase.google.com/) - For authentication and cloud services
- [Flutter](https://flutter.dev/) - For the amazing cross-platform framework

### Open Source Libraries
Special thanks to all the package maintainers:
- `firebase_core`, `firebase_auth`, `cloud_firestore` - Firebase Team
- `google_sign_in` - Google
- `flutter_facebook_auth` - Darwin Morocho
- `carousel_slider` - Serenader
- `youtube_player_flutter` - Sarbagya Dhaubanjar
- `font_awesome_flutter` - Flutter Community
- And many more!

### Design Inspiration
- Material Design 3 Guidelines
- Modern streaming app UIs (Netflix, Disney+)
- Dribbble & Behance community

---

## 📞 Support & Contact

### Get Help
- 📧 **Email**: your.email@example.com
- 🐛 **Issues**: [GitHub Issues](https://github.com/yourusername/flutter_movie_app/issues)
- 💬 **Discussions**: [GitHub Discussions](https://github.com/yourusername/flutter_movie_app/discussions)

### Connect
- 🌐 **Website**: [yourwebsite.com](https://yourwebsite.com)
- 🐦 **Twitter**: [@yourhandle](https://twitter.com/yourhandle)
- 💼 **LinkedIn**: [Your Name](https://linkedin.com/in/yourname)
- 📸 **Instagram**: [@yourhandle](https://instagram.com/yourhandle)

---

## 📊 Project Status

| Feature | Status | Priority |
|---------|--------|----------|
| Authentication | ✅ Complete | High |
| Content Browse | ✅ Complete | High |
| Search | ✅ Complete | High |
| Favorites | ✅ Complete | High |
| Profile | ✅ Complete | Medium |
| Settings | ✅ Complete | Medium |
| Light Mode | ⏳ Planned | Medium |
| Notifications | ⏳ Planned | Low |
| Social Features | ⏳ Future | Low |

---

## 🎯 Roadmap

### Version 1.0 (Current) ✅
- [x] Authentication system
- [x] Browse movies & TV shows
- [x] Search functionality
- [x] Favorites/Watchlist
- [x] User profile
- [x] Dark theme

### Version 1.1 (Q2 2024) 🔄
- [ ] Light mode
- [ ] Push notifications
- [ ] Watch history
- [ ] Improved search filters

### Version 2.0 (Q3 2024) 📅
- [ ] Social features
- [ ] User ratings & reviews
- [ ] Personalized recommendations
- [ ] Multi-profile support

### Version 3.0 (Q4 2024) 🚀
- [ ] Offline mode
- [ ] Chromecast support
- [ ] Picture-in-Picture
- [ ] Desktop version

---

<div align="center">
  <h3>⭐ If you like this project, please give it a star! ⭐</h3>

  <p>Made with Haotonn using Flutter & Firebase</p>

  <p>© 2024 Flick - All Rights Reserved</p>

  <a href="https://flutter.dev">
    <img src="https://img.shields.io/badge/Built%20with-Flutter-02569B?logo=flutter&logoColor=white" alt="Built with Flutter"/>
  </a>
  <a href="https://firebase.google.com">
    <img src="https://img.shields.io/badge/Powered%20by-Firebase-FFCA28?logo=firebase&logoColor=white" alt="Powered by Firebase"/>
  </a>
</div>
