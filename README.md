# 🏢 Syndic Management — Backend API

A RESTful backend built with **Node.js + Express + SQL Server** for managing building syndicates (copropriété). Covers authentication, charges, payments, general assemblies, notifications, and financial reports.

---

## 🗂️ Project Structure

```
syndic-backend/
├── src/
│   ├── config/
│   │   ├── database.js       # SQL Server connection pool
│   │   ├── migrate.js        # Creates all tables
│   │   └── seed.js           # Sample data
│   ├── controllers/
│   │   ├── authController.js
│   │   ├── immeublesController.js
│   │   ├── proprietairesController.js
│   │   ├── chargesController.js
│   │   ├── paiementsController.js
│   │   ├── assembleesController.js
│   │   ├── notificationsController.js
│   │   └── rapportsController.js
│   ├── middleware/
│   │   ├── auth.js           # JWT authenticate + authorize
│   │   └── errorHandler.js
│   ├── routes/               # One file per resource
│   ├── services/
│   │   └── notificationService.js
│   ├── app.js                # Express app setup
│   └── server.js             # Entry point
├── .env.example
├── package.json
└── README.md
```

---

## ⚙️ Setup

### 1. Install dependencies
```bash
npm install
```

### 2. Configure environment
```bash
cp .env.example .env
# Edit .env with your SQL Server credentials
```

### 3. Create database
In SQL Server Management Studio (SSMS):
```sql
CREATE DATABASE SyndicDB;
```

### 4. Run migrations + seed
```bash
npm run setup
# or separately:
npm run migrate
npm run seed
```

### 5. Start the server
```bash
npm run dev      # Development (nodemon)
npm start        # Production
```

---

## 🔐 Authentication

All protected routes require a Bearer token in the Authorization header:
```
Authorization: Bearer <your_jwt_token>
```

### Roles
| Role           | Access                                      |
|---------------|---------------------------------------------|
| `admin`        | Full access                                 |
| `syndic`       | Manage buildings, charges, assemblies, reports |
| `proprietaire` | View own charges, payments, notifications   |

---

## 📋 API Endpoints

### Auth — `/api/auth`
| Method | Endpoint               | Role      | Description                  |
|--------|------------------------|-----------|------------------------------|
| POST   | `/login`               | Public    | Login (syndic or proprietaire)|
| POST   | `/register`            | Admin/Syndic | Create new user             |
| GET    | `/me`                  | Any       | Get current user info        |
| PUT    | `/change-password`     | Any       | Change own password          |

**Login request:**
```json
{
  "email": "syndic@syndic.com",
  "password": "Syndic@1234"
}
```

---

### Immeubles — `/api/immeubles`
| Method | Endpoint    | Role   | Description          |
|--------|-------------|--------|----------------------|
| GET    | `/`         | Syndic | List own buildings   |
| GET    | `/:id`      | Syndic | Get building detail  |
| POST   | `/`         | Syndic | Create building      |
| PUT    | `/:id`      | Syndic | Update building      |
| DELETE | `/:id`      | Syndic | Delete building      |

---

### Propriétaires — `/api/proprietaires`
| Method | Endpoint         | Role         | Description             |
|--------|------------------|--------------|-------------------------|
| GET    | `/`              | Syndic       | List all owners         |
| GET    | `/profile/me`    | Propriétaire | Get own profile         |
| GET    | `/:id`           | Any          | Get owner detail        |
| PUT    | `/:id`           | Syndic       | Update owner info       |

---

### Charges — `/api/charges`
| Method | Endpoint                  | Role         | Description                   |
|--------|---------------------------|--------------|-------------------------------|
| GET    | `/`                       | Any          | List charges (filtered by role)|
| GET    | `/:id`                    | Any          | Get charge detail             |
| POST   | `/`                       | Syndic       | Create charge                 |
| PUT    | `/:id`                    | Syndic       | Update charge                 |
| DELETE | `/:id`                    | Syndic       | Delete charge                 |
| GET    | `/impayes/dashboard`      | Syndic       | Unpaid charges dashboard      |

**Query params:** `?statut=en_retard&immeubleId=1&page=1&limit=20`

---

### Paiements — `/api/paiements`
| Method | Endpoint                    | Role         | Description               |
|--------|-----------------------------|--------------|---------------------------|
| GET    | `/`                         | Any          | List payments             |
| POST   | `/`                         | Syndic       | Record a payment          |
| GET    | `/suivi/:proprietaireId`    | Any          | Payment tracking per owner|

---

### Assemblées Générales — `/api/assemblees`
| Method | Endpoint    | Role         | Description                    |
|--------|-------------|--------------|--------------------------------|
| GET    | `/`         | Any          | List assemblies (filtered)     |
| GET    | `/:id`      | Any          | Get assembly detail            |
| POST   | `/`         | Syndic       | Plan assembly (notifies owners)|
| PUT    | `/:id`      | Syndic       | Update assembly                |
| DELETE | `/:id`      | Syndic       | Delete assembly                |

---

### Notifications — `/api/notifications`
| Method | Endpoint         | Role   | Description                       |
|--------|------------------|--------|-----------------------------------|
| GET    | `/`              | Any    | Get own notifications             |
| PUT    | `/:id/read`      | Any    | Mark one as read                  |
| PUT    | `/read-all`      | Any    | Mark all as read                  |
| POST   | `/send`          | Syndic | Send notification to all owners   |

---

### Rapports — `/api/rapports`
| Method | Endpoint       | Role   | Description                         |
|--------|----------------|--------|-------------------------------------|
| GET    | `/financier`   | Syndic | Full financial report               |
| GET    | `/impayes`     | Syndic | List of all unpaid charges          |
| GET    | `/history`     | Syndic | Report generation history           |

**Query params:** `?immeubleId=1&dateDebut=2026-01-01&dateFin=2026-12-31`

---

## 🧪 Test Accounts (after seed)

| Role          | Email                  | Password     |
|---------------|------------------------|--------------|
| Admin         | admin@syndic.com       | Admin@1234   |
| Syndic        | syndic@syndic.com      | Syndic@1234  |
| Propriétaire  | prop1@syndic.com       | Prop@1234    |
| Propriétaire  | prop2@syndic.com       | Prop@1234    |
| Propriétaire  | prop3@syndic.com       | Prop@1234    |

---

## 🗄️ Database Schema

```
Users ──────────── Syndics
  │                  │
  └─── Proprietaires │
            │        │
            └── Immeubles ──── Charges ──── Paiements
                    │
                    └── AssembleesGenerales
Users ─── Notifications
Syndics ─── Rapports
```

---

## 🔧 Environment Variables

| Variable                  | Description                        |
|---------------------------|------------------------------------|
| `PORT`                    | Server port (default: 3000)        |
| `DB_SERVER`               | SQL Server host                    |
| `DB_PORT`                 | SQL Server port (default: 1433)    |
| `DB_DATABASE`             | Database name                      |
| `DB_USER`                 | SQL Server username                |
| `DB_PASSWORD`             | SQL Server password                |
| `DB_TRUST_SERVER_CERTIFICATE` | Set `true` for local dev       |
| `JWT_SECRET`              | Secret key for JWT signing         |
| `JWT_EXPIRES_IN`          | Token expiry (e.g., `7d`)         |
