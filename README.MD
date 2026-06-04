# SQL Analytics — HubSpot

Projeto de SQL avançado com 10 queries analíticas reais sobre dados mockados no formato HubSpot.

## Stack
- **DuckDB** — engine SQL local, zero configuração
- **Python + Faker** — geração de dados mockados realistas
- **Sintaxe compatível** com PostgreSQL e BigQuery

## Estrutura

```
sql-analytics-hubspot/
├── data/mock/
│   └── generate_mock_data.py   # Gera os CSVs mockados
├── db/
│   ├── schema.sql              # CREATE TABLEs
│   └── load_data.sql           # Carga dos CSVs no DuckDB
├── queries/
│   ├── 01_ranking_vendedores.sql
│   ├── 02_cohort_deals.sql
│   ├── 03_rolling_avg_receita.sql
│   ├── 04_funil_conversao.sql
│   ├── 05_ticket_medio_pipeline.sql
│   ├── 06_tempo_ciclo_venda.sql
│   ├── 07_cohort_retencao.sql
│   ├── 08_deals_em_risco.sql
│   ├── 09_performance_vs_meta.sql
│   └── 10_top_empresas_ltv.sql
└── docs/
    └── query_notes.md
```

## Como rodar

```bash
# 1. Instalar dependências
py -m pip install duckdb pandas faker

# 2. Gerar os dados mockados
py data/mock/generate_mock_data.py

# 3. Criar e carregar o banco
py -c "
import duckdb
con = duckdb.connect('hubspot.duckdb')
con.execute(open('db/schema.sql').read())
con.execute(open('db/load_data.sql').read())
print('Banco pronto!')
con.close()
"

# 4. Rodar uma query
py -c "
import duckdb
con = duckdb.connect('hubspot.duckdb')
result = con.execute(open('queries/01_ranking_vendedores.sql').read()).df()
print(result.to_string())
con.close()
"
```

## Queries

| # | Query | Técnicas |
|---|---|---|
| 01 | Ranking de vendedores | `RANK()`, `PARTITION BY` |
| 02 | Cohort de deals | `DATE_TRUNC`, `COUNT FILTER` |
| 03 | Rolling avg de receita | `AVG() OVER`, `ROWS BETWEEN` |
| 04 | Funil de conversão | `LAG()`, `CASE WHEN` |
| 05 | Ticket médio por pipeline | `PERCENTILE_CONT`, `AVG` |
| 06 | Tempo de ciclo de venda | `DATEDIFF`, `FILTER` |
| 07 | Cohort de retenção | CTE encadeada, `DATEDIFF` |
| 08 | Deals em risco | `CURRENT_DATE`, `CASE WHEN` |
| 09 | Performance vs meta | `LEFT JOIN`, `COALESCE` |
| 10 | Top empresas por LTV | `DENSE_RANK()`, `SUM() OVER` |

## Dados

Os dados são 100% fictícios, gerados com a biblioteca Faker. Nenhuma informação real de clientes ou empresas foi utilizada.
