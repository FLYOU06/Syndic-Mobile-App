# Syndic-Mobile-App
A mobile application for managing condominiums. Replaces the old Microsoft Access system, providing secure, real-time access to property data from any mobile device. Allows practical and efficient management of condominium information on the go.
#Base de donnée
Ce schéma de base de données est conçu pour gérer un système de copropriété (Syndic). Il prend en charge l'authentification des utilisateurs, les informations des copropriétaires, la gestion des biens immobiliers et le suivi financier (dettes théoriques vs paiements réels).

1. Schéma de la Base et Responsabilités des Tables
Voici le détail de chaque table et de son "rôle" spécifique au sein du système.

👤 Table : utilisateurs
Dépendance : Aucune (Table racine)

Description : Il s'agit de la couche de sécurité et d'authentification du système.

Son Rôle :

Authentification : Stocke les identifiants de connexion de manière sécurisée (emails et hachage des mots de passe).

Autorisation : Définit le niveau d'accès via la colonne role ('Admin' ou 'Coproprietaire').

Intégrité du Système : Garantit que chaque utilisateur possède une adresse email unique.

📇 Table : coproprietaires
Dépendance : utilisateurs

Description : Représente l'identité des personnes physiques qui possèdent les appartements.

Son Rôle :

Gestion de Profil : Stocke les informations de contact (Nom, Prénom, Téléphone, Email de contact).

Liaison de Compte : Relie une personne physique à un compte système (id_user).

Préservation des Données : Si un compte "Utilisateur" est supprimé, la fiche "Copropriétaire" reste (le lien devient NULL) pour conserver l'historique de propriété du bien.

🏢 Table : biens
Dépendance : coproprietaires

Description : Représente les unités physiques (appartements) au sein des immeubles.

Son Rôle :

Inventaire : Localise le bien (immeuble, etage, num_appt) et suit son statut (etat_bien).

Définition Financière : Définit la Base de Cotisation (frais annuels) et la Date de Signature, qui servent à calculer combien ce bien doit au syndic au fil du temps.

Propriété : Relie une unité spécifique à un copropriétaire spécifique.

💳 Table : paiements
Dépendance : biens

Description : Le grand livre de toutes les transactions financières entrant dans le système.

Son Rôle :

Journal des Transactions : Enregistre la date, le montant et le moyen (Espèce, Virement, Chèque) de chaque versement.

Trace d'Audit : Stocke les références de transaction pour vérification.

Maintenance : Si un bien est supprimé de la base, tout l'historique des paiements associé est automatiquement supprimé (ON DELETE CASCADE) pour éviter des données financières orphelines.

2. Rapport Financier
📊 Vue : vue_situation_financiere
Description : Il s'agit d'un rapport dynamique qui calcule la santé financière en temps réel de chaque bien. Il combine les données des biens, des propriétaires et des paiements.

Son Rôle (Logique de calcul) :

Identifie le Débiteur : Affiche l'Immeuble, le Numéro d'Appartement et le Nom du Propriétaire.

Calcule la Dette Totale (Total_Theorique_Du) :

Formule : (Années écoulées depuis signature + 1) * Cotisation Annuelle

Logique : Calcule le nombre d'années écoulées depuis l'achat du bien et le multiplie par le tarif de base.

Calcule le Total Payé (Total_Paye) :

Fait la somme de tous les enregistrements de la table paiements pour ce bien spécifique.

Détermine le Solde (Solde_Impaye) :

Formule : Total Dû - Total Payé

Résultat Positif = Le propriétaire a une dette.

Résultat Zéro ou Négatif = Le propriétaire est à jour ou a payé en avance.

3. Rôles Système (Les "Jobs" humains)
Basé sur les contraintes de la table utilisateurs, le système supporte deux types d'acteurs :

Admin (Syndic/Gérant) :

Responsabilités : Gère la base de données, saisit les nouveaux biens, enregistre les paiements reçus et relance les impayés en se basant sur la vue financière.

Coproprietaire :

Responsabilités : L'utilisateur final qui possède l'appartement. Il se connecte probablement pour consulter sa situation financière personnelle et son historique de paiements.
Table,Type de Contrainte,Objectif
utilisateurs,UNIQUE (email),Empêche la création de comptes en double.
coproprietaires,ON DELETE SET NULL,Conserve les infos du propriétaire même si son compte de connexion est supprimé.
biens,CHECK (etat_bien),"Assure que le statut est uniquement 'Vendu', 'Non vendu' ou 'Loué'."
paiements,ON DELETE CASCADE,Supprime l'historique de paiement si le Bien immobilier est supprimé.
