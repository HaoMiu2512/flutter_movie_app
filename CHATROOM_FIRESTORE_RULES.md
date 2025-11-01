# 🔐 Firestore Security Rules - Chat Rooms

## 📋 Mô Tả

File này chứa Firestore Security Rules cho chức năng Chat Room. Rules này đảm bảo:
- ✅ Chỉ user đã đăng nhập mới có thể gửi message
- ✅ Mọi người đều có thể đọc message (public chat)
- ✅ User chỉ có thể xóa message của chính mình
- ✅ Message phải có đầy đủ các field bắt buộc

---

## 🚀 Cách Update Firestore Rules

### **Option 1: Qua Firebase Console (Recommended)**

1. Truy cập: https://console.firebase.google.com/
2. Chọn project `flutter-movie-app` (hoặc tên project của bạn)
3. Click vào **Firestore Database** trong sidebar
4. Click tab **Rules**
5. Copy toàn bộ nội dung dưới đây vào editor
6. Click **Publish** để apply rules

---

### **Option 2: Qua Firebase CLI**

```bash
# 1. Cài đặt Firebase CLI (nếu chưa có)
npm install -g firebase-tools

# 2. Login vào Firebase
firebase login

# 3. Init Firebase trong project (nếu chưa init)
cd c:\flutter_app\flutter_movie_app
firebase init firestore

# 4. Copy rules vào file firestore.rules (file này đã tồn tại)
# Sau đó deploy:
firebase deploy --only firestore:rules
```

---

## 📄 Firestore Security Rules

Copy đoạn code sau vào Firebase Console hoặc file `firestore.rules`:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // ============================================
    // CHAT ROOMS COLLECTION
    // ============================================
    
    // Chat room metadata
    match /chatRooms/{chatRoomId} {
      // Anyone can read chat room metadata
      allow read: if true;
      
      // Only authenticated users can create/update chat room metadata
      // (automatically created when first message is sent)
      allow create, update: if request.auth != null;
      
      // No one can delete chat rooms
      allow delete: if false;
      
      // Messages subcollection
      match /messages/{messageId} {
        // Anyone can read messages (public chat)
        allow read: if true;
        
        // Only authenticated users can create messages
        allow create: if request.auth != null
                      && request.resource.data.keys().hasAll([
                           'userId', 'userName', 'userPhotoUrl', 
                           'message', 'timestamp', 'mediaId', 'mediaType'
                         ])
                      && request.resource.data.userId == request.auth.uid
                      && request.resource.data.message is string
                      && request.resource.data.message.size() > 0
                      && request.resource.data.message.size() <= 1000
                      && request.resource.data.mediaId is int
                      && request.resource.data.mediaType in ['movie', 'tv', 'trending', 'upcoming'];
        
        // Users can only update their own messages
        allow update: if request.auth != null
                      && resource.data.userId == request.auth.uid;
        
        // Users can only delete their own messages
        allow delete: if request.auth != null
                      && resource.data.userId == request.auth.uid;
      }
    }
    
    // ============================================
    // EXISTING RULES (Users, Favorites, etc.)
    // ============================================
    
    // Users collection
    match /users/{userId} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == userId;
      
      // User's favorites subcollection
      match /favorites/{favoriteId} {
        allow read: if true;
        allow write: if request.auth != null && request.auth.uid == userId;
      }
      
      // User's recently viewed subcollection
      match /recentlyViewed/{itemId} {
        allow read: if true;
        allow write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

---

## 🔍 Giải Thích Rules

### **1. Chat Room Metadata (`/chatRooms/{chatRoomId}`)**

```javascript
allow read: if true;
```
- **Ai cũng có thể đọc** thông tin chat room (số lượng message, message cuối, etc.)

```javascript
allow create, update: if request.auth != null;
```
- Chỉ **user đã login** mới có thể tạo/update chat room metadata

```javascript
allow delete: if false;
```
- **Không ai có thể xóa** chat room (persistent chat rooms)

---

### **2. Messages (`/chatRooms/{chatRoomId}/messages/{messageId}`)**

#### **Read Access**
```javascript
allow read: if true;
```
- **Public chat**: Ai cũng có thể đọc messages (kể cả chưa login)

#### **Create Access**
```javascript
allow create: if request.auth != null
              && request.resource.data.keys().hasAll([...])
              && request.resource.data.userId == request.auth.uid
              && request.resource.data.message.size() > 0
              && request.resource.data.message.size() <= 1000
```
- ✅ Phải đăng nhập
- ✅ Message phải có đầy đủ fields: `userId`, `userName`, `userPhotoUrl`, `message`, `timestamp`, `mediaId`, `mediaType`
- ✅ `userId` phải khớp với user đang login
- ✅ Message không được rỗng và tối đa 1000 ký tự
- ✅ `mediaType` phải là: `movie`, `tv`, `trending`, hoặc `upcoming`

#### **Update/Delete Access**
```javascript
allow update, delete: if request.auth != null
                       && resource.data.userId == request.auth.uid;
```
- User **chỉ có thể sửa/xóa message của chính mình**

---

## ⚠️ Lưu Ý Quan Trọng

### **1. Publish Rules Trước Khi Test**
Sau khi copy rules vào Firebase Console, **nhớ click PUBLISH** để apply changes.

### **2. Test Rules**
Bạn có thể test rules ngay trong Firebase Console:
1. Click tab **Rules Playground**
2. Chọn operation (read/write)
3. Nhập path (vd: `/chatRooms/movie_557/messages/abc123`)
4. Chọn authentication status
5. Click **Run** để test

### **3. Message Size Limit**
Hiện tại set limit **1000 ký tự** cho mỗi message. Có thể tăng nếu cần:
```javascript
&& request.resource.data.message.size() <= 5000  // 5000 ký tự
```

### **4. Rate Limiting**
Firestore không có built-in rate limiting trong rules. Nếu cần limit số message/phút, cần implement:
- Client-side throttling
- Cloud Function để track và block spammers
- Firebase App Check để chặn abuse

---

## 🧪 Test Cases

### **Test 1: User Chưa Login Đọc Messages**
```
Path: /chatRooms/movie_557/messages
Auth: null
Operation: read
Expected: ✅ ALLOW (public read)
```

### **Test 2: User Đã Login Gửi Message**
```
Path: /chatRooms/movie_557/messages/new_msg
Auth: uid = "user123"
Operation: create
Data: {
  userId: "user123",
  userName: "John Doe",
  message: "Great movie!",
  ...
}
Expected: ✅ ALLOW
```

### **Test 3: User Gửi Message Với Wrong UserId**
```
Data: {
  userId: "hacker456",  // ≠ request.auth.uid
  ...
}
Expected: ❌ DENY
```

### **Test 4: User Xóa Message Của Người Khác**
```
Auth: uid = "user123"
Existing Data: { userId: "user456", ... }
Operation: delete
Expected: ❌ DENY
```

---

## 🎯 Next Steps

Sau khi update Firestore Rules:

1. ✅ **Deploy rules** (qua Console hoặc CLI)
2. ✅ **Test chat** trong app
3. ✅ **Monitor logs** trong Firebase Console → Firestore → Usage tab
4. ✅ **Check errors** nếu có permission denied

---

## 📚 Resources

- [Firestore Security Rules Documentation](https://firebase.google.com/docs/firestore/security/get-started)
- [Rules Playground](https://firebase.google.com/docs/firestore/security/test-rules-emulator)
- [Common Rules Examples](https://firebase.google.com/docs/firestore/security/rules-examples)

---

**Created**: October 30, 2025  
**Author**: GitHub Copilot  
**Project**: Flick Movie App - Chat Room Feature
