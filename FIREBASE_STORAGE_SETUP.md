# Firebase Storage Setup Guide

## Lỗi: firebase_storage/object-not-found

Lỗi này xảy ra vì **Firebase Storage Rules** chưa được cấu hình đúng cách hoặc chưa cho phép người dùng upload file.

## Hướng dẫn cấu hình Firebase Storage Rules

### Bước 1: Truy cập Firebase Console

1. Mở [Firebase Console](https://console.firebase.google.com/)
2. Chọn project của bạn
3. Trong menu bên trái, chọn **Storage**
4. Chọn tab **Rules** ở trên cùng

### Bước 2: Cập nhật Storage Rules

Copy và paste rules sau vào Firebase Storage Rules:

```javascript
rules_version = '2';

service firebase.storage {
  match /b/{bucket}/o {

    // Cho phép đọc file công khai (avatars)
    match /avatars/{userId} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == userId;
    }

    // Cho phép đọc file công khai với extension .jpg
    match /avatars/{userId}.jpg {
      allow read: if true;
      allow write: if request.auth != null
                  && request.auth.uid == userId
                  && request.resource.size < 5 * 1024 * 1024  // Max 5MB
                  && request.resource.contentType.matches('image/.*');
    }

    // Default: deny all access
    match /{allPaths=**} {
      allow read, write: if false;
    }
  }
}
```

### Bước 3: Giải thích Rules

#### 1. **Public Read, Authenticated Write cho Avatars**
```javascript
match /avatars/{userId}.jpg {
  allow read: if true;  // Ai cũng có thể xem avatar
  allow write: if request.auth != null && request.auth.uid == userId;
  // Chỉ user đó mới upload được avatar của mình
}
```

#### 2. **Giới hạn File Size và Type**
```javascript
request.resource.size < 5 * 1024 * 1024  // Max 5MB
request.resource.contentType.matches('image/.*')  // Chỉ cho phép ảnh
```

### Bước 4: Publish Rules

1. Sau khi paste rules vào, click nút **Publish** màu xanh ở góc trên bên phải
2. Đợi vài giây để rules được áp dụng

### Bước 5: Kiểm tra Storage Bucket

1. Trong Storage, kiểm tra xem bạn đã có **bucket** chưa
2. Nếu chưa có, click **Get Started** để khởi tạo Storage
3. Chọn location gần bạn nhất (ví dụ: asia-southeast1 cho Việt Nam)

## Rules cho Development (Testing)

Nếu bạn đang test và muốn cho phép mọi người read/write (KHÔNG DÙNG CHO PRODUCTION):

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## Rules cho Production (Bảo mật cao)

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {

    // Avatars - Public read, owner write only
    match /avatars/{userId}.jpg {
      allow read: if true;
      allow write: if request.auth != null
                  && request.auth.uid == userId
                  && request.resource.size < 5 * 1024 * 1024
                  && request.resource.contentType.matches('image/.*');
    }

    // Private user files
    match /users/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // Deny everything else
    match /{allPaths=**} {
      allow read, write: if false;
    }
  }
}
```

## Troubleshooting

### Lỗi: "Firebase Storage: User does not have permission"

**Nguyên nhân:** Storage Rules chưa cho phép write

**Giải pháp:**
1. Kiểm tra user đã login chưa (`request.auth != null`)
2. Kiểm tra rules đã publish chưa
3. Đợi vài phút để rules được apply

### Lỗi: "Firebase Storage: Object does not exist"

**Nguyên nhân:**
- Storage bucket chưa được khởi tạo
- Path upload không đúng

**Giải pháp:**
1. Vào Firebase Console > Storage
2. Click "Get Started" để khởi tạo bucket
3. Kiểm tra path trong code: `avatars/${userId}.jpg`

### Lỗi: "Firebase Storage: Quota exceeded"

**Nguyên nhân:** Đã vượt quá giới hạn free tier của Firebase

**Giải pháp:**
1. Xem usage trong Firebase Console > Storage > Usage
2. Upgrade plan nếu cần
3. Hoặc giảm kích thước ảnh (hiện tại đang resize về 512x512)

## Testing

Sau khi cấu hình rules, test upload avatar:

1. Run app: `flutter run`
2. Login vào app
3. Vào Profile page
4. Click icon camera để upload avatar
5. Chọn ảnh từ gallery
6. Kiểm tra xem có lỗi không

## Kiểm tra Rules trong Firebase Console

Bạn có thể test rules trực tiếp trong Firebase Console:

1. Vào **Storage > Rules**
2. Click tab **Rules Playground**
3. Test các scenarios:
   - Read avatar: `/avatars/user123.jpg` với auth
   - Write avatar: `/avatars/user123.jpg` với auth uid = user123

## Cấu trúc thư mục Storage

```
storage_bucket/
└── avatars/
    ├── user_id_1.jpg
    ├── user_id_2.jpg
    └── user_id_3.jpg
```

Mỗi user sẽ có 1 avatar file với tên là `{userId}.jpg`.

## Lưu ý Security

1. ✅ **Luôn validate file type và size** trong rules
2. ✅ **Chỉ cho phép user upload avatar của chính họ**
3. ✅ **Set giới hạn size (5MB)**
4. ✅ **Public read cho avatars để hiển thị trong app**
5. ❌ **KHÔNG cho phép write public** (bất kỳ ai cũng upload được)

## Additional Resources

- [Firebase Storage Rules Documentation](https://firebase.google.com/docs/storage/security)
- [Firebase Storage Security Best Practices](https://firebase.google.com/docs/storage/security/start)
