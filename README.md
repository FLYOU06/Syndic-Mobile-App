# 🏢 Syndic Management API — v3.0

Backend REST API — **Node.js + Express + SQL Server**  
CDC: Modernisation application de gestion de syndic (EST Safi / ISWY Consulting)

---

## 🗂️ Project Structure

```
syndic-backend/
├── src/
│   ├── config/
│   │   ├── database.js           # SQL Server connection pool
│   │   ├── migrate.js            # Creates all tables
│   │   └── seed.js               # Sample data
│   ├── controllers/
│   │   ├── authController.js
│   │   ├── immeublesController.js
│   │   ├── habitantsController.js   ← Proprietaires + Locataires merged
│   │   ├── chargesController.js     ← Notifies ALL habitants on create
│   │   ├── paiementsController.js
│   │   ├── assembleesController.js
│   │   ├── notificationsController.js
│   │   └── rapportsController.js
│   ├── middleware/
│   │   ├── auth.js
│   │   └── errorHandler.js
│   ├── routes/
│   ├── services/
│   │   └── notificationService.js
│   ├── app.js
│   └── server.js
├── .env.example
├── package.json
└── README.md
```

---

## ⚙️ Setup

```bash
npm install
cp .env.example .env       # configure DB credentials
# CREATE DATABASE SyndicDB; in SSMS
npm run setup              # migrate + seed
npm run dev
```

---

## 🗄️ Database Schema

```
Users ─────┬──── Syndics ──── Immeubles ──── Charges ──── Paiements
           └──── Habitants (type: proprietaire | locataire)
                    └── self-ref: locataire.proprietaireId → Habitants.id

Immeubles ──── AssembleesGenerales
Users ──── Notifications
Syndics ──── Rapports
```

### Key design decision — `Habitants` table
`Proprietaires` and `Locataires` are merged into a single `Habitants` table with a `type` column:

| Column          | Description                                      |
|-----------------|--------------------------------------------------|
| `type`          | `'proprietaire'` or `'locataire'`                |
| `immeubleId`    | The building they belong to                      |
| `appartement`   | Their apartment number                           |
| `proprietaireId`| (locataire only) FK → another Habitants row      |
| `dateEntree`    | (locataire only) start date                      |
| `dateSortie`    | (locataire only) end date                        |

---

## 👥 User Roles

| Role           | Description                                                |
|----------------|------------------------------------------------------------|
| `syndic`       | Manages buildings, habitants, charges, assemblies, reports |
| `proprietaire` | Views own charges, payments, notifications                 |
| `locataire`    | Views own charges, payments, notifications                 |

---

## 🔔 Charge Notification Logic

When a syndic creates a charge via `POST /api/charges`:
1. The charge is saved to the database
2. **ALL habitants (`proprietaires` + `locataires`) in the same `immeubleId`** are automatically notified
3. Each notification appears in their `/api/notifications` feed

---

## 📋 API Endpoints

### Auth — `/api/auth`
| Method | Endpoint           | Access  | Description                          |
|--------|--------------------|---------|--------------------------------------|
| POST   | `/login`           | Public  | Login for all roles                  |
| POST   | `/register`        | Syndic  | Create syndic / proprietaire / locataire |
| GET    | `/me`              | Any     | Current user + profile               |
| PUT    | `/change-password` | Any     | Change own password                  |

**Register habitant example:**
```json
{
  "email": "newprop@syndic.com",
  "password": "Pass@123",
  "role": "proprietaire",
  "nom": "Alaoui", "prenom": "Mehdi",
  "telephone": "+212600000010",
  "immeubleId": 1,
  "appartement": "D1"
}
```

**Register locataire example:**
```json
{
  "email": "newloc@syndic.com",
  "password": "Pass@123",
  "role": "locataire",
  "nom": "Raji", "prenom": "Salma",
  "immeubleId": 1,
  "appartement": "D1",
  "proprietaireId": 2,
  "dateEntree": "2026-01-01"
}
```

---

### Immeubles — `/api/immeubles`
| Method | Endpoint  | Access | Description     |
|--------|-----------|--------|-----------------|
| GET    | `/`       | Syndic | List buildings  |
| GET    | `/:id`    | Syndic | Detail          |
| POST   | `/`       | Syndic | Create          |
| PUT    | `/:id`    | Syndic | Update          |
| DELETE | `/:id`    | Syndic | Delete          |

---

### Habitants — `/api/habitants`
| Method | Endpoint        | Access                    | Description                         |
|--------|-----------------|---------------------------|-------------------------------------|
| GET    | `/`             | Syndic                    | List all (filter: `?type=locataire`)|
| GET    | `/profile/me`   | Propriétaire / Locataire  | Own profile                         |
| GET    | `/:id`          | Any                       | Detail                              |
| PUT    | `/:id`          | Syndic                    | Update                              |
| DELETE | `/:id`          | Syndic                    | Delete                              |

---

### Charges — `/api/charges`
| Method | Endpoint              | Access | Description                                         |
|--------|-----------------------|--------|-----------------------------------------------------|
| GET    | `/`                   | Any    | List (filtered by role automatically)              |
| GET    | `/:id`                | Any    | Detail                                              |
| POST   | `/`                   | Syndic | Create + **auto-notify all habitants in immeuble** |
| PUT    | `/:id`                | Syndic | Update                                              |
| DELETE | `/:id`                | Syndic | Delete                                              |
| GET    | `/impayes/dashboard`  | Syndic | Unpaid charges summary                             |

**Create charge body:**
```json
{
  "immeubleId": 1,
  "nom": "Charges communes Mai 2026",
  "description": "Entretien ascenseur et parties communes",
  "montant": 950.00,
  "dateEcheance": "2026-05-31",
  "type": "charges_communes",
  "habitantId": 2
}
```

---

### Paiements — `/api/paiements`
| Method | Endpoint              | Access | Description              |
|--------|-----------------------|--------|--------------------------|
| GET    | `/`                   | Any    | List payments            |
| POST   | `/`                   | Syndic | Record a payment         |
| GET    | `/suivi/:habitantId`  | Any    | Payment history          |

---

### Assemblées Générales — `/api/assemblees`
| Method | Endpoint  | Access | Description                                  |
|--------|-----------|--------|----------------------------------------------|
| GET    | `/`       | Any    | List                                         |
| GET    | `/:id`    | Any    | Detail                                       |
| POST   | `/`       | Syndic | Plan + notify all habitants                  |
| PUT    | `/:id`    | Syndic | Update                                       |
| DELETE | `/:id`    | Syndic | Delete                                       |

---

### Notifications — `/api/notifications`
| Method | Endpoint       | Access | Description              |
|--------|----------------|--------|--------------------------|
| GET    | `/`            | Any    | Own list + unread count  |
| PUT    | `/:id/read`    | Any    | Mark one read            |
| PUT    | `/read-all`    | Any    | Mark all read            |
| POST   | `/send`        | Syndic | Broadcast to building    |

---

### Rapports — `/api/rapports`
| Method | Endpoint      | Access | Description            |
|--------|---------------|--------|------------------------|
| GET    | `/financier`  | Syndic | Financial report       |
| GET    | `/impayes`    | Syndic | Unpaid charges report  |
| GET    | `/history`    | Syndic | Report history         |

---

## 🧪 Test Accounts

| Role          | Email                 | Password    |
|---------------|-----------------------|-------------|
| Syndic        | syndic@syndic.com     | Syndic@1234 |
| Propriétaire  | prop1@syndic.com      | Prop@1234   |
| Propriétaire  | prop2@syndic.com      | Prop@1234   |
| Propriétaire  | prop3@syndic.com      | Prop@1234   |
| Locataire     | loc1@syndic.com       | Loc@1234    |
| Locataire     | loc2@syndic.com       | Loc@1234    |
