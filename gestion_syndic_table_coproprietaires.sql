CREATE TABLE [coproprietaires] (
    [id_copro] INT IDENTITY(1,1) NOT NULL,
    [nom_prenom] VARCHAR(150) NOT NULL,
    [telephone] VARCHAR(25) NULL,
    [email_contact] VARCHAR(100) NULL,
    [id_user] INT NULL,

    CONSTRAINT [PK_coproprietaires] PRIMARY KEY CLUSTERED ([id_copro]),
    CONSTRAINT [UQ_coproprietaires_id_user] UNIQUE ([id_user]),
    CONSTRAINT [FK_user_copro] FOREIGN KEY ([id_user]) 
        REFERENCES [utilisateurs] ([id_user]) ON DELETE SET NULL
);  