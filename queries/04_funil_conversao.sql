-- 04_funil_conversao.sql
-- Taxa de conversão entre cada etapa do funil de vendas.
-- Técnicas: CASE WHEN (índice manual), LAG(), ROUND, CTE

WITH etapas_indexadas AS (
    SELECT
        pipeline,
        etapa,
        COUNT(deal_id)                          AS total_deals,
        CASE etapa
            WHEN 'Prospecção'             THEN 1
            WHEN 'Qualificação'           THEN 2
            WHEN 'Proposta enviada'       THEN 3
            WHEN 'Negociação'             THEN 4
            WHEN 'Ganho (CORPORATE)'      THEN 5
            WHEN 'Ganho (MIDDLE)'         THEN 5
            WHEN 'Perdido'                THEN 6
        END                               AS ordem
    FROM deals
    GROUP BY pipeline, etapa
),

funil AS (
    SELECT
        pipeline,
        etapa,
        ordem,
        total_deals,
        LAG(total_deals) OVER (
            PARTITION BY pipeline
            ORDER BY ordem
        )                                       AS deals_etapa_anterior
    FROM etapas_indexadas
)

SELECT
    pipeline,
    ordem,
    etapa,
    total_deals,
    deals_etapa_anterior,
    ROUND(
        total_deals * 100.0 / deals_etapa_anterior, 1
    )                                           AS pct_conversao
FROM funil
ORDER BY pipeline, ordem;