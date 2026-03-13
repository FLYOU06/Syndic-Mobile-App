📱 SyndiControl – Front-End Mobile (Flutter)
👨‍💻 Développeur Front-End

Jihad Chakir

📌 Description

SyndiControl est une application mobile développée avec Flutter permettant la gestion moderne d’une copropriété (syndic).

Cette partie du projet concerne exclusivement le Front-End mobile, incluant :

Conception UI/UX

Gestion des écrans

Navigation

Gestion d’état

Intégration avec l’API backend

L’objectif est d’offrir une interface intuitive, moderne et responsive pour la gestion des habitants et des charges.

🚀 Fonctionnalités Implémentées (Front-End)
📊 1️⃣ Dashboard

Le tableau de bord affiche :

🔴 Montant total des charges impayées

📈 Variation mensuelle

👥 Nombre total d’habitants

📅 Prochaine assemblée générale

📊 Aperçu graphique des charges impayées

⚡ Actions rapides :

Gérer les habitants

Générer des rapports

Planifier une assemblée

Diffusion

Le dashboard centralise les informations importantes de la résidence.

👥 2️⃣ Gestion des Habitants
✅ Fonctionnalités :

Affichage de la liste des habitants

Recherche d’un habitant

Séparation en deux catégories :

🏠 Propriétaires

🏢 Locataires

Ajout d’un habitant

Modification d’un habitant

Suppression d’un habitant

Consultation des détails

Chaque habitant contient :

Nom

Prénom

Immeuble

Appartement

Téléphone

Email

Rôle (Propriétaire / Locataire)

💰 3️⃣ Gestion des Charges
📌 Affichage des charges :

Montant total des charges

Montant des charges impayées

Liste des charges :

💧 Eau

⚡ Électricité

🌿 Jardinier

🛠 Entretien

📊 Statut des charges :

🟢 Soldée

🟡 Partiellement payée

🔴 Impayée

🔍 4️⃣ Détail d’une Charge

Lorsqu’on clique sur “Voir détail”, on peut voir :

Description de la charge

Montant total

Statut

Liste des habitants ayant payé

Liste des habitants n’ayant pas payé

Calcul dynamique du montant restant

🛠️ Technologies Utilisées

Flutter

Dart

HTTP (API REST)

SharedPreferences (stockage token)

Intl (formatage des dates)

Architecture modulaire (screens / services)