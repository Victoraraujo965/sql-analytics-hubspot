-- 01_ranking_vendedores.sql
-- Ranking de vendedores por receita total em deals ganhos.
-- Técnicas: GROUP BY, SUM, RANK() OVER (ORDER BY)

WITH receita_por_vendedor AS (
    SELECT
        vendedor_id,
        vendedor_nome,
        pipeline                        AS linha_de_negocio,
        COUNT(deal_id)                  AS total_deals_ganhos,
        SUM(vl_mrr)                     AS total_mrr,
        SUM(vl_setup)                   AS total_setup,
        SUM(receita_total)              AS receita_total
    FROM deals
    WHERE etapa LIKE 'Ganho%'   -- 'Ganho (CORPORATE)' e 'Ganho (MIDDLE)'
    GROUP BY vendedor_id, vendedor_nome, pipeline
)

SELECT
    RANK() OVER (ORDER BY receita_total DESC)   AS posicao,
    vendedor_nome,
    linha_de_negocio,
    total_deals_ganhos,
    total_mrr,
    total_setup,
    receita_total
FROM receita_por_vendedor
ORDER BY posicao;