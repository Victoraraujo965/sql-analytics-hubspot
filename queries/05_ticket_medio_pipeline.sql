-- 05_ticket_medio_pipeline.sql
-- Ticket médio, mediana e percentil 90 por pipeline.
-- Técnicas: AVG, PERCENTILE_CONT, MIN, MAX, COUNT

SELECT
    pipeline,
    COUNT(deal_id)                              AS total_deals_ganhos,
    ROUND(AVG(receita_total), 2)                AS ticket_medio,
    ROUND(
        PERCENTILE_CONT(0.5) WITHIN GROUP (
            ORDER BY receita_total
        ), 2
    )                                           AS mediana,
    ROUND(
        PERCENTILE_CONT(0.9) WITHIN GROUP (
            ORDER BY receita_total
        ), 2
    )                                           AS percentil_90,
    ROUND(MIN(receita_total), 2)                AS menor_deal,
    ROUND(MAX(receita_total), 2)                AS maior_deal
FROM deals
WHERE etapa LIKE 'Ganho%'
GROUP BY pipeline
ORDER BY ticket_medio DESC;