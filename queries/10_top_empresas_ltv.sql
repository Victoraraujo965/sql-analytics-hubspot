-- 10_top_empresas_ltv.sql
-- Top empresas por LTV (receita acumulada) com ranking global e por segmento.
-- Técnicas: SUM() OVER, DENSE_RANK(), PARTITION BY, CTE

WITH ltv_empresa AS (
    SELECT
        d.empresa_id,
        d.nome_empresa,
        e.segmento,
        e.porte,
        COUNT(d.deal_id)                        AS total_deals_ganhos,
        ROUND(SUM(d.receita_total), 2)          AS ltv_total
    FROM deals d
    JOIN empresas e
        ON d.empresa_id = e.empresa_id
    WHERE d.etapa LIKE 'Ganho%'
    GROUP BY d.empresa_id, d.nome_empresa, e.segmento, e.porte
)

SELECT
    nome_empresa,
    segmento,
    porte,
    total_deals_ganhos,
    ltv_total,
    DENSE_RANK() OVER (
        ORDER BY ltv_total DESC
    )                                           AS ranking_global,
    DENSE_RANK() OVER (
        PARTITION BY segmento
        ORDER BY ltv_total DESC
    )                                           AS ranking_por_segmento,
    ROUND(
        ltv_total * 100.0 / SUM(ltv_total) OVER (), 2
    )                                           AS pct_receita_total
FROM ltv_empresa
ORDER BY ranking_global;