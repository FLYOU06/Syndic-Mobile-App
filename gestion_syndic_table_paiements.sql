CREATE TABLE [paiements] (
    [id_paiement] INT IDENTITY(1,1) NOT NULL,
    [id_bien] INT NOT NULL,
    [date_versement] DATE NOT NULL,
    [montant_verse] DECIMAL(10,2) NOT NULL,
    [moyen_paiement] VARCHAR(20) NULL,
    [reference_trans] VARCHAR(100) NULL,

    CONSTRAINT [PK_paiements] PRIMARY KEY CLUSTERED ([id_paiement]),
    CONSTRAINT [CK_moyen_paiement] CHECK ([moyen_paiement] IN ('Espèce', 'Virement', 'Chèque')),
    CONSTRAINT [FK_paiement_bien] FOREIGN KEY ([id_bien]) 
        REFERENCES [biens] ([id_bien]) ON DELETE CASCADE
);