CREATE TABLE especialidades (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE pacientes (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    cpf VARCHAR(11) NOT NULL UNIQUE CHECK (length(cpf) = 11),
    data_nascimento DATE NOT NULL,
    data_cadastro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE medicos (
    id SERIAL PRIMARY KEY,
    especialidade_id INT NOT NULL REFERENCES especialidades(id),
    nome VARCHAR(150) NOT NULL,
    crm VARCHAR(20) NOT NULL UNIQUE,
    valor_consulta NUMERIC(10, 2) NOT NULL CHECK (valor_consulta > 0)
);

CREATE TABLE consultas (
    id SERIAL PRIMARY KEY,
    medico_id INT NOT NULL REFERENCES medicos(id),
    paciente_id INT NOT NULL REFERENCES pacientes(id),
    data_hora TIMESTAMP NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'Agendada' CHECK (status IN ('Agendada', 'Realizada', 'Cancelada'))
);

CREATE TABLE exames_consulta (
    id SERIAL PRIMARY KEY,
    consulta_id INT NOT NULL REFERENCES consultas(id),
    nome_exame VARCHAR(150) NOT NULL,
    valor_exame NUMERIC(10, 2) NOT NULL CHECK (valor_exame >= 0)
);

INSERT INTO especialidades (nome) VALUES
('Cardiologia'),
('Pediatria'),
('Dermatologia');

INSERT INTO medicos (especialidade_id, nome, crm, valor_consulta) VALUES
(1, 'Guilherme', 'CRM12345SP', 350.00),
(2, 'Nicolas', 'CRM67890SP', 250.00),
(3, 'Lucca', 'CRM11223SP', 400.00);

INSERT INTO pacientes (nome, email, cpf, data_nascimento) VALUES
('davi', 'davi.pedrinho@email.com', '12345678901', '1985-04-12'),
('felipe', 'felipe.giongo@email.com', '98765432100', '1990-08-25'),
('manuela', 'manuela.urbano@email.com', '45678912300', '1978-11-03');

INSERT INTO consultas (medico_id, paciente_id, data_hora, status) VALUES
(1, 1, '2026-03-01 10:00:00', 'Realizada'),
(2, 1, '2026-03-05 14:00:00', 'Agendada'),
(3, 2, '2026-03-02 11:30:00', 'Realizada'),
(1, 3, '2026-03-03 09:00:00', 'Cancelada');

INSERT INTO exames_consulta (consulta_id, nome_exame, valor_exame) VALUES
(1, 'Hemograma Completo', 50.00),
(1, 'Eletrocardiograma', 150.00),
(3, 'Biópsia de Pele', 200.00),
(4, 'Colesterol Total', 30.00);

SELECT 
    m.nome AS medico,
    m.crm,
    e.nome AS especialidade,
    m.valor_consulta
FROM medicos m
JOIN especialidades e ON m.especialidade_id = e.id
ORDER BY m.valor_consulta DESC;

SELECT 
    c.id AS consulta_id,
    c.data_hora,
    m.nome AS medico,
    e.nome AS especialidade,
    c.status
FROM consultas c
JOIN pacientes p ON c.paciente_id = p.id
JOIN medicos m ON c.medico_id = m.id
JOIN especialidades e ON m.especialidade_id = e.id
WHERE p.nome = 'Carlos Silva'
ORDER BY c.data_hora;

SELECT 
    c.id AS consulta_id,
    p.nome AS paciente,
    m.nome AS medico,
    m.valor_consulta + COALESCE(SUM(ec.valor_exame), 0) AS valor_total
FROM consultas c
JOIN pacientes p ON c.paciente_id = p.id
JOIN medicos m ON c.medico_id = m.id
LEFT JOIN exames_consulta ec ON c.id = ec.consulta_id
GROUP BY c.id, p.nome, m.nome, m.valor_consulta
ORDER BY c.id;

SELECT 
    nome, 
    crm, 
    valor_consulta
FROM medicos
WHERE valor_consulta > 300.00
ORDER BY valor_consulta DESC;

SELECT 
    e.nome AS especialidade,
    SUM(m.valor_consulta + COALESCE(ex.total_exames, 0)) AS total_faturado
FROM consultas c
JOIN medicos m ON c.medico_id = m.id
JOIN especialidades e ON m.especialidade_id = e.id
LEFT JOIN (
    SELECT consulta_id, SUM(valor_exame) AS total_exames
    FROM exames_consulta
    GROUP BY consulta_id
) ex ON c.id = ex.consulta_id
WHERE c.status = 'Realizada'
GROUP BY e.id, e.nome
ORDER BY total_faturado DESC;