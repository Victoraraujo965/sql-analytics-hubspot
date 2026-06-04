-- 09_performance_vs_meta.sql
-- Performance de cada vendedor vs meta do quarter atual.
-- Técnicas: CTE, JOIN, CASE WHEN, ROUND

WITH quarter_atual AS (
    SELECT
        vendedor_id,
        vendedor_nome,
        vertical,
        meta_receita
    FROM metas
    WHERE ano     = 2026
      AND quarter = 'Q2'
),

receita_realizada AS (
    SELECT
        vendedor_id,
        vendedor_nome,
        pipeline,
        ROUND(SUM(receita_total), 2)            AS receita_realizada
    FROM deals
    WHERE etapa LIKE 'Ganho%'
      AND STRFTIME(data_fechamento, '%Y')  = '2026'
      AND STRFTIME(data_fechamento, '%m') IN ('04', '05', '06')
    GROUP BY vendedor_id, vendedor_nome, pipeline
)

SELECT
    q.vendedor_nome,
    q.vertical,
    q.meta_receita,
    COALESCE(r.receita_realizada, 0)            AS receita_realizada,
    ROUND(
        COALESCE(r.receita_realizada, 0)
        * 100.0 / q.meta_receita, 1
    )                                           AS pct_atingido,
    CASE
        WHEN COALESCE(r.receita_realizada, 0) >= q.meta_receita       THEN 'Bateu meta'
        WHEN COALESCE(r.receita_realizada, 0) >= q.meta_receita * 0.7 THEN 'Perto da meta'
        ELSE                                                                'Abaixo da meta'
    END                                         AS status_meta
FROM quarter_atual q
LEFT JOIN receita_realizada r
    ON q.vendedor_id = r.vendedor_id
ORDER BY pct_atingido DESC;