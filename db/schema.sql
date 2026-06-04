-- schema.sql
-- Define as tabelas do projeto SQL Analytics HubSpot no DuckDB.
-- Rodar antes de load_data.sql

DROP TABLE IF EXISTS line_items;
DROP TABLE IF EXISTS deals;
DROP TABLE IF EXISTS metas;
DROP TABLE IF EXISTS vendedores;
DROP TABLE IF EXISTS empresas;

CREATE TABLE empresas (
    empresa_id   VARCHAR PRIMARY KEY,
    nome_empresa VARCHAR,
    cnpj         VARCHAR,
    segmento     VARCHAR,
    porte        VARCHAR,
    cidade       VARCHAR,
    estado       VARCHAR,
    data_criacao DATE
);

CREATE TABLE vendedores (
    id        VARCHAR PRIMARY KEY,
    nome      VARCHAR,
    vertical  VARCHAR   -- CORPORATE | MIDDLE
);

CREATE TABLE deals (
    deal_id            VARCHAR PRIMARY KEY,
    empresa_id         VARCHAR,
    nome_empresa       VARCHAR,
    cnpj               VARCHAR,
    pipeline           VARCHAR,
    etapa              VARCHAR,
    vendedor_id        VARCHAR,
    vendedor_nome      VARCHAR,
    data_criacao       DATE,
    data_fechamento    DATE,
    dias_ciclo         INTEGER,
    vl_mrr             DECIMAL(15,2),
    vl_setup           DECIMAL(15,2),
    receita_total      DECIMAL(15,2),
    sigla_proposta     VARCHAR,
    motivo_perda       VARCHAR,
    ultima_atualizacao DATE
);

CREATE TABLE line_items (
    line_item_id  VARCHAR PRIMARY KEY,
    deal_id       VARCHAR,
    tipo_cobranca VARCHAR,
    valor         DECIMAL(15,2),
    incremento    DECIMAL(15,2),
    decremento    DECIMAL(15,2),
    valor_liquido DECIMAL(15,2)
);

CREATE TABLE metas (
    vendedor_id   VARCHAR,
    vendedor_nome VARCHAR,
    vertical      VARCHAR,
    ano           INTEGER,
    quarter       VARCHAR,
    meta_receita  DECIMAL(15,2),
    PRIMARY KEY (vendedor_id, ano, quarter)
);