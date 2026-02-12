--Listar todos os tipos de seguro

SELECT * FROM TipoSeguro

--Contar quantas apólices existem por tipo de seguro, e ordenar do tipo com mais contratos para o que tem menos.

SELECT TipoSeguro.Descricao, COUNT(Apolice.ApoliceID) AS TotalContratos
FROM TipoSeguro 
LEFT JOIN Produto --LEFT JOIN garante que aparecem todos os 4 tipos mesmo sem apólices.  
    ON TipoSeguro.TipoSeguroID = Produto.TipoSeguroID
LEFT JOIN Apolice  
    ON Produto.ProdutoID = Apolice.ProdutoID
GROUP BY TipoSeguro.Descricao
ORDER BY TotalContratos DESC;

--Lista todas as seguradoras 

SELECT * FROM Seguradora

--Contar apólices ativas por seguradora

SELECT Seguradora.Nome, COUNT(Apolice.ApoliceID) AS NumeroContratosAtivos
FROM Seguradora
LEFT JOIN Produto --LEFT JOIN mostra todas as seguradoras mesmo  sem apólices ativas.
    ON Seguradora.SeguradoraID = Produto.SeguradoraID
LEFT JOIN Apolice 
    ON Produto.ProdutoID = Apolice.ProdutoID 
    AND Apolice.Estado = 'Ativo' 
    AND GETDATE() BETWEEN Apolice.DataInicio 
    AND ISNULL(Apolice.DataFim, '99991231')
GROUP BY Seguradora.SeguradoraID, Seguradora.Nome
ORDER BY NumeroContratosAtivos DESC;


--Listar seguradoras sem Apólices e ordenar por ordem decrescente

SELECT Seguradora.Nome, ISNULL(COUNT(Apolice.ApoliceID), 0) AS NumeroContratosAtivos
FROM Seguradora
LEFT JOIN Produto 
    ON Seguradora.SeguradoraID = Produto.SeguradoraID
LEFT JOIN Apolice 
    ON Produto.ProdutoID = Apolice.ProdutoID 
    AND Apolice.Estado = 'Ativo'
GROUP BY Seguradora.SeguradoraID, Seguradora.Nome
ORDER BY NumeroContratosAtivos DESC;

-- Seguradoras + Prémios PAGOS 
SELECT Seguradora.Nome AS Seguradora, FORMAT(COALESCE(SUM(Premio.ValorPago), 0), 'N2') AS TotalPremiosPagos,
       COUNT(Apolice.ApoliceID) AS NumApolices
FROM Seguradora
LEFT JOIN Produto 
    ON Seguradora.SeguradoraID = Produto.SeguradoraID
LEFT JOIN Apolice 
    ON Produto.ProdutoID = Apolice.ProdutoID 
    AND Apolice.Estado = 'Ativo'
LEFT JOIN Premio 
    ON Apolice.ApoliceID = Premio.ApoliceID
GROUP BY Seguradora.SeguradoraID, Seguradora.Nome
ORDER BY TotalPremiosPagos DESC;

--Valor médio do prémio por tipo de seguro. 

SELECT TipoSeguro.Descricao, FORMAT(AVG(Premio.ValorContratado), 'N2') AS PremioMedio
FROM Apolice 
LEFT JOIN Produto 
    ON Apolice.ProdutoID = Produto.ProdutoID
LEFT JOIN TipoSeguro 
    ON Produto.TipoSeguroID = TipoSeguro.TipoSeguroID
LEFT JOIN Premio 
    ON Apolice.ApoliceID = Premio.ApoliceID
WHERE Apolice.Estado = 'Ativo'
GROUP BY TipoSeguro.Descricao
ORDER BY AVG(Premio.ValorContratado) DESC; 



-- Valor médio efetivamente pago

SELECT TipoSeguro.Descricao, FORMAT(AVG(Premio.ValorPago),'N2') AS PremioMedioPago
FROM Apolice 
LEFT JOIN Produto  
    ON Apolice.ProdutoID = Produto.ProdutoID
LEFT JOIN TipoSeguro 
    ON Produto.TipoSeguroID = TipoSeguro.TipoSeguroID
LEFT JOIN Premio 
    ON Apolice.ApoliceID = Premio.ApoliceID
WHERE Apolice.Estado = 'Ativo'
GROUP BY TipoSeguro.Descricao
ORDER BY AVG(Premio.ValorPago) DESC


--- Apenas prémios com pagamento (Carro, Casa e Vida)

SELECT TipoSeguro.Descricao, FORMAT(AVG(Premio.ValorPago), 'N2') AS PremioMedioPago
FROM Apolice
LEFT JOIN Produto 
    ON Apolice.ProdutoID = Produto.ProdutoID
LEFT JOIN TipoSeguro 
    ON Produto.TipoSeguroID = TipoSeguro.TipoSeguroID  
LEFT JOIN Premio 
    ON Apolice.ApoliceID = Premio.ApoliceID
WHERE Apolice.Estado = 'Ativo' AND Premio.ValorPago > 0
GROUP BY TipoSeguro.Descricao
ORDER BY AVG(Premio.ValorPago) DESC


--Listar todas as entidades que assumem o papel de cliente
--Cliente como Tomador
SELECT Entidade.Nome AS Cliente, ISNULL(COUNT(EntidadeApolice.ApoliceID), 0) AS NumeroContratos
FROM Entidade
LEFT JOIN EntidadeApolice 
    ON Entidade.EntidadeID = EntidadeApolice.EntidadeID 
    AND EntidadeApolice.Papel = 'Tomador'  
GROUP BY Entidade.EntidadeID, Entidade.Nome
ORDER BY NumeroContratos DESC, Entidade.Nome

--Cliente como Segurado
SELECT Entidade.Nome AS Cliente, ISNULL(COUNT(EntidadeApolice.ApoliceID), 0) AS NumeroContratos
FROM Entidade
LEFT JOIN EntidadeApolice 
    ON Entidade.EntidadeID = EntidadeApolice.EntidadeID 
    AND EntidadeApolice.Papel = 'Segurado'  
GROUP BY Entidade.EntidadeID, Entidade.Nome
ORDER BY NumeroContratos DESC, Entidade.Nome;


--Cliente como Beneficiario
SELECT Entidade.Nome AS Cliente, ISNULL(COUNT(EntidadeApolice.ApoliceID), 0) AS NumeroContratos 
FROM Entidade
LEFT JOIN EntidadeApolice 
    ON Entidade.EntidadeID = EntidadeApolice.EntidadeID 
    AND EntidadeApolice.Papel = 'Beneficiário'  
GROUP BY Entidade.EntidadeID, Entidade.Nome
ORDER BY NumeroContratos DESC, Entidade.Nome


--Número de contratos associados a cada cliente
SELECT Entidade.Nome AS Cliente, ISNULL(COUNT(EntidadeApolice.ApoliceID), 0) AS NumeroContratos
FROM Entidade
LEFT JOIN EntidadeApolice 
    ON Entidade.EntidadeID = EntidadeApolice.EntidadeID  
GROUP BY Entidade.EntidadeID, Entidade.Nome
ORDER BY NumeroContratos DESC, Entidade.Nome

--Clientes sem contratos
SELECT Entidade.Nome AS ClienteSemContratos
FROM Entidade
LEFT JOIN EntidadeApolice 
    ON Entidade.EntidadeID = EntidadeApolice.EntidadeID
GROUP BY Entidade.EntidadeID, Entidade.Nome, Entidade.Contacto, Entidade.Morada
HAVING COUNT(EntidadeApolice.ApoliceID) = 0
ORDER BY Entidade.Nome;

--Identificar clientes com mais do que um contrato
SELECT Entidade.Nome AS Cliente, COUNT(EntidadeApolice.ApoliceID) AS TotalContratos
FROM Entidade
INNER JOIN EntidadeApolice 
    ON Entidade.EntidadeID = EntidadeApolice.EntidadeID
GROUP BY Entidade.EntidadeID, Entidade.Nome
HAVING COUNT(EntidadeApolice.ApoliceID) > 1
ORDER BY TotalContratos DESC, Entidade.Nome;

--Listar todos os contratos
SELECT * FROM Apolice

-- Listar TODOS os contratos + número de pagamentos 

SELECT Apolice.NumeroApolice, COUNT(Pagamento.PagamentoID) AS NoPagamentos
FROM Apolice
INNER JOIN Pagamento --mostra só com pagamentos
    ON Apolice.ApoliceID = Pagamento.ApoliceID
GROUP BY Apolice.NumeroApolice

SELECT Apolice.NumeroApolice, COUNT(Pagamento.PagamentoID) AS NoPagamentos
FROM Apolice
LEFT JOIN Pagamento --mostra também com zero pagamentos
    ON Apolice.ApoliceID = Pagamento.ApoliceID
GROUP BY Apolice.NumeroApolice

--Apolices sem pagamentos

SELECT Apolice.NumeroApolice, COUNT(Pagamento.PagamentoID) AS NoPagamentos
FROM Apolice
LEFT JOIN Pagamento 
    ON Apolice.ApoliceID = Pagamento.ApoliceID
GROUP BY Apolice.NumeroApolice
HAVING COUNT(Pagamento.PagamentoID) = 0

--Seguradoras + prémios pagos (com limite + incluir zeros)
SELECT Seguradora.Nome, SUM(Premio.ValorPago) AS TotalPago
FROM Seguradora 
LEFT JOIN Produto 
    ON Seguradora.SeguradoraID = Produto.SeguradoraID
LEFT JOIN Apolice 
    ON Produto.ProdutoID = Apolice.ProdutoID
LEFT JOIN Premio 
    ON Apolice.ApoliceID = Premio.ApoliceID
GROUP BY Seguradora.Nome
HAVING SUM(Premio.ValorPago) > 200

--Contar sinistros por Apolice e Apolices sem sinistros

SELECT TOP 10 Apolice.ApoliceID, COUNT(Sinistro.SinistroID) AS TotalSinistros
FROM Apolice
LEFT JOIN Sinistro 
    ON Apolice.ApoliceID = Sinistro.ApoliceID
GROUP BY Apolice.ApoliceID
ORDER BY  Apolice.ApoliceID 

--Apólices só com sinistros 

SELECT TOP 10 Apolice.ApoliceID, COUNT(Sinistro.SinistroID) AS TotalSinistros
FROM Apolice
INNER JOIN Sinistro 
    ON Apolice.ApoliceID = Sinistro.ApoliceID
GROUP BY Apolice.ApoliceID
ORDER BY  Apolice.ApoliceID


--quais os clientes com maior valor total de indemnizações?

SELECT Entidade.Nome, SUM(Sinistro.ValorIndemnizado) AS TotalIndemnizado
FROM Entidade
INNER JOIN EntidadeApolice 
    ON Entidade.EntidadeID = EntidadeApolice.EntidadeID AND EntidadeApolice.Papel = 'Tomador'
INNER JOIN Apolice
    ON EntidadeApolice.ApoliceID = Apolice.ApoliceID
INNER JOIN Sinistro
    ON Apolice.ApoliceID = Sinistro.ApoliceID
GROUP BY Entidade.Nome
ORDER BY TotalIndemnizado DESC

--TIPOS DE PRODUTO MAIS COMERCIALIZADOS

SELECT TOP 1 Produto.Descricao AS ProdutoLider, COUNT(Apolice.ApoliceID) AS TotalContratos
FROM Produto
LEFT JOIN Apolice 
    ON Produto.ProdutoID = Apolice.ProdutoID
GROUP BY Produto.Descricao
ORDER BY COUNT(Apolice.ApoliceID) DESC;


--Total de Contratos por Tipo de Seguro
SELECT TipoSeguro.Descricao AS TipoSeguro, COUNT(Apolice.ApoliceID) AS TotalContratos
FROM TipoSeguro 
LEFT JOIN Produto 
    ON TipoSeguro.TipoSeguroID = Produto.TipoSeguroID
LEFT JOIN Apolice
    ON Produto.ProdutoID = Apolice.ProdutoID
GROUP BY TipoSeguro.Descricao
ORDER BY TotalContratos DESC

-- RELATÓRIO DE PERCENTAGEM DE RISCO POR Nº DE CLIENTES

SELECT RiscoCliente.NivelRisco, COUNT(RiscoCliente.ClienteID) AS NumClientes, 
    FORMAT(CAST(COUNT(RiscoCliente.ClienteID) AS FLOAT) * 100 / 6, 'N1') + '%' AS Percentagem
FROM RiscoCliente 
GROUP BY RiscoCliente.NivelRisco
ORDER BY NumClientes DESC;

-- RISCO por TIPO DE SEGURO
SELECT TipoSeguro.Descricao AS TipoSeguro, RiscoCliente.NivelRisco, COUNT(*) AS NumClientes
FROM RiscoCliente 
INNER JOIN Entidade 
    ON RiscoCliente.ClienteID = Entidade.EntidadeID
INNER JOIN EntidadeApolice 
    ON Entidade.EntidadeID = EntidadeApolice.EntidadeID
INNER JOIN Apolice 
    ON EntidadeApolice.ApoliceID = Apolice.ApoliceID
INNER JOIN Produto 
    ON Apolice.ProdutoID = Produto.ProdutoID  
INNER JOIN TipoSeguro 
    ON Produto.TipoSeguroID = TipoSeguro.TipoSeguroID
GROUP BY TipoSeguro.Descricao, RiscoCliente.NivelRisco
ORDER BY TipoSeguro.Descricao, COUNT(*) DESC;

-- CLIENTES RISCO ELEVADO + VALOR CONTRATADO (Ana Oliveira)
SELECT TOP 5 Entidade.Nome, RiscoCliente.NivelRisco, 
FORMAT(SUM(Premio.ValorContratado), 'N2') AS Exposicao
FROM RiscoCliente 
LEFT JOIN Entidade 
    ON RiscoCliente.ClienteID = Entidade.EntidadeID
LEFT JOIN EntidadeApolice 
    ON Entidade.EntidadeID = EntidadeApolice.EntidadeID AND EntidadeApolice.Papel = 'Tomador'
LEFT JOIN Apolice 
    ON EntidadeApolice.ApoliceID = Apolice.ApoliceID
LEFT JOIN Premio 
    ON Apolice.ApoliceID = Premio.ApoliceID
WHERE RiscoCliente.NivelRisco = 'Elevado'
GROUP BY Entidade.EntidadeID, Entidade.Nome, RiscoCliente.NivelRisco
ORDER BY Exposicao DESC;

-- EVOLUÇÃO DO RISCO
SELECT Entidade.Nome, RiscoCliente.NivelRisco, RiscoCliente.DataCalculo
FROM RiscoCliente 
LEFT JOIN Entidade 
    ON RiscoCliente.ClienteID = Entidade.EntidadeID
WHERE Entidade.Nome = 'Ana Oliveira'
ORDER BY RiscoCliente.DataCalculo DESC;

-- % CLIENTES POR NÍVEL DE RISCO 
SELECT RiscoCliente.NivelRisco, FORMAT(COUNT(DISTINCT RiscoCliente.ClienteID)*100.0/6, 'N1') + '%' AS PercentagemClientes
FROM RiscoCliente 
GROUP BY RiscoCliente.NivelRisco
ORDER BY COUNT(DISTINCT RiscoCliente.ClienteID) DESC;


--Auditoria
-- HISTÓRICO Apólice 1

SELECT * FROM Auditoria 
WHERE TabelaAfetada = 'Apolice' AND RegistoID = 1
ORDER BY DataOperacao DESC;

-- ATIVIDADE por UTILIZADOR

SELECT Utilizador, COUNT(*) AS TotalOperacoes,MAX(DataOperacao) AS UltimaAtividade
FROM Auditoria 
GROUP BY Utilizador
ORDER BY TotalOperacoes DESC;

-- MUDANÇAS RECENTES EM CLIENTES COM RISCO ELEVADO
SELECT * FROM Auditoria 
WHERE TabelaAfetada = 'Entidade' AND RegistoID IN (SELECT ClienteID FROM RiscoCliente 
    WHERE NivelRisco = 'Elevado') AND DataOperacao >= '2026-01-01'
ORDER BY DataOperacao DESC;


--Alterações em Apólices com sinistro
SELECT * FROM Auditoria 
WHERE TabelaAfetada = 'Apolice' AND RegistoID IN (
      SELECT ApoliceID FROM Sinistro 
      WHERE ValorIndemnizado IS NOT NULL)
ORDER BY DataOperacao DESC;