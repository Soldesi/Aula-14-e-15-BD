-- A) SP para atualizar autor de um livro
CREATE OR REPLACE PROCEDURE sp_atualizar_autor_livro(
    id_livro_p INT,
    novo_autor_p VARCHAR
)
LANGUAGE SQL
AS $$
    UPDATE livro
    SET autor = novo_autor_p
    WHERE id_livro = id_livro_p;
$$;

-- B) SP para excluir livro pelo id
CREATE OR REPLACE PROCEDURE sp_excluir_livro(
    id_livro_p INT
)
LANGUAGE SQL
AS $$
    DELETE FROM livro
    WHERE id_livro = id_livro_p;
$$;

-- ============================================
-- 3. STORED PROCEDURES PARA PROJETO ABP
-- ============================================

-- A) SP para cadastrar reservatório
CREATE OR REPLACE PROCEDURE sp_cadastrar_reservatorio(
    nome_p VARCHAR,
    localizacao_p VARCHAR DEFAULT NULL,
    capacidade_p NUMERIC DEFAULT NULL
)
LANGUAGE SQL
AS $$
    INSERT INTO reservatorio (nome, localizacao, capacidade)
    VALUES (nome_p, localizacao_p, capacidade_p);
$$;

-- B) SP para cadastrar parâmetro ambiental
CREATE OR REPLACE PROCEDURE sp_cadastrar_parametro(
    nome_parametro_p VARCHAR,
    unidade_p VARCHAR DEFAULT NULL
)
LANGUAGE SQL
AS $$
    INSERT INTO parametro (nome_parametro, unidade)
    VALUES (nome_parametro_p, unidade_p);
$$;

-- C) SP para registrar medição (básica)
CREATE OR REPLACE PROCEDURE sp_registrar_medicao(
    id_reservatorio_p INT,
    id_parametro_p INT,
    valor_p NUMERIC,
    data_hora_p TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
LANGUAGE SQL
AS $$
    INSERT INTO serie_temporal (id_reservatorio, id_parametro, valor, data_hora)
    VALUES (id_reservatorio_p, id_parametro_p, valor_p, data_hora_p);
$$;

-- ============================================
-- 4. BÔNUS: SP COM VALIDAÇÃO (RAISE EXCEPTION)
-- ============================================

CREATE OR REPLACE PROCEDURE sp_registrar_medicao_validada(
    id_reservatorio_p INT,
    id_parametro_p INT,
    valor_p NUMERIC,
    data_hora_p TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Validação: valor não pode ser negativo
    IF valor_p < 0 THEN
        RAISE EXCEPTION 'Valor não pode ser negativo: %', valor_p;
    END IF;

    -- Validação: parâmetro deve existir
    IF NOT EXISTS (SELECT 1 FROM parametro WHERE id_parametro = id_parametro_p) THEN
        RAISE EXCEPTION 'Parâmetro com ID % não existe', id_parametro_p;
    END IF;

    -- Validação: reservatório deve existir
    IF NOT EXISTS (SELECT 1 FROM reservatorio WHERE id_reservatorio = id_reservatorio_p) THEN
        RAISE EXCEPTION 'Reservatório com ID % não existe', id_reservatorio_p;
    END IF;

    -- Inserção se todas as validações passarem
    INSERT INTO serie_temporal (id_reservatorio, id_parametro, valor, data_hora)
    VALUES (id_reservatorio_p, id_parametro_p, valor_p, data_hora_p);
    
    RAISE NOTICE 'Medição registrada com sucesso!';
END;
$$;

