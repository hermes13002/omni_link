# OmniLink

> Your digital universe, seamlessly connected. Organize with tags, sync across devices, and share files instantly.

OmniLink is a modern, cross-platform digital workspace designed to unify file storage, organization, and sharing. Built with a robust Python/FastAPI backend and visually stunning Flutter interfaces, OmniLink provides a seamless experience whether you are on the web, iOS, or Android.

---

## Architecture Overview

The OmniLink project is organized as a monorepo containing four distinct services, each tailored for a specific domain of the application ecosystem.

### 1. `omnilink_backend` (The Core API)
The central nervous system of OmniLink, built for high performance and scalability.
* **Framework:** FastAPI (Python 3.12+)
* **Database:** PostgreSQL (via Neon DB) with `asyncpg` and SQLAlchemy 2.0.
* **Caching & Pub/Sub:** Redis (for real-time events and token blocklisting).
* **Storage:** Google Cloud Storage (GCS) for secure, scalable object storage with signed URLs.
* **Authentication:** JWT-based auth (Access + Refresh tokens) and Google OAuth2 integration.
* **Deployment:** Pre-configured for deployment on **FastAPI Cloud**, with automatic Alembic migrations run programmatically on startup.

### 2. `omnilink_frontend` (The User Client)
The primary cross-platform application for end-users.
* **Framework:** Flutter (Dart)
* **State Management:** BLoC (Business Logic Component).
* **Networking:** Dio with custom interceptors for automatic token refreshing.
* **Auth:** Email/Password and native Google Sign-in integration.
* **Deployment:** Deploys as a highly responsive Web App (via Render) and compiles natively to iOS and Android.

### 3. `omnilink_admin` (The Admin Dashboard)
A dedicated secure portal for system administrators to manage the OmniLink ecosystem.
* **Framework:** Flutter (Web)
* **Features:** User management, role-based access control (RBAC), system health monitoring, and comprehensive audit logging.
* **Security:** Requires administrative privileges and an additional `Admin Secret Key` for authentication.

### 4. `omnilink_landing` (The Marketing Site)
A fast, beautiful, and SEO-optimized landing page to showcase OmniLink's capabilities.
* **Framework:** React + Vite
* **Styling:** TailwindCSS + Framer Motion for buttery-smooth micro-animations.
* **Deployment:** Deployed as a static site via Render.

---

## Getting Started

### Prerequisites
* **Python 3.12+** (Backend)
* **Flutter SDK** (Frontend & Admin)
* **Node.js 20+** (Landing Page)
* **PostgreSQL & Redis** (Local or Cloud instances like Neon DB / Upstash)
* **Google Cloud Project** (For GCS credentials and OAuth Client IDs)

### Backend Setup
1. Navigate to the backend directory:
   ```bash
   cd omnilink_backend
   ```
2. Create and activate a virtual environment:
   ```bash
   python -m venv .venv
   source .venv/bin/activate
   ```
3. Install dependencies:
   ```bash
   pip install -e .
   ```
4. Configure your `.env` file (see `.env.example` if available) with your NeonDB, Redis, and GCS credentials. Place your Google OAuth `client_secret_*.json` in this folder.
5. Run the server locally:
   ```bash
   uvicorn app.main:app --reload
   ```
   *(Note: Alembic migrations will run automatically on startup).*

### Frontend Setup
1. Navigate to the frontend directory:
   ```bash
   cd omnilink_frontend
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app:
   ```bash
   flutter run -d chrome  # Or select an iOS/Android emulator
   ```

---

## Deployment

OmniLink is built to be cloud-native:
* **Backend:** Deployed to **FastAPI Cloud**. Environment variables (including `GOOGLE_CLIENT_ID`) must be set in the cloud dashboard. 
* **Frontends (Web & Admin):** Deployed to **Render** as static sites. The `render.yaml` file in the root directory manages the build and routing (e.g., rewriting rules for Single Page Applications).
* **Landing Page:** Deployed to **Render** as a static site using the Vite build pipeline.

---

## Security & Privacy
* **Stateless Auth:** Secure JWT implementations with short-lived access tokens and Redis-backed blocklisting for refresh tokens.
* **Signed URLs:** Files are never served directly; GCS signed URLs provide temporary, secure access to assets.
* **Audit Trails:** Administrative actions and security alerts (e.g., suspicious logins) are logged immutably in the database.


*OmniLink — The future of file synchronization.*
