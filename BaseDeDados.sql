USE master;
GO

-- Fecha conexões e apaga BD antiga
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'SurpresasExistemEntrega')
BEGIN
    ALTER DATABASE SurpresasExistemEntrega SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE SurpresasExistemEntrega;
END
GO

CREATE DATABASE SurpresasExistemEntrega;
GO
USE SurpresasExistemEntrega;
GO

DROP TABLE IF EXISTS Auditoria;
DROP TABLE IF EXISTS RiscoCliente;
DROP TABLE IF EXISTS Sinistro;
DROP TABLE IF EXISTS Cobertura;
DROP TABLE IF EXISTS Premio;
DROP TABLE IF EXISTS Pagamento;
DROP TABLE IF EXISTS EntidadeApolice;
DROP TABLE IF EXISTS Apolice;
DROP TABLE IF EXISTS Carteira;
DROP TABLE IF EXISTS Produto;
DROP TABLE IF EXISTS SeguradoraMediador;
DROP TABLE IF EXISTS Entidade;
DROP TABLE IF EXISTS Carteira;
DROP TABLE IF EXISTS Mediador;
DROP TABLE IF EXISTS Seguradora;
DROP TABLE IF EXISTS TipoSeguro;
GO


CREATE TABLE TipoSeguro (
    TipoSeguroID INT IDENTITY(1,1) PRIMARY KEY,
    Descricao VARCHAR(20) NOT NULL CHECK (Descricao IN ('Vida','Casa','Carro','Saúde')),
    Estado VARCHAR(10) DEFAULT 'Ativo' CHECK (Estado IN ('Ativo','Inativo'))
);
GO

CREATE TABLE Mediador (
    MediadorID INT IDENTITY(1,1) PRIMARY KEY,
    Nome VARCHAR(40) NOT NULL,
    Contacto VARCHAR(9) UNIQUE NOT NULL,
    NIF VARCHAR(9) UNIQUE NOT NULL,
    Estado VARCHAR(10) NOT NULL CHECK (Estado IN ('Ativo','Inativo'))
);
GO

CREATE TABLE Seguradora (
    SeguradoraID INT IDENTITY(1,1) PRIMARY KEY,
    Nome VARCHAR(40) NOT NULL,
    Contacto VARCHAR(9) UNIQUE NOT NULL,
    Morada VARCHAR(100) NOT NULL,
    NIF VARCHAR(9) UNIQUE NOT NULL,
    Estado VARCHAR(10) NOT NULL CHECK (Estado IN ('Ativo','Inativo')) 
);
GO

CREATE TABLE Entidade (
    EntidadeID INT IDENTITY(1,1) PRIMARY KEY,
    Nome VARCHAR(40) NOT NULL,
    DataNascimento DATE NULL,
    Contacto VARCHAR(9) UNIQUE NOT NULL,
    Morada VARCHAR(100) NOT NULL,
    NIF VARCHAR(9) UNIQUE NOT NULL,
    Estado VARCHAR(10) DEFAULT 'Ativo' CHECK (Estado IN ('Ativo','Inativo'))
);
GO


CREATE TABLE SeguradoraMediador (
    MediadorID INT NOT NULL,
    SeguradoraID INT NOT NULL,
    PRIMARY KEY (MediadorID, SeguradoraID),
    FOREIGN KEY (MediadorID) REFERENCES Mediador(MediadorID),
    FOREIGN KEY (SeguradoraID) REFERENCES Seguradora(SeguradoraID)
);
GO

CREATE TABLE Produto (
    ProdutoID INT IDENTITY(1,1) PRIMARY KEY,
    TipoSeguroID INT NOT NULL,
    SeguradoraID INT NOT NULL,
    Nome VARCHAR(30) NOT NULL,
    Descricao VARCHAR(150),
    DataInicio DATE NOT NULL,
    DataFim DATE NULL,
    Estado VARCHAR(10) DEFAULT 'Ativo' CHECK (Estado IN ('Ativo','Inativo')),
    CONSTRAINT CK_Produto_Nome CHECK (
        TipoSeguroID=1 AND Nome IN ('Invalidez','Morte') OR
        TipoSeguroID=2 AND Nome IN ('Incêndio','Roubo') OR
        TipoSeguroID=3 AND Nome IN ('Acidente','Danos') OR
        TipoSeguroID=4 AND Nome IN ('Internamento','Consultas')
    ),
    FOREIGN KEY (TipoSeguroID) REFERENCES TipoSeguro(TipoSeguroID),
    FOREIGN KEY (SeguradoraID) REFERENCES Seguradora(SeguradoraID)
);
GO

CREATE TABLE Carteira (
    CarteiraID INT IDENTITY(1,1) PRIMARY KEY,
    MediadorID INT NOT NULL,
    Estado VARCHAR(10) DEFAULT 'Ativo' CHECK (Estado IN ('Ativo','Inativo')),
    FOREIGN KEY (MediadorID) REFERENCES Mediador(MediadorID)
);
GO


CREATE TABLE Apolice (
    ApoliceID INT IDENTITY(1,1) PRIMARY KEY,
    ProdutoID INT NOT NULL,
    CarteiraID INT NOT NULL,
    NumeroApolice VARCHAR(20) UNIQUE NOT NULL,
    DataInicio DATE NOT NULL,
    DataFim DATE NULL,
    Estado VARCHAR(10) DEFAULT 'Ativo' CHECK (Estado IN ('Ativo','Inativo')),  
    FOREIGN KEY (ProdutoID) REFERENCES Produto(ProdutoID),
    FOREIGN KEY (CarteiraID) REFERENCES Carteira(CarteiraID)
);
GO

CREATE TABLE Pagamento (
    PagamentoID INT IDENTITY PRIMARY KEY,
    ApoliceID INT NOT NULL,
    DataPagamento DATE NOT NULL,
    Valor DECIMAL(10,2) CHECK (Valor > 0),
    Estado VARCHAR(15) CHECK (Estado IN ('Pago','EmDivida')),
    FOREIGN KEY (ApoliceID) REFERENCES Apolice(ApoliceID)
);
GO

CREATE TABLE EntidadeApolice (
    ApoliceID INT NOT NULL,
    EntidadeID INT NOT NULL,
    Papel VARCHAR(20) NOT NULL CHECK (Papel IN ('Tomador','Segurado','Beneficiário')),
    PRIMARY KEY (ApoliceID, EntidadeID, Papel),
    FOREIGN KEY (ApoliceID) REFERENCES Apolice(ApoliceID),
    FOREIGN KEY (EntidadeID) REFERENCES Entidade(EntidadeID)
);
GO

CREATE TABLE Premio (
    PremioID INT IDENTITY(1,1) PRIMARY KEY,
    ApoliceID INT NOT NULL,
    Periodicidade VARCHAR(10) NOT NULL CHECK (Periodicidade IN ('Mensal','Anual')),
    ValorContratado DECIMAL(10,2) NOT NULL,
    ValorPago DECIMAL(10,2) DEFAULT 0,
    ValorDivida DECIMAL(10,2) DEFAULT 0,
    DataReferencia DATE NOT NULL,
    FOREIGN KEY (ApoliceID) REFERENCES Apolice(ApoliceID)
);
GO

CREATE TABLE Cobertura (
    CoberturaID INT IDENTITY(1,1) PRIMARY KEY,
    ProdutoID INT NOT NULL,
    Descricao VARCHAR(100),
    ValorMaximo DECIMAL(12,2) NOT NULL,
    FOREIGN KEY (ProdutoID) REFERENCES Produto(ProdutoID)
);
GO

CREATE TABLE Sinistro (
    SinistroID INT IDENTITY(1,1) PRIMARY KEY,
    ApoliceID INT NOT NULL,
    Estado VARCHAR(20) CHECK (Estado IN ('Aberto','Em_Analise','Fechado','Rejeitado','Pago')),
    ValorReclamado DECIMAL(10,2) NOT NULL,
    ValorIndemnizado DECIMAL(10,2) NULL,
    DataOcorrencia DATE NOT NULL,
    FOREIGN KEY (ApoliceID) REFERENCES Apolice(ApoliceID)
);
GO


CREATE TABLE Auditoria (
    AuditoriaID INT IDENTITY(1,1) PRIMARY KEY,
    TabelaAfetada VARCHAR(50) NOT NULL,
    RegistoID INT NOT NULL,
    TipoOperacao VARCHAR(10) CHECK (TipoOperacao IN ('INSERT','UPDATE','DELETE')),
    DataOperacao DATETIME DEFAULT GETDATE(),
    Utilizador VARCHAR(50),
    Detalhes VARCHAR(500)
);
GO

CREATE TABLE RiscoCliente (
    ClienteID INT PRIMARY KEY,
    NivelRisco VARCHAR(10) CHECK (NivelRisco IN ('Baixo','Medio','Elevado')),
    DataCalculo DATE DEFAULT GETDATE(),
    FOREIGN KEY (ClienteID) REFERENCES Entidade(EntidadeID)
);
GO