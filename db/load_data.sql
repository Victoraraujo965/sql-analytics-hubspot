INSERT INTO empresas   SELECT * FROM read_csv_auto('data/mock/mock/empresas.csv');
INSERT INTO vendedores SELECT * FROM read_csv_auto('data/mock/mock/vendedores.csv');
INSERT INTO deals      SELECT * FROM read_csv_auto('data/mock/mock/deals.csv');
INSERT INTO line_items SELECT * FROM read_csv_auto('data/mock/mock/line_items.csv');
INSERT INTO metas      SELECT * FROM read_csv_auto('data/mock/mock/metas.csv');