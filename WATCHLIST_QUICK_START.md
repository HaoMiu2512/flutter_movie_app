# Watchlist Feature - Quick Start Guide

## 🚀 Start Backend Server

```bash
cd backend
npm install  # If first time
npm start    # Start on port 3000
```

Backend sẽ chạy tại `http://localhost:3000` (Android emulator: `http://10.0.2.2:3000`)

---

## 📱 Test in Flutter App

### 1. Restart App
```bash
flutter run
```

### 2. Login First
- Tap avatar icon → Login với Firebase
- Email/Password, Phone, hoặc Facebook

### 3. Access My Lists
- Swipe to **MY LISTS** tab (tab thứ 4)
- Hoặc từ drawer menu

---

## 🎯 Quick Test Flow

### Create Your First List
1. Tap **MY LISTS** tab
2. Tap **+ icon** (top right)
3. Enter name: "Favorites" 
4. (Optional) Add description
5. Tap **Create**

### Add Movies/TV to List
1. Open any **Movie** or **TV Series** detail
2. Tap **Bookmark icon** (📑) in AppBar
3. Select existing list OR create new
4. Tap list name → Item added!

### View & Manage List
1. Go to **MY LISTS** tab
2. Tap your list card
3. See all items with posters
4. Tap item → Open detail
5. Tap **X** → Remove from list
6. Tap **⋮** (3 dots) → Edit or Delete list

---

## 🧪 Test Scenarios

### Basic Operations
- ✅ Create list → Verify in grid
- ✅ Add movie to list → Check bookmark icon turns cyan
- ✅ View list → See item with poster
- ✅ Remove item → Verify removed
- ✅ Delete list → Verify gone

### Edge Cases
- ✅ Add same item to multiple lists
- ✅ Create list from detail page dialog
- ✅ Edit list name/description
- ✅ Public/private toggle
- ✅ Pull to refresh lists
- ✅ Empty list state
- ✅ Not logged in state

---

## 🔍 Check Backend Data

### MongoDB Compass
Connect to: `mongodb://localhost:27017/flutter_movie_app`

Collections:
- `watchlists` - User lists với items array
- `users` - User data

### Postman API Testing

**Get all lists:**
```
GET http://localhost:3000/api/watchlists
Authorization: Bearer <firebase_token>
```

**Create list:**
```
POST http://localhost:3000/api/watchlists
Authorization: Bearer <firebase_token>
Content-Type: application/json

{
  "name": "My Favorites",
  "description": "Best movies ever",
  "isPublic": false
}
```

**Add item to list:**
```
POST http://localhost:3000/api/watchlists/:listId/items
Authorization: Bearer <firebase_token>
Content-Type: application/json

{
  "itemId": "123",
  "itemType": "movie",
  "title": "Inception",
  "posterPath": "/path.jpg",
  "voteAverage": 8.8
}
```

---

## 🐛 Troubleshooting

### "Please login to create lists"
- Make sure you're logged in với Firebase
- Check Firebase auth status in console

### "Failed to get watchlists"
- Verify backend is running: `http://localhost:3000/health`
- Check Firebase token in request headers
- Check MongoDB connection

### Bookmark icon not showing
- Wait for page to load fully (MovieDetails array)
- Check console for errors
- Verify WatchlistService API calls

### Items not appearing in list
- Refresh list (pull down)
- Check backend response in console
- Verify item was added successfully

---

## 📝 API Endpoints Reference

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/watchlists` | Get all user's lists |
| GET | `/api/watchlists/check?itemId=X&itemType=Y` | Check if item in lists |
| GET | `/api/watchlists/:id` | Get specific list |
| POST | `/api/watchlists` | Create new list |
| PUT | `/api/watchlists/:id` | Update list |
| DELETE | `/api/watchlists/:id` | Delete list |
| POST | `/api/watchlists/:id/items` | Add item to list |
| DELETE | `/api/watchlists/:id/items/:itemId` | Remove item |

All require: `Authorization: Bearer <firebase_token>`

---

## ✅ Success Indicators

- ✅ Backend console shows: `🚀 Server is running on port 3000`
- ✅ MY LISTS tab loads without errors
- ✅ Can create lists and see them in grid
- ✅ Bookmark icon appears in movie/TV details
- ✅ Can add items and see them in list detail
- ✅ Pull to refresh works
- ✅ Edit/delete operations work

---

## 🎨 UI Components

### My Lists Tab
- **Empty State**: Lock icon + "Please login" OR Movie icon + "No lists yet"
- **Grid View**: 2 columns, cards with gradient backgrounds
- **+ Icon**: Top right, creates new list

### List Detail Page
- **Header**: List name + item count
- **Items**: Poster + title + type badge + rating + remove button
- **Menu**: 3 dots → Edit / Delete

### Add to List Dialog
- **Item Preview**: Small poster + title + type
- **Lists**: Scrollable với checkmarks
- **Create New**: Expandable text field
- **Actions**: Close / Create & Add

### Bookmark Button
- **States**: 
  - Loading (small spinner)
  - Not in list (outline bookmark, white)
  - In list (filled bookmark, cyan)

---

## 🚀 Ready to Use!

Tất cả đã hoàn thành và ready to test. Enjoy your new Watchlist feature! 🎉
