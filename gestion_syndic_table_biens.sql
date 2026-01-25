CREATE TABLE [biens] (
    [id_bien] INT IDENTITY(1,1) NOT NULL,
    [immeuble] VARCHAR(10) NOT NULL,
    [etage] INT NULL,
    [num_appt] VARCHAR(10) NOT NULL,
    [etat_bien] VARCHAR(20) DEFAULT 'Vendu',
    [date_signature] DATE NULL,
    [base_cotisation] DECIMAL(10,2) DEFAULT 4500.00,
    [id_copro] INT NULL,

    CONSTRAINT [PK_biens] PRIMARY KEY CLUSTERED ([id_bien]),
    CONSTRAINT [CK_etat_bien] CHECK ([etat_bien] IN ('Vendu', 'Non vendu', 'Loué')),
    CONSTRAINT [FK_bien_copro] FOREIGN KEY ([id_copro]) 
        REFERENCES [coproprietaires] ([id_copro]) ON DELETE SET NULL
);