-- 02_cohort_deals.sql
-- Cohort de deals por mês de criação.
-- Técnicas: STRFTIME, GROUP BY, COUNT condicional com FILTER, CTE

WITH cohort AS (
    SELECT
        STRFTIME(data_criacao, '%Y-%m')             AS cohort_mes,
        COUNT(deal_id)                              AS total_deals,
        COUNT(deal_id) FILTER (
            WHERE etapa LIKE 'Ganho%'
        )                                           AS deals_ganhos,
        COUNT(deal_id) FILTER (
            WHERE etapa = 'Perdido'
        )                                           AS deals_perdidos,
        ROUND(SUM(receita_total), 2)                AS receita_gerada
    FROM deals
    GROUP BY cohort_mes
)

SELECT
    cohort_mes,
    total_deals,
    deals_ganhos,
    deals_perdidos,
    total_deals - deals_ganhos - deals_perdidos     AS em_aberto,
    ROUND(
        deals_ganhos * 100.0 / total_deals, 1
    )                                               AS pct_conversao,
    receita_gerada
FROM cohort
ORDER BY cohort_mes;