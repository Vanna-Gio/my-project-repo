# Flutter Product Management – Coding Test

This project is a full-stack Flutter application with a Node.js backend and SQL Server database.
It was developed as part of the Flutter Developer Internship coding test.

## Project Structure
/backend   - Node.js + Express API  
/frontend  - Flutter application (Android, iOS, Desktop)  
/sql       - SQL Server schema and sample data  

## Features
- JWT Authentication (Login, Sign Up, Forgot Password)
- Category CRUD with Khmer & English search (debounced)
- Product CRUD with:
  - Pagination (20 items per page)
  - Sorting by name or price
  - Category filter
  - Debounced search (Khmer supported)
- Local image upload & display
- Cross-platform Flutter support (Mobile & Desktop)

---

## Backend Setup

### Requirements
- Node.js v18+
- SQL Server

### Steps
```bash
cd backend
npm install
cp .env.example .env
npm run dev

Backend runs at:

http://localhost:3000

Frontend Setup
Requirements

Flutter 3+

Steps
cd frontend
flutter pub get
flutter run

Android Emulator Note

Use this base URL instead of localhost:

http://10.0.2.2:3000

API Overview

POST /api/auth/login

POST /api/auth/signup

POST /api/auth/forgot-password

GET /api/categories

POST /api/categories

GET /api/products?page=1&limit=20

POST /api/upload
