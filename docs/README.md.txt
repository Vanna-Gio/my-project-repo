1️⃣ Root README.md (MANDATORY)

Create /README.md

# Flutter Developer Coding Test – TonaireDigital

## Project Structure
/backend   - Node.js + Express API  
/frontend  - Flutter application  
/sql       - SQL Server schema & sample data  

## Requirements
- Node.js v18+
- SQL Server
- Flutter 3+

## Backend Setup
```bash
cd backend
npm install
cp .env.example .env
npm run dev


API runs on:

http://localhost:3000

Frontend Setup
cd frontend
flutter pub get
flutter run

Android Emulator Note

Use:

http://10.0.2.2:3000


instead of localhost.

Features

JWT Authentication (Login, Signup, Forgot Password)

Category CRUD with Khmer & English search (debounced)

Product CRUD with pagination, sorting, filter

Local image storage

Cross-platform (Android, iOS, Desktop)


---

## 2️⃣ Backend README

Create `/backend/README.md`

Include:
- Environment variables explanation
- API list
- Image upload endpoint

Example:
```md
## API Endpoints

POST /api/auth/login  
POST /api/auth/signup  
POST /api/auth/forgot-password  

GET /api/categories  
POST /api/categories  

GET /api/products?page=1&limit=20  
POST /api/upload  

3️⃣ SQL Scripts

In /sql/ include:

schema.sql

sample_data.sql

This makes reviewers happy. Trust me.

4️⃣ Git Final Check (CRITICAL)

Before submission:

git status


Make sure:

❌ No .env

❌ No node_modules

❌ No build/

✅ Clean commits

✅ One repository only

STEP 13: Video Demo (MAX 7 minutes)

This matters more than UI beauty.

Suggested Flow (STRICT)

Intro (30 sec)
“This is my Flutter test for TonaireDigital.”

Backend demo (1 min)

Show login API

Show categories API

Show products pagination

Flutter demo (4 min)

Login

Category CRUD (Khmer search)

Product list scroll

Sorting

Category filter

Image loading

Desktop view resize

Wrap up (30 sec)
“All requirements are implemented.”

FINAL SUBMISSION CHECKLIST ✅

✔ GitHub repo pushed
✔ Only ONE submission
✔ Backend runs
✔ Flutter runs
✔ Khmer search works
✔ Pagination real (not fake)
✔ Images load
✔ README clear
✔ Video under 7 min

⚠️ Common LAST-MINUTE FAILS

Forgot Khmer COLLATE

Pagination loads same data

No debounce

Video too long

README missing