# Quick Start - Backend Setup trong 5 phút

## Bước 1: Cài đặt dependencies (1 phút)

```bash
cd backend
npm install
```

## Bước 2: Setup Firebase Admin SDK (2 phút)

1. Vào https://console.firebase.google.com/
2. Chọn project của bạn
3. ⚙️ Project Settings → Service Accounts
4. Click "Generate New Private Key"
5. Save file vào: `backend/src/config/firebase-service-account.json`

## Bước 3: Cài MongoDB (1 phút)

### Windows:
- Download: https://www.mongodb.com/try/download/community
- Install và start service:
```bash
net start MongoDB
```

### Mac:
```bash
brew tap mongodb/brew
brew install mongodb-community
brew services start mongodb-community
```

### Linux:
```bash
sudo apt-get install mongodb
sudo systemctl start mongod
```

**Hoặc dùng MongoDB Atlas (Cloud - Free):**
1. Tạo account: https://www.mongodb.com/cloud/atlas
2. Create free cluster
3. Get connection string
4. Update trong file `.env`:
```env
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/flutter_movies
```

## Bước 4: Seed data (30 giây)

```bash
npm run seed
```

Kết quả:
```
✅ Database seeded successfully!
Inserted 10 sample movies
```

## Bước 5: Chạy server (30 giây)

```bash
npm run dev
```

Output:
```
🚀 Server is running on port 3000
📱 API available at: http://localhost:3000
```

## Bước 6: Test API

Mở browser:
- http://localhost:3000 → Xem danh sách endpoints
- http://localhost:3000/api/movies → Xem danh sách phim

## Xong! 🎉

Backend đã sẵn sàng. Bây giờ update Flutter app để sử dụng backend này.

## Commands hữu ích

```bash
# Start development server
npm run dev

# Start production server
npm start

# Seed database lại
npm run seed

# Check MongoDB đang chạy
# Windows
tasklist | findstr mongod

# Mac/Linux
ps aux | grep mongod
```

## Nếu gặp lỗi

### MongoDB không connect được
```bash
# Restart MongoDB service
# Windows
net stop MongoDB
net start MongoDB

# Mac
brew services restart mongodb-community

# Linux
sudo systemctl restart mongod
```

### Port 3000 đang được dùng
Thay đổi PORT trong file `.env`:
```env
PORT=3001
```

### Firebase error
Kiểm tra:
- File `firebase-service-account.json` có trong `src/config/`
- Path trong `.env` đúng chưa
- File JSON có valid không (mở bằng text editor xem)

## Next Steps

1. ✅ Backend đang chạy
2. 📱 Cập nhật Flutter app (xem file `BACKEND_SETUP.md`)
3. 🎬 Thêm phim của bạn vào database
4. 🚀 Deploy lên Railway/Render khi sẵn sàng

---

Xem chi tiết: [README.md](README.md) | [BACKEND_SETUP.md](../BACKEND_SETUP.md)
