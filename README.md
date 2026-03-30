# 📱 Task Management App (Flutter + FastAPI + PostgreSQL)

A full-stack Task Management application built using **Flutter** for the frontend and **FastAPI (Python)** with **PostgreSQL** for the backend.

This project was developed as part of the **Flodo AI Take-Home Assignment**.

---

## 🎯 Track Chosen

✅ **Track A: Full-Stack Builder**

- Frontend: Flutter (Dart)
- Backend: FastAPI (Python)
- Database: PostgreSQL

---

## 🚀 Features

### ✅ Core Requirements Implemented

- 📝 **Task Data Model**
  - Title
  - Description
  - Due Date
  - Status (Pending, In Progress, Done)
  - Blocked By (Task Dependency)

- 📋 **Task List Screen**
  - Displays all tasks
  - Blocked tasks appear visually different (disabled/greyed out)

- ✏️ **Task Creation & Editing**
  - Add new tasks
  - Edit existing tasks
  - Select dependency (Blocked By)

- 🔄 **CRUD Operations**
  - Create, Read, Update, Delete tasks

- 💾 **Draft Persistence**
  - User input is saved locally
  - Restored if user leaves screen accidentally

- 🔍 **Search**
  - Search tasks by title

- 🎯 **Filter**
  - Filter tasks by status

- ⏳ **2-Second Delay Simulation**
  - Applied on Create & Update
  - Shows loading indicator
  - Prevents duplicate submissions

---

## 🖼️ Screenshots

### 🏠 Home Screen
<img src="Features/home_page.png" width="300"/>

### 📖 Read Task
<img src="Features/read_task.png" width="300"/>

### ➕ Add Task
<img src="Features/add_new_task.png" width="300"/>

### ✏️ Edit Task
<img src="Features/edit_task.png" width="300"/>

### 🔍 Search Task
<img src="Features/search_task.png" width="300"/>

### 🎯 Filter by Status
<img src="Features/filter_status.png" width="300"/>

### 🔒 Block Task
<img src="Features/block_task.png" width="300"/>

### 🔓 Unblocked After Parent Done
<img src="Features/unblock_after.png" width="300"/>

---

## 🏗️ Tech Stack

### Frontend
- Flutter
- Dart
- Stateful Widgets
- REST API Integration

### Backend
- FastAPI (Python)
- PostgreSQL
- REST API

---

## ⚙️ How to Run the Project (Step-by-Step)

### 🔹 1. Clone Repository

```bash
git clone https://github.com/chauhanmuskan291980-wq/Flodo_AI.git
cd My_FLUTTER_APP
```

---

## 🧩 Backend Setup (FastAPI + PostgreSQL)

### 🔹 2. Navigate to Backend Folder

```bash
cd Backend
```

---

### 🔹 3. Create Virtual Environment

```bash
python -m venv .venv
```

Activate it:

**Windows (PowerShell):**
```bash
.venv\Scripts\activate
```

---

### 🔹 4. Install Dependencies

```bash
pip install -r requirements.txt
```

---

### 🔹 5. Setup PostgreSQL Database

1. Open PostgreSQL
2. Create a database:

```sql
CREATE DATABASE taskdb;
```

3. Update your database connection string:

```python
DATABASE_URL = "postgresql://username:password@localhost:5432/taskdb"
```

---

### 🔹 6. Run Backend Server

```bash
uvicorn main:app --reload
```

Backend will run on:
```
http://127.0.0.1:8000
```

---

## 📱 Frontend Setup (Flutter)

### 🔹 7. Navigate to Flutter App

```bash
cd ../my_app
```

---

### 🔹 8. Install Dependencies

```bash
flutter pub get
```

---

### 🔹 9. Run the App

```bash
flutter run
```

---

## 🔗 API Connection

Make sure your Flutter app uses:

```dart
const String baseUrl = "http://127.0.0.1:8000";
```

For Android Emulator:

```dart
http://10.0.2.2:8000
```

---

## ⏳ Important Notes

- Create & Update operations have a 2-second delay
- Loading indicator is shown during API calls
- Prevents duplicate submissions

---

## 🧪 Test the App

1. Add a new task  
2. Edit the task  
3. Assign "Blocked By"  
4. Mark parent task as Done  
5. Verify blocked task becomes active  
6. Test search and filter  

---

## 🧠 Key Technical Decisions

- ⚡ Used **FastAPI** for high-performance backend  
- 🔗 Implemented **task dependency logic**  
- 💾 Used **SharedPreferences** for draft persistence  
- 🛠️ Handled **Flutter Dropdown edge cases**  
- ⏳ Simulated API delays for better UX  

---

## 🤖 AI Usage Report

### ✅ Helpful Prompts
- "Flutter DropdownButtonFormField error fix"
- "FastAPI CRUD with PostgreSQL"
- "Save form draft using SharedPreferences"

### ❌ Issues Faced & Fixes

- Dropdown crash due to invalid value  
  ✔ Fixed by validating selected value  

- SharedPreferences error  
  ✔ Fixed using:
  ```bash
  flutter clean
  flutter pub get
  ```

---

## 🚀 Future Improvements

- 🔄 Drag & Drop Task Ordering  
- ⏱️ Recurring Tasks  
- 🎨 Improved UI Animations  
- 🔔 Notifications  

---

## 🎥 Demo Video

👉 Add your demo video link here  

---

## 👨‍💻 Author

**Muskan Chauhan**  
💼 Flutter Developer | Full-Stack Enthusiast  

---