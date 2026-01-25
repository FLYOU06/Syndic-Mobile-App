CREATE TABLE [utilisateurs] (
    [id_user] INT IDENTITY(1,1) NOT NULL,
    [email] VARCHAR(100) NOT NULL,
    [password_hash] VARCHAR(255) NOT NULL,
    [role] VARCHAR(20) DEFAULT 'Coproprietaire',
    [date_inscription] DATETIME DEFAULT GETDATE() NOT NULL,
    
    CONSTRAINT [PK_utilisateurs] PRIMARY KEY CLUSTERED ([id_user]),
    CONSTRAINT [UQ_utilisateurs_email] UNIQUE ([email]),
    CONSTRAINT [CK_utilisateurs_role] CHECK ([role] IN ('Admin', 'Coproprietaire'))
);