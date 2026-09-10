CREATE TABLE clientes(

id SERIAL primary key,
nome VARCHAR(100) not null,
email VARCHAR(100) Unique not null,
telefone VARCHAR(15) not null,
cpf VARCHAR(11) unique not null,
data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
CREATE TABLE mecanicos(

ID SERIAL PRIMARY KEY,
nome VARCHAR(100) not null,
especialidade VARCHAR(100) not null,
valor_hora numeric(10,2) not null check(valor_hora > 0)
)

CREATE TABLE veiculos(

ID SERIAL PRIMARY KEY,
cliente_id INT not null,
placa VARCHAR(7) unique not null,
modelo VARCHAR(100) not null,
marca VARCHAR(100) not null,
ano INT not null check(ano > 1886),

CONSTRAINT fk_veiculos_cliente 
FOREIGN KEY(cliente_id)
REFERENCES clientes(id)
ON DELETE CASCADE
)

CREATE TABLE ordens_servico(

ID SERIAL PRIMARY KEY,
	veiculo_id INT NOT NULL,
 	mecanico_id INT NOT NULL,
	data_abertura TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	valor_mao_obra INT not null check(valor_mao_obra >= 0),
	status VARCHAR(20) DEFAULT 'Em Aberto' CHECK (status IN ('Em Aberto', 'Em Andamento', 'Concluida', 'Cancelada')),

	FOREIGN KEY (veiculo_id)
	REFERENCES veiculos(ID),

	FOREIGN KEY (mecanico_id)
	REFERENCES mecanicos(ID)
	
)

CREATE TABLE pecas_os(

ID SERIAL PRIMARY KEY,
os_id INT not null,
nome_peca VARCHAR(100) not null,
quantidade NUMERIC(67) not null check(quantidade > 0),
valor_unitario INT not null check(valor_unitario >0),

FOREIGN KEY (os_id)
REFERENCES ordens_servico(id)
)
 

