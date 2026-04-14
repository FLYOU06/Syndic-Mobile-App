# 🏢 Syndic Management API — v4.0

**Node.js + Express + SQL Server**  
Complete backend for modernising a property management (syndic) application.

---

## ✅ Implemented Requirements

| # | Requirement | Status |
|---|---|---|
| 1 | No public registration — only syndic creates accounts | ✅ |
| 2 | Syndic adds habitants with auto-generated credentials + optional email | ✅ |
| 3 | Charge auto-assigned to all habitants in the building | ✅ |
| 4 | Per-charge calculations (total paid / unpaid / restant) | ✅ |
| 5 | Residents grouped by status (paid / partially_paid / unpaid) | ✅ |
| 6 | In-app + email notifications for unpaid and paid residents | ✅ |
| 7 | Clean, modular, scalable MVC architecture | ✅ |

---

## 🗂️ Project Structure

```
syndic-backend/
├── src/
│   ├── config/
│   │   ├── database.js          # SQL Server connection pool
│   │   ├── migrate.js           # Creates all tables
│   │   └── seed.js              # Sample data with mixed payment statuses
│   ├── controllers/
│   │   ├── authController.js           # login + change-password only
│   │   ├── habitantsController.js      # syndic-only creation, reset-password
│   │   ├── chargesController.js        # auto-assign + payment recording + notifications
│   │   ├── assembleesController.js
│   │   ├── notificationsController.js
│   │   └── rapportsController.js
│   ├── middleware/
│   │   ├── auth.js              # JWT authenticate + authorize
│   │   └── errorHandler.js
│   ├── routes/
│   ├── services/
│   │   ├── emailService.js      # credentials / reminders / confirmations
│   │   └── notificationService.js
│   ├── app.js
│   └── server.js
├── .env.example
├── package.json
└── README.md
```

---

## 🗄️ Database Schema

```
Users ─────┬──── Syndics ──── Immeubles ──── Charges
           │                                    │
           └──── Habitants ──────────────── ChargeHabitants
                  (type: proprietaire             (pivot: one row per
                        | locataire)               charge × habitant)

Habitants ──── Notifications
Immeubles ──── AssembleesGenerales
Syndics   ──── Rapports
```

### Key table: `ChargeHabitants` (pivot)

| Column        | Type          | Description                            |
|---------------|---------------|----------------------------------------|
| `chargeId`    | FK → Charges  | Which charge                           |
| `habitantId`  | FK → Habitants| Which resident                         |
| `montantDu`   | DECIMAL       | Amount owed by this resident           |
| `montantPaye` | DECIMAL       | Amount paid so far                     |
| `statut`      | NVARCHAR      | `unpaid` / `partially_paid` / `paid`   |
| `datePaiement`| DATETIME      | Last payment date                      |
| `modePaiement`| NVARCHAR      | especes / virement / cheque / carte    |
| `reference`   | NVARCHAR      | Payment reference                      |

---

## ⚙️ Setup

```bash
# 1. Install
npm install

# 2. Configure environment
cp .env.example .env
# → edit DB credentials, JWT secret, email settings

# 3. Create database in SSMS
#    CREATE DATABASE SyndicDB;

# 4. Migrate + seed
npm run setup

# 5. Start
npm run dev        # development (nodemon)
npm start          # production
```

---

## 👥 Roles

| Role           | Description                                               |
|----------------|-----------------------------------------------------------|
| `syndic`       | Manages everything: buildings, habitants, charges, reports |
| `proprietaire` | Views own charges, payments, notifications               |
| `locataire`    | Views own charges, payments, notifications               |

> ⚠️ **There is no public registration.** Only the syndic can create resident accounts via `POST /api/habitants`.

---

## 📋 API Reference

### Auth — `/api/auth`

| Method | Endpoint           | Access | Description           |
|--------|--------------------|--------|-----------------------|
| POST   | `/login`           | Public | Login for all roles   |
| GET    | `/me`              | Any    | Current user + profile|
| PUT    | `/change-password` | Any    | Change own password   |

**Login:**
```json
{ "email": "syndic@syndic.com", "password": "Syndic@1234" }
```

---

### Habitants — `/api/habitants`

> Only the syndic can create habitants. No public registration.

| Method | Endpoint                 | Access                   | Description                          |
|--------|--------------------------|--------------------------|--------------------------------------|
| POST   | `/`                      | Syndic                   | Create resident + generate credentials |
| GET    | `/`                      | Syndic                   | List all (filter: `?type=locataire`) |
| GET    | `/profile/me`            | Proprietaire / Locataire | Own profile                          |
| GET    | `/:id`                   | Any                      | Resident detail                      |
| PUT    | `/:id`                   | Syndic                   | Update resident info                 |
| DELETE | `/:id`                   | Syndic                   | Delete resident                      |
| PUT    | `/:id/reset-password`    | Syndic                   | Reset password + optional email      |

**Create habitant (req body):**
```json
{
  "email": "newresident@example.com",
  "password": "optional_custom_pass",
  "type": "proprietaire",
  "nom": "Alaoui",
  "prenom": "Mehdi",
  "telephone": "+212600000099",
  "immeubleId": 1,
  "appartement": "D3",
  "sendEmail": true
}
```
**Response includes generated credentials:**
```json
{
  "success": true,
  "message": "Habitant created. Credentials sent by email.",
  "data": { ... },
  "credentials": { "email": "newresident@example.com", "password": "Xk3$mP9@nQ" }
}
```

---

### Charges — `/api/charges`

> When a charge is created, it is **automatically assigned to every habitant** in the building. Each gets their own `ChargeHabitants` row with `statut = unpaid`.

| Method | Endpoint                 | Access | Description                                        |
|--------|--------------------------|--------|----------------------------------------------------|
| POST   | `/`                      | Syndic | Create charge → auto-assign to all habitants       |
| GET    | `/`                      | Any    | List charges (habitants see only their own)        |
| GET    | `/:id`                   | Any    | **Full detail: summary + per-resident breakdown**  |
| PUT    | `/:id`                   | Syndic | Update charge details                              |
| DELETE | `/:id`                   | Syndic | Delete charge                                      |
| POST   | `/:id/paiement`          | Syndic | Record payment for a specific resident             |
| POST   | `/:id/notify-unpaid`     | Syndic | Notify all unpaid/partial residents (in-app+email) |
| GET    | `/impayes/dashboard`     | Syndic | Summary per building                               |

**Create charge:**
```json
{
  "immeubleId": 1,
  "nom": "Charges communes Mai 2026",
  "description": "Entretien ascenseur",
  "montantTotal": 5000.00,
  "dateEcheance": "2026-05-31",
  "type": "charges_communes"
}
```

**GET `/api/charges/:id` response:**
```json
{
  "charge": { "id": 1, "nom": "Charges communes...", "montantTotal": 5000 },
  "summary": {
    "totalHabitants": 5,
    "paid": 1,
    "partiallyPaid": 1,
    "unpaid": 3,
    "totalMontantDu": 5000,
    "totalMontantPercu": 1500,
    "totalMontantRestant": 3500
  },
  "byStatus": {
    "paid":          [ { "habitantNom": "Benali", ... } ],
    "partiallyPaid": [ { "habitantNom": "Fassi",  ... } ],
    "unpaid":        [ { "habitantNom": "Idrissi",...  }, ... ]
  },
  "rows": [ ... ]
}
```

**Record a payment:**
```json
{
  "habitantId": 2,
  "montantPaye": 500.00,
  "modePaiement": "virement",
  "reference": "VIR-2026-04-001"
}
```

---

### Assemblées — `/api/assemblees`

| Method | Endpoint  | Access | Description                             |
|--------|-----------|--------|-----------------------------------------|
| GET    | `/`       | Any    | List (filtered by role)                 |
| GET    | `/:id`    | Any    | Detail                                  |
| POST   | `/`       | Syndic | Create + notify all habitants           |
| PUT    | `/:id`    | Syndic | Update                                  |
| DELETE | `/:id`    | Syndic | Delete                                  |

---

### Notifications — `/api/notifications`

| Method | Endpoint       | Access | Description              |
|--------|----------------|--------|--------------------------|
| GET    | `/`            | Any    | Own list + unread count  |
| PUT    | `/:id/read`    | Any    | Mark one read            |
| PUT    | `/read-all`    | Any    | Mark all read            |
| POST   | `/send`        | Syndic | Broadcast to a building  |

---

### Rapports — `/api/rapports`

| Method | Endpoint      | Access | Description                        |
|--------|---------------|--------|------------------------------------|
| GET    | `/financier`  | Syndic | Financial report (paid/unpaid/etc) |
| GET    | `/impayes`    | Syndic | List of all unpaid rows            |

**Query params:** `?immeubleId=1&dateDebut=2026-01-01&dateFin=2026-12-31`

---

### Immeubles — `/api/immeubles`

| Method | Endpoint  | Access | Description |
|--------|-----------|--------|-------------|
| GET    | `/`       | Syndic | List        |
| GET    | `/:id`    | Syndic | Detail      |
| POST   | `/`       | Syndic | Create      |
| PUT    | `/:id`    | Syndic | Update      |
| DELETE | `/:id`    | Syndic | Delete      |

---

## 🧪 Test Accounts (after `npm run seed`)

| Role          | Email               | Password    | Charge Status  |
|---------------|---------------------|-------------|----------------|
| Syndic        | syndic@syndic.com   | Syndic@1234 | —              |
| Propriétaire  | prop1@syndic.com    | Prop@1234   | paid ✅        |
| Propriétaire  | prop2@syndic.com    | Prop@1234   | partially_paid ⚡|
| Propriétaire  | prop3@syndic.com    | Prop@1234   | unpaid ❌      |
| Locataire     | loc1@syndic.com     | Loc@1234    | unpaid ❌      |
| Locataire     | loc2@syndic.com     | Loc@1234    | unpaid ❌      |

---

## 📧 Email Configuration

Email is **optional**. If `EMAIL_USER` is not set in `.env`, emails are silently skipped and a console log is printed instead.

When configured, the system sends:
- **Credentials email** — when syndic creates a new habitant with `"sendEmail": true`
- **Payment reminder** — when syndic calls `POST /api/charges/:id/notify-unpaid`
- **Payment confirmation** — automatically when a payment reaches `paid` status

---

## 🔧 Environment Variables

| Variable                      | Required | Description                        |
|-------------------------------|----------|------------------------------------|
| `PORT`                        | No       | Server port (default: 3000)        |
| `DB_SERVER`                   | Yes      | SQL Server host                    |
| `DB_DATABASE`                 | Yes      | Database name                      |
| `DB_USER` / `DB_PASSWORD`     | Yes      | SQL Server credentials             |
| `DB_TRUST_SERVER_CERTIFICATE` | Yes      | `true` for local dev               |
| `JWT_SECRET`                  | Yes      | Secret key for JWT signing         |
| `JWT_EXPIRES_IN`              | No       | Token lifetime (default: `7d`)    |
| `EMAIL_USER` / `EMAIL_PASS`   | No       | SMTP credentials (skip if absent)  |
