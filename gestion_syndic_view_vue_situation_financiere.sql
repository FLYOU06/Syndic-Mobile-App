CREATE VIEW [dbo].[vue_situation_financiere] 
AS 
SELECT 
    b.immeuble, 
    b.num_appt, 
    c.nom_prenom AS Proprietaire, 
    b.base_cotisation AS Tarif_Annuel, 
    
    -- Calcul du montant théorique dû : (Années écoulées depuis signature + 1) * cotisation
    (DATEDIFF(YEAR, b.date_signature, GETDATE()) + 1) * b.base_cotisation AS Total_Theorique_Du, 
    
    -- Somme des paiements (ISNULL remplace IFNULL)
    ISNULL(SUM(p.montant_verse), 0) AS Total_Paye, 
    
    -- Calcul du solde (Dû - Payé)
    ((DATEDIFF(YEAR, b.date_signature, GETDATE()) + 1) * b.base_cotisation) - ISNULL(SUM(p.montant_verse), 0) AS Solde_Impaye 

FROM 
    biens b 
    LEFT JOIN coproprietaires c ON b.id_copro = c.id_copro 
    LEFT JOIN paiements p ON b.id_bien = p.id_bien 

GROUP BY 
    b.id_bien, 
    b.immeuble, 
    b.num_appt, 
    c.nom_prenom, 
    b.base_cotisation, 
    b.date_signature;