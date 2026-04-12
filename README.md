# 🏢 Syndic Management API — v2.0

Backend REST API built with **Node.js + Express + SQL Server** for modernising a syndic management application (CDC — EST Safi / ISWY Consulting).

---

## 🗂️ Project Structure

```
syndic-backend/
├── src/
│   ├── config/
│   │   ├── database.js          # SQL Server connection pool
│   │   ├── migrate.js           # Creates all tables
│   │   └── seed.js              # Sample data (3 user types)
│   ├── controllers/
│   │   ├── authController.js
│   │   ├── immeublesController.js
│   │   ├── proprietairesController.js
│   │   ├── locatairesController.js      ← NEW
│   │   ├── chargesController.js         ← updated (nom field)
│   │   ├── paiementsController.js       ← updated (locataire)
│   │   ├── assembleesController.js
│   │   ├── notificationsController.js
│   │   └── rapportsController.js
│   ├── middleware/
│   │   ├── auth.js              # JWT authenticate + authorize
│   │   └── errorHandler.js
│   ├── routes/                  # One file per resource
│   ├── services/
│   │   └── notificationService.js
│   ├── app.js
│   └── server.js
├── .env.example
├── .gitignore
├── package.json
└── README.md
```

---

## ⚙️ Setup

```bash
# 1. Install
npm install

# 2. Configure environment
cp .env.example .env
# → edit .env with your SQL Server credentials

# 3. Create DB in SSMS
# CREATE DATABASE SyndicDB;

# 4. Migrate + Seed
npm run setup

# 5. Start
npm run dev
```

---

## 👥 User Roles

| Role           | Description                                              |
|----------------|----------------------------------------------------------|
| `syndic`       | Manages buildings, charges, assemblies, reports          |
| `proprietaire` | Views own charges, payments, notifications               |
| `locataire`    | Views own charges, payments, notifications (tenant)      |

---

## 🔐 Authentication

All protected routes require:
```
Authorization: Bearer <jwt_token>
```

---

## 📋 API Endpoints

### Auth — `/api/auth`
| Method | Endpoint            | Access        | Description                        |
|--------|---------------------|---------------|------------------------------------|
| POST   | `/login`            | Public        | Login for all roles                |
| POST   | `/register`         | Syndic       | Create syndic/proprietaire/locataire |
| GET    | `/me`               | Any           | Current user + profile             |
| PUT    | `/change-password`  | Any           | Change own password                |

**Login:**
```json
{ "email": "syndic@syndic.com", "password": "Syndic@1234" }
```

**Register locataire:**
```json
{
  "email": "new@loc.com", "password": "Pass@123", "role": "locataire",
  "nom": "Dupont", "prenom": "Jean", "telephone": "+212600000099",
  "immeubleId": 1, "appartement": "D1",
  "proprietaireId": 1,
  "dateEntree": "2026-01-01"
}
```

---

### Immeubles — `/api/immeubles`
| Method | Endpoint  | Access | Description      |
|--------|-----------|--------|------------------|
| GET    | `/`       | Syndic | List buildings   |
| GET    | `/:id`    | Syndic | Building detail  |
| POST   | `/`       | Syndic | Create building  |
| PUT    | `/:id`    | Syndic | Update building  |
| DELETE | `/:id`    | Syndic | Delete building  |

---

### Propriétaires — `/api/proprietaires`
| Method | Endpoint        | Access        | Description          |
|--------|-----------------|---------------|----------------------|
| GET    | `/`             | Syndic        | List all owners      |
| GET    | `/profile/me`   | Propriétaire  | Own profile          |
| GET    | `/:id`          | Any           | Owner detail         |
| PUT    | `/:id`          | Syndic        | Update owner         |

---

### Locataires — `/api/locataires` ← NEW
| Method | Endpoint        | Access     | Description           |
|--------|-----------------|------------|-----------------------|
| GET    | `/`             | Syndic     | List all tenants      |
| GET    | `/profile/me`   | Locataire  | Own profile           |
| GET    | `/:id`          | Any        | Tenant detail         |
| PUT    | `/:id`          | Syndic     | Update tenant         |
| DELETE | `/:id`          | Syndic     | Delete tenant         |

---

### Charges — `/api/charges`
| Method | Endpoint                 | Access | Description                        |
|--------|--------------------------|--------|------------------------------------|
| GET    | `/`                      | Any    | List charges (filtered by role)    |
| GET    | `/:id`                   | Any    | Charge detail                      |
| POST   | `/`                      | Syndic | Create charge (requires `nom`)     |
| PUT    | `/:id`                   | Syndic | Update charge                      |
| DELETE | `/:id`                   | Syndic | Delete charge                      |
| GET    | `/impayes/dashboard`     | Syndic | Unpaid charges dashboard           |

**Create charge body:**
```json
{
  "immeubleId": 1,
  "nom": "Charges communes Avril 2026",
  "description": "Entretien ascenseur et parties communes",
  "montant": 950.00,
  "dateEcheance": "2026-04-30",
  "type": "charges_communes",
  "proprietaireId": 1
}
```

---

### Paiements — `/api/paiements`
| Method | Endpoint              | Access | Description                    |
|--------|-----------------------|--------|--------------------------------|
| GET    | `/`                   | Any    | List payments (filtered)       |
| POST   | `/`                   | Syndic | Record a payment               |
| GET    | `/suivi/:type/:id`    | Any    | Payment tracking (`type` = `proprietaire` or `locataire`) |

---

### Assemblées Générales — `/api/assemblees`
| Method | Endpoint  | Access | Description                                    |
|--------|-----------|--------|------------------------------------------------|
| GET    | `/`       | Any    | List assemblies                                |
| GET    | `/:id`    | Any    | Assembly detail                                |
| POST   | `/`       | Syndic | Plan assembly (auto-notifies proprietaires + locataires) |
| PUT    | `/:id`    | Syndic | Update assembly                                |
| DELETE | `/:id`    | Syndic | Delete assembly                                |

---

### Notifications — `/api/notifications`
| Method | Endpoint       | Access | Description                            |
|--------|----------------|--------|----------------------------------------|
| GET    | `/`            | Any    | Own notifications + unread count       |
| PUT    | `/:id/read`    | Any    | Mark one as read                       |
| PUT    | `/read-all`    | Any    | Mark all as read                       |
| POST   | `/send`        | Syndic | Broadcast to all owners of a building  |

---

### Rapports — `/api/rapports`
| Method | Endpoint      | Access | Description                    |
|--------|---------------|--------|--------------------------------|
| GET    | `/financier`  | Syndic | Full financial report          |
| GET    | `/impayes`    | Syndic | All unpaid charges report      |
| GET    | `/history`    | Syndic | Report generation history      |

---

## 🧪 Test Accounts (after `npm run seed`)

| Role          | Email                | Password     |
|---------------|----------------------|--------------|
| Syndic        | syndic@syndic.com    | Syndic@1234  |
| Propriétaire  | prop1@syndic.com     | Prop@1234    |
| Propriétaire  | prop2@syndic.com     | Prop@1234    |
| Propriétaire  | prop3@syndic.com     | Prop@1234    |
| Locataire     | loc1@syndic.com      | Loc@1234     |
| Locataire     | loc2@syndic.com      | Loc@1234     |

---

## 🗄️ Database Schema

```
Users ──────┬──── Syndics ──── Immeubles ──┬── Charges ──── Paiements
            ├──── Proprietaires ────────────┤
            └──── Locataires ───────────────┘
                       │
                       └── AssembleesGenerales
Users ─── Notifications
Syndics ─── Rapports
```

---

## 🔧 Environment Variables

| Variable                      | Description                      |
|-------------------------------|----------------------------------|
| `PORT`                        | Server port (default 3000)       |
| `DB_SERVER`                   | SQL Server hostname              |
| `DB_DATABASE`                 | Database name (SyndicDB)         |
| `DB_USER` / `DB_PASSWORD`     | SQL Server credentials           |
| `DB_TRUST_SERVER_CERTIFICATE` | `true` for local dev             |
| `JWT_SECRET`                  | JWT signing secret               |
| `JWT_EXPIRES_IN`              | Token lifetime (e.g. `7d`)      |
