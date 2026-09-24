CREATE TABLE membros (
    id_membro SERIAL PRIMARY KEY,
    nome_completo VARCHAR(120) NOT NULL,
    email_contato VARCHAR(100) UNIQUE NOT NULL,
    documento_cpf VARCHAR(11) UNIQUE NOT NULL,
    num_telefone VARCHAR(20) NOT NULL,
    cadastrado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE pacotes_treino (
    id_pacote SERIAL PRIMARY KEY,
    descricao VARCHAR(50) UNIQUE NOT NULL,
    preco_base_mensal DECIMAL(10,2) CHECK (preco_base_mensal > 0) NOT NULL
);

CREATE TABLE atividades (
    id_atividade SERIAL PRIMARY KEY,
    id_pacote INT REFERENCES pacotes_treino(id_pacote),
    nome_atividade VARCHAR(100) NOT NULL,
    local_aula VARCHAR(30) NOT NULL,
    limite_alunos INT CHECK (limite_alunos > 0) NOT NULL,
    esta_ativo BOOLEAN DEFAULT TRUE
);

CREATE TABLE contratos (
    id_contrato SERIAL PRIMARY KEY,
    id_membro INT REFERENCES membros(id_membro),
    data_assinatura TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    situacao VARCHAR(20) DEFAULT 'Vigente' CHECK (situacao IN ('Vigente', 'Cancelado', 'Pausado'))
);

CREATE TABLE itens_contrato (
    id_item SERIAL PRIMARY KEY,
    id_contrato INT REFERENCES contratos(id_contrato),
    id_atividade INT REFERENCES atividades(id_atividade),
    tempo_meses INT CHECK (tempo_meses > 0) NOT NULL,
    valor_cobrado_mes DECIMAL(10,2) CHECK (valor_cobrado_mes > 0) NOT NULL,
    custo_matricula DECIMAL(10,2) CHECK (custo_matricula >= 0) DEFAULT 0.00
);

INSERT INTO pacotes_treino (descricao, preco_base_mensal) VALUES 
('Plano Elite', 250.00), 
('Plano Intermediário', 160.00), 
('Plano Econômico', 100.00);

INSERT INTO atividades (id_pacote, nome_atividade, local_aula, limite_alunos, esta_ativo) VALUES 
(1, 'Treinamento Funcional Extreme', 'Box 1', 20, TRUE),
(2, 'Yoga e Alongamento', 'Sala Zen', 12, TRUE),
(3, 'Área de Musculação', 'Andar Térreo', 60, TRUE);

INSERT INTO membros (nome_completo, email_contato, documento_cpf, num_telefone) VALUES 
('Rafael Oliveira', 'rafael.oli@email.com', '98765432100', '21999998888'),
('Juliana Mendes', 'jumendes@email.com', '12345678911', '21988887777'),
('Fernando Souza', 'fersouza@email.com', '45612378922', '21977776666');

INSERT INTO contratos (id_membro, situacao) VALUES 
(1, 'Vigente'), 
(1, 'Vigente'), 
(2, 'Vigente'), 
(3, 'Cancelado');

INSERT INTO itens_contrato (id_contrato, id_atividade, tempo_meses, valor_cobrado_mes, custo_matricula) VALUES 
(1, 1, 12, 250.00, 0.00),
(2, 2, 6, 160.00, 40.00),
(3, 3, 12, 100.00, 0.00),
(4, 1, 1, 250.00, 50.00);

CREATE VIEW vw_projecao_mensalidades AS
SELECT 
    a.nome_atividade AS aula, 
    a.local_aula AS espaco, 
    pt.descricao AS pacote_vinculado, 
    ROUND(pt.preco_base_mensal * 1.15, 2) AS valor_com_acrescimo
FROM atividades a
INNER JOIN pacotes_treino pt ON a.id_pacote = pt.id_pacote
ORDER BY valor_com_acrescimo DESC;

CREATE VIEW vw_membros_ativos AS
SELECT 
    m.nome_completo AS nome_cliente, 
    m.documento_cpf AS cpf_cliente, 
    ati.nome_atividade AS aula_escolhida, 
    ati.local_aula, 
    ic.tempo_meses, 
    c.data_assinatura
FROM contratos c
INNER JOIN membros m ON c.id_membro = m.id_membro
INNER JOIN itens_contrato ic ON c.id_contrato = ic.id_contrato
INNER JOIN atividades ati ON ic.id_atividade = ati.id_atividade
WHERE c.situacao = 'Vigente';

CREATE VIEW vw_clientes_premium AS
SELECT 
    m.nome_completo AS cliente, 
    COUNT(c.id_contrato) AS qtd_contratos, 
    SUM((ic.valor_cobrado_mes * ic.tempo_meses) + ic.custo_matricula) AS gasto_total
FROM membros m
INNER JOIN contratos c ON m.id_membro = c.id_membro
INNER JOIN itens_contrato ic ON c.id_contrato = ic.id_contrato
WHERE c.situacao = 'Vigente'
GROUP BY m.id_membro, m.nome_completo
HAVING SUM((ic.valor_cobrado_mes * ic.tempo_meses) + ic.custo_matricula) > 1200.00;

SELECT 
    ati.*, 
    pt.descricao AS nome_pacote, 
    pt.preco_base_mensal
FROM atividades ati
INNER JOIN pacotes_treino pt ON ati.id_pacote = pt.id_pacote
WHERE ati.limite_alunos >= 15 
  AND pt.preco_base_mensal > 120.00 
  AND ati.esta_ativo = TRUE;

CREATE VIEW vw_receita_por_pacote AS
SELECT 
    pt.descricao AS tipo_pacote, 
    SUM((ic.valor_cobrado_mes * ic.tempo_meses) + ic.custo_matricula) AS receita_gerada,
    ROUND(AVG(ic.tempo_meses), 1) AS media_fidelidade_meses
FROM itens_contrato ic
INNER JOIN contratos c ON ic.id_contrato = c.id_contrato
INNER JOIN atividades ati ON ic.id_atividade = ati.id_atividade
INNER JOIN pacotes_treino pt ON ati.id_pacote = pt.id_pacote
WHERE c.situacao = 'Vigente'
GROUP BY pt.descricao;
