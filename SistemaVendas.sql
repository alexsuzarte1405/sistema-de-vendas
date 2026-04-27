-- ==========================================================
-- ATIVIDADE: SISTEMA DE VENDAS COM PROCEDURE
-- BANCO DE DADOS: PostgreSQL
-- ==========================================================

-- 1. DDL - CRIAÇÃO DAS TABELAS
-- ----------------------------------------------------------
;;;
CREATE TABLE IF NOT EXISTS produtos (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    preco DECIMAL(10, 2) NOT NULL,
    estoque INT NOT NULL
);

CREATE TABLE IF NOT EXISTS vendas (
    id SERIAL PRIMARY KEY,
    produto_id INT REFERENCES produtos(id),
    quantidade INT NOT NULL,
    valor_total DECIMAL(10, 2) NOT NULL,
    data_venda TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. DML - INSERÇÃO DE DADOS INICIAIS
-- ----------------------------------------------------------

INSERT INTO produtos (nome, preco, estoque) VALUES 
('Produto A', 10.00, 100),
('Produto B', 20.00, 50),
('Produto C', 5.00, 200);

-- 3. PROCEDURE DE VENDA COM VALIDAÇÕES
-- ----------------------------------------------------------

CREATE OR REPLACE PROCEDURE realizar_venda(p_produto_id INT, p_quantidade INT)
LANGUAGE plpgsql
AS $$
DECLARE
    v_preco DECIMAL(10, 2);
    v_estoque_atual INT;
    v_valor_total DECIMAL(10, 2);
BEGIN
    -- Verificar se o produto existe e obter preço e estoque
    SELECT preco, estoque INTO v_preco, v_estoque_atual
    FROM produtos
    WHERE id = p_produto_id;

    -- Validação: Existência do produto
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Erro: Produto com ID % não encontrado.', p_produto_id;
    END IF;

    -- Validação: Estoque suficiente
    IF v_estoque_atual < p_quantidade THEN
        RAISE EXCEPTION 'Erro: Estoque insuficiente para o produto %. Disponível: %, Solicitado: %', 
                        p_produto_id, v_estoque_atual, p_quantidade;
    END IF;

    -- Cálculo do valor total
    v_valor_total := v_preco * p_quantidade;

    -- Inserir o registro da venda
    INSERT INTO vendas (produto_id, quantidade, valor_total)
    VALUES (p_produto_id, p_quantidade, v_valor_total);

    -- Atualizar o estoque do produto diminuindo a quantidade vendida
    UPDATE produtos
    SET estoque = estoque - p_quantidade
    WHERE id = p_produto_id;

    -- Mensagem de confirmação no console
    RAISE NOTICE 'Venda realizada com sucesso! ID Produto: %, Total: R$ %', p_produto_id, v_valor_total;

END;
$$;

-- 4. EXEMPLOS DE EXECUÇÃO (TESTES)
-- ----------------------------------------------------------

-- Chamada de venda bem-sucedida
-- CALL realizar_venda(1, 2); 

-- Consulta para conferir os resultados
-- SELECT * FROM produtos;
-- SELECT * FROM vendas;