USE SurpresasExistemEntrega;
GO

-- 1. TABELAS INDEPENDENTES PRIMEIRO
INSERT INTO TipoSeguro (Descricao) VALUES 
    ('Vida'), ('Casa'), ('Carro'), ('Saúde');
GO

INSERT INTO Mediador (Nome, Contacto, NIF, Estado) VALUES 
    ('João Silva', '912345678', '123456789', 'Ativo'),
    ('Maria Santos', '923456789', '987654321', 'Ativo');
GO

INSERT INTO Seguradora (Nome, Contacto, Morada, NIF, Estado) VALUES 
    ('Allianz', '911111111', 'Lisboa Centro', '500000001', 'Ativo'),
    ('Fidelidade', '922222222', 'Porto Baixa', '500000002', 'Ativo');
GO

INSERT INTO Entidade (Nome, DataNascimento, Contacto, Morada, NIF, Estado) VALUES 
    ('Ana Oliveira', '1985-03-15', '915555555', 'Aveiro', '111111111', 'Ativo'),     -- ID=1
    ('Carlos Pereira', '1990-07-22', '925555555', 'Porto', '222222222', 'Ativo'),    -- ID=2
    ('João Santos', '1988-05-10', '935666666', 'Lisboa', '333333333', 'Ativo'),     -- ID=3
    ('Maria Costa', '1992-11-25', '945777777', 'Coimbra', '444444444', 'Ativo'),    -- ID=4
    ('Pedro Almeida', '1987-09-12', '955888888', 'Braga', '555555555', 'Ativo'),    -- ID=5
    ('Rui Sousa', '1990-01-20', '966999999', 'Faro', '666666666', 'Ativo');         -- ID=6 SEM CONTRATOS
GO

-- 2. TABELAS INTERMEDIÁRIAS
INSERT INTO SeguradoraMediador (MediadorID, SeguradoraID) VALUES 
    (1,1), (1,2), (2,1), (2,2);
GO

INSERT INTO Produto (TipoSeguroID, SeguradoraID, Nome, Descricao, DataInicio, DataFim, Estado) VALUES 
    (1,1,'Invalidez','Proteção invalidez','2025-01-01', NULL, 'Ativo'),    --ID=1 Allianz
    (1,2,'Morte','Capital morte','2025-01-01', NULL, 'Ativo'),            --ID=2 Fidelidade
    (2,1,'Incêndio','Danos incêndio','2025-01-01', NULL, 'Ativo'),        --ID=3 Allianz
    (2,2,'Roubo','Conteúdos roubo','2025-01-01', NULL, 'Ativo'),          --ID=4 Fidelidade
    (3,1,'Acidente','Acidentes varios','2025-01-01', NULL, 'Ativo'),      --ID=5 Allianz
    (4,2,'Internamento','Cobertura hospitalar','2025-01-01', NULL, 'Ativo'); --ID=6 Fidelidade 
GO

INSERT INTO Carteira (MediadorID, Estado) VALUES 
    (1, 'Ativo'), (2, 'Ativo');
GO

-- 3. APOLICES (depois de produtos e carteiras)
INSERT INTO Apolice (ProdutoID, CarteiraID, NumeroApolice, DataInicio, DataFim, Estado) VALUES 
    (1,1,'APL001/2025','2025-01-01','2026-12-31','Ativo'),  -- ID=1
    (2,1,'APL002/2025','2025-01-15','2026-12-31','Ativo'),  -- ID=2
    (3,2,'APL003/2025','2025-02-01','2026-12-31','Ativo'),  -- ID=3
    (4,2,'APL004/2025','2025-02-15','2026-12-31','Ativo'),  -- ID=4
    (5,1,'APL005/2025','2025-03-01','2026-12-31','Ativo'),  -- ID=5
    (6,2,'APL006/2025','2025-03-15','2026-12-31','Ativo'),  -- ID=6
    (5,2,'APL007/2025','2025-03-20','2026-12-31','Ativo');  -- ID=7 EXTRA
GO

-- 4. TABELAS DEPENDENTES DE APOLICE
INSERT INTO Pagamento (ApoliceID, DataPagamento, Valor, Estado) VALUES
    (1,'2025-01-05',50.00,'Pago'), 
    (1,'2025-02-05',50.00,'Pago'),
    (2,'2025-01-15',120.00,'Pago'), 
    (3,'2025-02-01',80.00,'EmDivida'), 
    (4,'2025-02-15',200.00,'Pago'),
    (5,'2025-03-01',60.00,'Pago');
GO

INSERT INTO EntidadeApolice (ApoliceID, EntidadeID, Papel) VALUES 
    (1,1,'Tomador'), (1,3,'Segurado'), (1,4,'Beneficiário'),
    (2,2,'Tomador'), (2,1,'Segurado'), (2,3,'Beneficiário'),
    (3,1,'Tomador'), (3,2,'Segurado'),
    (4,3,'Tomador'), (4,4,'Segurado'), (4,1,'Beneficiário'),
    (5,4,'Tomador'), (5,3,'Segurado'),
    (6,2,'Tomador'), (6,5,'Segurado');
GO

INSERT INTO Premio (ApoliceID, Periodicidade, ValorContratado, ValorPago, ValorDivida, DataReferencia) VALUES
    (1,'Mensal',45.50,45.50,0,'2025-01-01'),
    (2,'Anual',320.00,320.00,0,'2025-01-15'),
    (3,'Anual',420.00,0,420.00,'2025-02-01'),
    (4,'Anual',280.00,280.00,0,'2025-02-15'),
    (5,'Mensal',75.00,75.00,0,'2025-03-01'),
    (6,'Mensal',95.00,95.00,0,'2025-03-15');
GO

-- 5. DEMAIS TABELAS
INSERT INTO Cobertura (ProdutoID, Descricao, ValorMaximo) VALUES 
    (1,'Invalidez Total',50000),
    (3,'Incêndio Total',75000),
    (5,'Acidente Pessoal',25000);
GO

INSERT INTO Sinistro (ApoliceID, Estado, ValorReclamado, ValorIndemnizado, DataOcorrencia) VALUES 
    (1,'Aberto',8500,NULL,'2025-07-20'),
    (3,'Fechado',12500,11000,'2025-08-15');
GO

INSERT INTO RiscoCliente (ClienteID, NivelRisco, DataCalculo) VALUES 
    (1,'Elevado','2026-01-21'), 
    (2,'Medio','2026-01-21'), 
    (3,'Baixo','2026-01-21'),
    (4,'Baixo','2026-01-21'), 
    (5,'Baixo','2026-01-21'), 
    (6,'Baixo','2026-01-21');
GO

INSERT INTO Auditoria (TabelaAfetada, RegistoID, TipoOperacao, Utilizador, Detalhes) VALUES
    ('Apolice', 1, 'INSERT', 'joao_silva', 'Criação apólice APL001/2025 - Invalidez'),
    ('Apolice', 3, 'UPDATE', 'maria_santos', 'Alterado estado para Em_Analise'),
    ('Sinistro', 1, 'INSERT', 'joao_silva', 'Registo sinistro aberto APL001 - 8500€'),
    ('Pagamento', 1, 'INSERT', 'admin', 'Pagamento Jan 2025 - 50€'),
    ('Entidade', 1, 'UPDATE', 'gestor', 'Ana Oliveira movida para risco Elevado');
GO

PRINT 'Sucesso';
