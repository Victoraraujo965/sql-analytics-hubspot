-- 06_tempo_ciclo_venda.sql
-- Tempo médio de ciclo de venda por vendedor e pipeline.
-- Técnicas: AVG, MIN, MAX, FILTER, ORDER BY

SELECT
    pipeline,
    vendedor_nome,
    COUNT(deal_id)                              AS deals_ganhos,
    ROUND(AVG(dias_ciclo), 1)                   AS ciclo_medio_dias,
    MIN(dias_ciclo)                             AS ciclo_minimo,
    MAX(dias_ciclo)                             AS ciclo_maximo,
    ROUND(
        AVG(dias_ciclo) FILTER (
            WHERE dias_ciclo <= 30
        ), 1
    )                                           AS ciclo_medio_rapidos
FROM deals
WHERE etapa LIKE 'Ganho%'
  AND dias_ciclo IS NOT NULL
GROUP BY pipeline, vendedor_nome
ORDER BY pipeline, ciclo_medio_dias;