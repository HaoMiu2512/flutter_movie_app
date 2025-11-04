# 📚 Setup & Configuration Guides

This document provides an overview of all available setup and configuration guides for the Flutter Movie App.

---

## 🚀 Quick Start

1. **[Backend Setup](BACKEND_SETUP.md)** - Complete guide to set up Node.js backend
2. **[README](README.md)** - Main project documentation

---

## 🔧 Firebase Configuration

### Core Setup
- **[Firestore Setup](FIRESTORE_SETUP.md)** - Database configuration and initialization
- **[Firestore Rules Setup](FIRESTORE_RULES_SETUP.md)** - Security rules for Firestore
- **[Firebase Storage Setup](FIREBASE_STORAGE_SETUP.md)** - File storage configuration for avatars

### Feature-Specific
- **[Chatroom Firestore Rules](CHATROOM_FIRESTORE_RULES.md)** - Security rules for real-time chat

---

## 🔐 Authentication Guides

- **[Facebook Auth Setup Guide](FACEBOOK_AUTH_SETUP_GUIDE.md)** - Complete Facebook authentication setup
- **[Facebook Auth Quickstart](FACEBOOK_AUTH_QUICKSTART.md)** - Quick reference for Facebook auth
- **[Phone Auth Testing Guide](PHONE_AUTH_TESTING_GUIDE.md)** - Test phone authentication

---

## 🎯 Backend Services

- **[Backend Services Quick Reference](BACKEND_SERVICES_QUICK_REFERENCE.md)** - API endpoints and usage

---

## 🧪 Testing & Debugging

- **[Testing Guide](TESTING_GUIDE.md)** - General testing procedures
- **[Profile Page Testing Guide](PROFILE_PAGE_TESTING_GUIDE.md)** - Test profile features
- **[Troubleshooting](TROUBLESHOOTING.md)** - Common issues and solutions

---

## ⚡ Performance

- **[Performance Optimization Guide](PERFORMANCE_OPTIMIZATION_GUIDE.md)** - App performance tips and best practices

---

## 📁 File Organization

```
flutter_movie_app/
├── SETUP_GUIDES.md                        ← You are here
├── README.md                               ← Main documentation
│
├── Backend/
│   ├── BACKEND_SETUP.md                    ← Backend installation
│   └── BACKEND_SERVICES_QUICK_REFERENCE.md ← API reference
│
├── Firebase/
│   ├── FIRESTORE_SETUP.md                  ← Database setup
│   ├── FIRESTORE_RULES_SETUP.md            ← Security rules
│   ├── FIREBASE_STORAGE_SETUP.md           ← File storage
│   └── CHATROOM_FIRESTORE_RULES.md         ← Chat security
│
├── Authentication/
│   ├── FACEBOOK_AUTH_SETUP_GUIDE.md        ← Facebook login
│   ├── FACEBOOK_AUTH_QUICKSTART.md         ← Quick reference
│   └── PHONE_AUTH_TESTING_GUIDE.md         ← Phone verification
│
├── Testing/
│   ├── TESTING_GUIDE.md                    ← General testing
│   ├── PROFILE_PAGE_TESTING_GUIDE.md       ← Profile testing
│   └── TROUBLESHOOTING.md                  ← Debug guide
│
└── Performance/
    └── PERFORMANCE_OPTIMIZATION_GUIDE.md   ← Optimization tips
```

---

## 🎯 Setup Order (Recommended)

For new developers, follow this order:

1. **Backend Setup**
   ```bash
   # Read BACKEND_SETUP.md first
   cd backend
   npm install
   npm run dev
   ```

2. **Firebase Configuration**
   - Follow `FIRESTORE_SETUP.md`
   - Configure `FIRESTORE_RULES_SETUP.md`
   - Set up `FIREBASE_STORAGE_SETUP.md`

3. **Authentication**
   - Set up Facebook: `FACEBOOK_AUTH_SETUP_GUIDE.md`
   - Configure phone auth: `PHONE_AUTH_TESTING_GUIDE.md`

4. **Testing**
   - Read `TESTING_GUIDE.md`
   - Run tests following guides

5. **Optimization**
   - Apply `PERFORMANCE_OPTIMIZATION_GUIDE.md` tips

---

## 🆘 Need Help?

1. Check **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** first
2. Search in specific guide related to your issue
3. Check backend logs: `BACKEND_SERVICES_QUICK_REFERENCE.md`

---

## 📝 Notes

- All guides are up-to-date as of **November 2024**
- Keep your environment variables secure (never commit to git)
- Always test in development before deploying to production

---

**Last Updated:** November 4, 2025
