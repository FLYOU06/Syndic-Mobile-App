# 📱 SyndiControl – Front-End Mobile (Flutter)

## 👨‍💻 Développeur Front-End
**Jihad Chakir**

---

# 📌 Description

**SyndiControl** est une application mobile développée avec **Flutter** permettant la gestion moderne d’une copropriété (syndic).

Cette partie du projet concerne exclusivement le **Front-End mobile**, incluant :

- Conception **UI/UX**
- Gestion des **écrans**
- **Navigation**
- **Gestion d’état**
- **Intégration avec l’API backend**

L’objectif est d’offrir une **interface intuitive, moderne et responsive** pour faciliter la gestion des habitants et des charges dans une résidence.

---

# 🚀 Fonctionnalités Implémentées (Front-End)

---

# 📊 1️⃣ Dashboard

Le **tableau de bord** affiche :

- 🔴 Montant total des **charges impayées**
- 📈 **Variation mensuelle**
- 👥 Nombre total **d’habitants**
- 📅 **Prochaine assemblée générale**
- 📊 Aperçu **graphique des charges impayées**

### ⚡ Actions rapides :

- Gérer les habitants
- Voir Charges
- Planifier une assemblée
- Parammètres

Le dashboard centralise les **informations importantes de la résidence** pour une vision rapide de la situation.

---

# 👥 2️⃣ Gestion des Habitants

## ✅ Fonctionnalités

- Affichage de la **liste des habitants**
- **Recherche** d’un habitant
- Séparation en deux catégories :
  - 🏠 **Propriétaires**
  - 🏢 **Locataires**
- **Ajout** d’un habitant
- **Modification** d’un habitant
- **Suppression** d’un habitant
- **Consultation des détails**

### 📌 Chaque habitant contient :

- Nom
- Prénom
- Immeuble
- Appartement
- Téléphone
- Email
- Rôle (**Propriétaire / Locataire**)

Cette section permet au syndic de **gérer facilement les résidents de la copropriété**.

---

# 💰 3️⃣ Gestion des Charges

## 📌 Affichage des charges

- Montant **total des charges**
- Montant **des charges impayées**

### Liste des charges :

- 💧 Eau
- ⚡ Électricité
- 🌿 Jardinier
- 🛠 Entretien

## 📊 Statut des charges

- 🟢 **Soldée**
- 🟡 **Partiellement payée**
- 🔴 **Impayée**

Cette fonctionnalité permet de **suivre l’état financier de la copropriété**.

---

# 🔍 4️⃣ Détail d’une Charge

Lorsqu’on clique sur **“Voir détail”**, on peut consulter :

- Description de la charge
- Montant total
- Statut
- Liste des habitants **ayant payé**
- Liste des habitants **n’ayant pas payé**
- Calcul dynamique du **montant restant**

Cela permet d’avoir une **vision précise du paiement des charges par habitant**.

---

# 🏛 5️⃣ Gestion de l’Assemblée Générale

Cette section permet de gérer tout le cycle de vie d’une assemblée générale, avant, pendant et après la réunion, à travers une interface moderne sous forme de timeline interactive.

## Informations principales

### Chaque assemblée affiche :

📅 Date et heure
📍 Lieu de la réunion
📌 Carte récapitulative de la prochaine assemblée générale
🔘 Accès rapide à la convocation
🧭 Workflow de l’Assemblée (Interface par étapes)

L’application guide l’utilisateur à travers un processus structuré :

🔹### AVANT L’ASSEMBLÉE

1️⃣ Fixation de la date et du lieu

Définir les informations principales de la réunion

2️⃣ Préparation de l’ordre du jour

Ajouter les points à discuter
Organiser les résolutions

3️⃣ Envoi des convocations

Envoyer les invitations aux copropriétaires
🔸 ### APRÈS L’ASSEMBLÉE

4️⃣ Enregistrement des présences

Marquer les présents / absents
Calcul automatique du quorum

5️⃣ Rédaction du procès-verbal (PV)

Résumé des discussions
Résultats des votes

# 🛠 Technologies Utilisées

- **Flutter**
- **Dart**
- **HTTP (API REST)**
- **SharedPreferences** (stockage token)
- **Intl** (formatage des dates)

---

# 📂 Architecture Front-End

```text
lib/
 ├── main.dart
 ├── screens/
 │    ├── login_screen.dart
 │    ├── signup_screen.dart
 │    ├── dashboard_screen.dart
 │    ├── assembly_dashboard_screen.dart
 │    ├── habitants_screen.dart
 │    ├── habitant_details_screen.dart
 │    ├── add_habitant_screen.dart
 │    ├── edit_habitant_screen.dart
 │    ├── charges.dart
 │    ├── add_charge_screen.dart
 │    ├── detail_charge_screen.dart
 │    ├── notifications_screen.dart
 │    └── paramètres.dart
 └── services/
      ├── api_service.dart
      ├── auth_service.dart
      └── token_storage.dart
