USE SurpresasExistem;
GO

-- DELETE FORÇADO (ignora FKs temporariamente)
-- Desativa verificação FK
EXEC sp_MSforeachtable "ALTER TABLE ? NOCHECK CONSTRAINT ALL";

-- Apaga TUDO
DELETE FROM Sinistro;
DELETE FROM Premio;
DELETE FROM EntidadeApolice;
DELETE FROM Cobertura;
DELETE FROM Apolice;
DELETE FROM Carteira;
DELETE FROM Produto;
DELETE FROM Pagamento;
DELETE FROM Entidade;
DELETE FROM SeguradoraMediador;
DELETE FROM Seguradora;
DELETE FROM Mediador;
DELETE FROM TipoSeguro;
DELETE FROM RiscoCliente;
DELETE FROM Auditoria;

-- Reativa FKs
EXEC sp_MSforeachtable "ALTER TABLE ? WITH CHECK CHECK CONSTRAINT ALL";

-- RESET IDENTITYs
DBCC CHECKIDENT ('TipoSeguro', RESEED, 0);
DBCC CHECKIDENT ('Mediador', RESEED, 0);
DBCC CHECKIDENT ('Seguradora', RESEED, 0);
DBCC CHECKIDENT ('Entidade', RESEED, 0);
DBCC CHECKIDENT ('Pagamento', RESEED, 0);
DBCC CHECKIDENT ('Carteira', RESEED, 0);
DBCC CHECKIDENT ('Produto', RESEED, 0);
DBCC CHECKIDENT ('Apolice', RESEED, 0);

PRINT 'LIMPO!';

