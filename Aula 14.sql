
-- Exercício 1: Criar view vw_media_temperatura_reservatorio
CREATE OR REPLACE VIEW vw_media_temperatura_reservatorio AS
SELECT
    r.nome AS reservatorio,
    AVG(s.valor) AS media_temperatura,
    MIN(s.valor) AS temperatura_minima,
    MAX(s.valor) AS temperatura_maxima,
    COUNT(s.valor) AS total_medicoes
FROM reservatorio r
JOIN serie_temporal s ON s.id_reservatorio = r.id_reservatorio
JOIN parametro p ON p.id_parametro = s.id_parametro
WHERE p.nome_parametro = 'Temperatura'
GROUP BY r.nome
ORDER BY media_temperatura DESC;

-- Exercício 2: Criar view vw_eventos_reservatorio
CREATE OR REPLACE VIEW vw_eventos_reservatorio AS
SELECT
    r.nome AS nome_reservatorio,
    p.nome_parametro AS nome_parametro,
    s.valor,
    s.data_hora
FROM reservatorio r
JOIN serie_temporal s ON s.id_reservatorio = r.id_reservatorio
JOIN parametro p ON p.id_parametro = s.id_parametro
ORDER BY s.data_hora DESC;

-- Exercício 3: View de reservatórios com média de turbidez acima de 5
CREATE OR REPLACE VIEW vw_reservatorios_turbidez_alta AS
SELECT
    r.nome AS reservatorio,
    AVG(s.valor) AS media_turbidez,
    COUNT(s.valor) AS medicoes_turbidez
FROM reservatorio r
JOIN serie_temporal s ON s.id_reservatorio = r.id_reservatorio
JOIN parametro p ON p.id_parametro = s.id_parametro
WHERE p.nome_parametro = 'Turbidez'
GROUP BY r.nome
HAVING AVG(s.valor) > 5
ORDER BY media_turbidez DESC;

-- ============================================
-- 3. VIEWS OBRIGATÓRIAS PARA O PROJETO
-- ============================================

-- View 1: Análise de qualidade da água por reservatório
CREATE OR REPLACE VIEW vw_analise_agua_reservatorio AS
SELECT
    r.nome AS reservatorio,
    p.nome_parametro AS parametro,
    AVG(s.valor) AS media,
    MIN(s.valor) AS minimo,
    MAX(s.valor) AS maximo,
    COUNT(s.valor) AS quantidade_medicoes
FROM reservatorio r
JOIN serie_temporal s ON s.id_reservatorio = r.id_reservatorio
JOIN parametro p ON p.id_parametro = s.id_parametro
GROUP BY r.nome, p.nome_parametro
ORDER BY r.nome, p.nome_parametro;

-- View 2: Parâmetros críticos (acima do limiar definido)
CREATE OR REPLACE VIEW vw_alerta_parametros AS
SELECT
    r.nome AS reservatorio,
    p.nome_parametro AS parametro,
    s.valor,
    s.data_hora,
    'ALERTA: Valor acima da média + desvio padrão' AS motivo
FROM serie_temporal s
JOIN reservatorio r ON r.id_reservatorio = s.id_reservatorio
JOIN parametro p ON p.id_parametro = s.id_parametro
WHERE s.valor > (
    SELECT AVG(s2.valor) + STDDEV(s2.valor)
    FROM serie_temporal s2
    WHERE s2.id_parametro = s.id_parametro
);

-- ============================================
-- 4. INSERIR DADOS DE EXEMPLO PARA TESTES
-- ============================================

-- Inserir dados de exemplo
INSERT INTO reservatorio (nome) VALUES 
('Jaguari'),
('Billings'),
('Guarapiranga'),
('Rio Grande');

INSERT INTO parametro (nome_parametro, unidade) VALUES 
('Temperatura', '°C'),
('pH', ''),
('Turbidez', 'NTU'),
('Oxigênio Dissolvido', 'mg/L'),
('Condutividade', 'μS/cm');

INSERT INTO serie_temporal (id_reservatorio, id_parametro, valor, data_hora) VALUES
-- Temperatura
(1, 1, 25.5, '2025-10-10 10:00:00'),
(1, 1, 26.0, '2025-10-10 11:00:00'),
(2, 1, 24.0, '2025-10-10 10:00:00'),
(2, 1, 24.5, '2025-10-10 11:00:00'),
(3, 1, 23.0, '2025-10-10 10:00:00'),
-- pH
(1, 2, 7.2, '2025-10-10 10:00:00'),
(1, 2, 7.3, '2025-10-10 11:00:00'),
(2, 2, 6.8, '2025-10-10 10:00:00'),
(3, 2, 7.0, '2025-10-10 10:00:00'),
-- Turbidez (alguns acima de 5)
(1, 3, 3.5, '2025-10-10 10:00:00'),
(1, 3, 8.2, '2025-10-10 11:00:00'),  -- Alta turbidez
(2, 3, 2.0, '2025-10-10 10:00:00'),
(3, 3, 7.8, '2025-10-10 10:00:00'),  -- Alta turbidez
(3, 3, 6.5, '2025-10-10 11:00:00'),  -- Alta turbidez
-- Oxigênio Dissolvido
(1, 4, 8.5, '2025-10-10 10:00:00'),
(2, 4, 7.8, '2025-10-10 10:00:00'),
-- Condutividade (apenas para alguns reservatórios)
(1, 5, 150.0, '2025-10-10 10:00:00'),
(2, 5, 180.0, '2025-10-10 10:00:00');

-- ============================================
-- 5. CONSULTAR AS VIEWS CRIADAS (Exercício 4)
-- ============================================

-- Consultar view de média de temperatura
SELECT * FROM vw_media_temperatura_reservatorio;

-- Consultar view de eventos
SELECT * FROM vw_eventos_reservatorio;

-- Consultar view de turbidez alta
SELECT * FROM vw_reservatorios_turbidez_alta;

-- Consultar views obrigatórias do projeto
SELECT * FROM vw_analise_agua_reservatorio;
SELECT * FROM vw_alerta_parametros;

-- Consultar apenas os primeiros registros de cada view
SELECT * FROM vw_media_temperatura_reservatorio LIMIT 3;
SELECT * FROM vw_eventos_reservatorio LIMIT 5;
SELECT * FROM vw_reservatorios_turbidez_alta;

-- ============================================
-- 6. REMOVER UMA VIEW (Exercício 5)
-- ============================================

-- Exemplo 1: Remover view vw_eventos_reservatorio
-- DROP VIEW IF EXISTS vw_eventos_reservatorio;

-- Exemplo 2: Remover e recriar uma view
-- DROP VIEW IF EXISTS vw_reservatorios_turbidez_alta;
-- CREATE OR REPLACE VIEW vw_reservatorios_turbidez_alta AS ... (recriar)

-- ============================================
-- 7. VIEWS ADICIONAIS (EXTRA)
-- ============================================

-- View do desafio prático: relatório de pH por reservatório
CREATE OR REPLACE VIEW vw_relatorio_ph AS
SELECT 
    r.nome AS reservatorio,
    AVG(s.valor) AS media_ph,
    MIN(s.valor) AS ph_min,
    MAX(s.valor) AS ph_max,
    COUNT(s.valor) AS total_medicoes
FROM reservatorio r
JOIN serie_temporal s ON s.id_reservatorio = r.id_reservatorio
JOIN parametro p ON p.id_parametro = s.id_parametro
WHERE p.nome_parametro = 'pH'
GROUP BY r.nome
ORDER BY media_ph DESC;

-- View para reservatórios que possuem medições de pH
CREATE OR REPLACE VIEW vw_reservatorios_com_ph AS
SELECT DISTINCT r.nome
FROM reservatorio r
WHERE r.id_reservatorio IN (
    SELECT s.id_reservatorio
    FROM serie_temporal s
    JOIN parametro p ON p.id_parametro = s.id_parametro
    WHERE p.nome_parametro = 'pH'
);

-- View para reservatórios que NÃO possuem Oxigênio Dissolvido
CREATE OR REPLACE VIEW vw_reservatorios_sem_oxigenio AS
SELECT r.nome
FROM reservatorio r
WHERE r.id_reservatorio NOT IN (
    SELECT s.id_reservatorio
    FROM serie_temporal s
    JOIN parametro p ON p.id_parametro = s.id_parametro
    WHERE p.nome_parametro = 'Oxigênio Dissolvido'
);

-- ============================================
-- 8. INFORMAÇÕES SOBRE AS VIEWS CRIADAS
-- ============================================

-- Listar todas as views criadas
SELECT table_name AS view_name,
       view_definition
FROM information_schema.views
WHERE table_schema = 'public'
ORDER BY table_name;

-- Mostrar detalhes de uma view específica
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'vw_analise_agua_reservatorio'
ORDER BY ordinal_position;

-- ============================================
-- 9. EXEMPLOS DE USO PRÁTICO DAS VIEWS
-- ============================================

-- Exemplo 1: Usar view para relatório rápido
SELECT * FROM vw_relatorio_ph;

-- Exemplo 2: Filtrar dados de uma view
SELECT * FROM vw_analise_agua_reservatorio 
WHERE parametro = 'Turbidez' 
ORDER BY media DESC;

-- Exemplo 3: Juntar views com outras consultas
SELECT 
    v.reservatorio,
    v.media_temperatura,
    a.quantidade_medicoes
FROM vw_media_temperatura_reservatorio v
JOIN (
    SELECT reservatorio, COUNT(*) as quantidade_medicoes
    FROM vw_eventos_reservatorio
    GROUP BY reservatorio
) a ON v.reservatorio = a.reservatorio;

-- Exemplo 4: Usar view em subconsulta
SELECT *
FROM vw_eventos_reservatorio
WHERE nome_reservatorio IN (
    SELECT reservatorio 
    FROM vw_reservatorios_turbidez_alta
);

