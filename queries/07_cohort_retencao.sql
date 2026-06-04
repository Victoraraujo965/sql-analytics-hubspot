-- 07_cohort_retencao.sql
-- Empresas que tiveram mais de um deal ganho — cohort de retenção.
-- Técnicas: CTE encadeada, COUNT, MIN, MAX, DATEDIFF

WITH deals_ganhos AS (
    SELECT
        empresa_id,
        nome_empresa,
        deal_id,
        pipeline,
        receita_total,
        data_fechamento
    FROM deals
    WHERE etapa LIKE 'Ganho%'
),

resumo_empresa AS (
    SELECT
        empresa_id,
        nome_empresa,
        COUNT(deal_id)                          AS total_deals_ganhos,
        MIN(data_fechamento)                    AS primeiro_fechamento,
        MAX(data_fechamento)                    AS ultimo_fechamento,
        SUM(receita_total)                      AS receita_total_acumulada,
        DATEDIFF('day',
            MIN(data_fechamento),
            MAX(data_fechamento)
        )                                       AS dias_entre_deals
    FROM deals_ganhos
    GROUP BY empresa_id, nome_empresa
)

SELECT
    nome_empresa,
    total_deals_ganhos,
    primeiro_fechamento,
    ultimo_fechamento,
    dias_entre_deals,
    ROUND(receita_total_acumulada, 2)           AS receita_total_acumulada
FROM resumo_empresa
WHERE total_deals_ganhos > 1
ORDER BY total_deals_ganhos DESC, receita_total_acumulada DESC;