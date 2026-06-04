"""
generate_mock_data.py
Gera CSVs mockados realistas no formato HubSpot para o projeto SQL Analytics.
Saída: pasta mock/ com 5 arquivos CSV prontos para carregar no DuckDB.
"""

import random
import uuid
from datetime import datetime, timedelta
from pathlib import Path

import pandas as pd
from faker import Faker

fake = Faker("pt_BR")
random.seed(42)
fake.seed_instance(42)

OUTPUT_DIR = Path(__file__).parent / "mock"
OUTPUT_DIR.mkdir(exist_ok=True)

# ── CONFIGURAÇÕES ────────────────────────────────────────────────────────────

PIPELINES = ["CORPORATE", "MIDDLE"]

ETAPAS = {
    "CORPORATE": [
        "Prospecção",
        "Qualificação",
        "Proposta enviada",
        "Negociação",
        "Ganho (CORPORATE)",
        "Perdido",
    ],
    "MIDDLE": [
        "Prospecção",
        "Qualificação",
        "Proposta enviada",
        "Negociação",
        "Ganho (MIDDLE)",
        "Perdido",
    ],
}

# Peso de probabilidade por etapa (maioria fica no topo do funil)
PESOS_ETAPA = [0.30, 0.22, 0.18, 0.12, 0.10, 0.08]

VENDEDORES = [
    {"id": "V001", "nome": "Ana Paula Ferreira",   "vertical": "CORPORATE"},
    {"id": "V002", "nome": "Bruno Carvalho",        "vertical": "CORPORATE"},
    {"id": "V003", "nome": "Carla Mendes",          "vertical": "MIDDLE"},
    {"id": "V004", "nome": "Diego Souza",           "vertical": "MIDDLE"},
    {"id": "V005", "nome": "Fernanda Lima",         "vertical": "CORPORATE"},
    {"id": "V006", "nome": "Gabriel Rocha",         "vertical": "MIDDLE"},
    {"id": "V007", "nome": "Helena Costa",          "vertical": "CORPORATE"},
    {"id": "V008", "nome": "Igor Nascimento",       "vertical": "MIDDLE"},
]

MOTIVOS_PERDA = [
    "Preço alto",
    "Escolheu concorrente",
    "Sem budget",
    "Projeto cancelado",
    "Sem retorno",
]

N_EMPRESAS = 300
N_DEALS    = 800


# ── 1. EMPRESAS ──────────────────────────────────────────────────────────────

def gerar_cnpj():
    nums = [random.randint(0, 9) for _ in range(12)]
    return f"{''.join(map(str, nums[:2]))}.{''.join(map(str, nums[2:5]))}.{''.join(map(str, nums[5:8]))}/{''.join(map(str, nums[8:12]))}-00"

def gerar_empresas(n: int) -> pd.DataFrame:
    segmentos = ["Tecnologia", "Indústria", "Varejo", "Saúde", "Financeiro", "Logística", "Educação"]
    portes    = ["Pequena", "Média", "Grande"]
    registros = []
    for _ in range(n):
        registros.append({
            "empresa_id":  str(uuid.uuid4())[:8].upper(),
            "nome_empresa": fake.company(),
            "cnpj":         gerar_cnpj(),
            "segmento":     random.choice(segmentos),
            "porte":        random.choice(portes),
            "cidade":       fake.city(),
            "estado":       fake.state_abbr(),
            "data_criacao": fake.date_between(start_date="-3y", end_date="-6m"),
        })
    return pd.DataFrame(registros)


# ── 2. VENDEDORES ─────────────────────────────────────────────────────────────

def gerar_vendedores() -> pd.DataFrame:
    return pd.DataFrame(VENDEDORES)


# ── 3. DEALS ─────────────────────────────────────────────────────────────────

def data_aleatoria(inicio_dias_atras: int, fim_dias_atras: int) -> datetime:
    delta = random.randint(fim_dias_atras, inicio_dias_atras)
    return datetime.now() - timedelta(days=delta)

def gerar_deals(n: int, empresas: pd.DataFrame) -> pd.DataFrame:
    registros = []

    for _ in range(n):
        pipeline  = random.choice(PIPELINES)
        etapas    = ETAPAS[pipeline]
        etapa     = random.choices(etapas, weights=PESOS_ETAPA)[0]
        ganho     = "Ganho" in etapa
        perdido   = etapa == "Perdido"

        # Vendedor compatível com o pipeline
        vendedor = random.choice([v for v in VENDEDORES if v["vertical"] == pipeline])

        data_criacao    = data_aleatoria(730, 30)
        dias_duracao    = random.randint(5, 180) if (ganho or perdido) else None
        data_fechamento = (data_criacao + timedelta(days=dias_duracao)) if dias_duracao else None

        # Receita: CORPORATE tickets maiores
        if pipeline == "CORPORATE":
            mrr   = round(random.uniform(5_000,  80_000), 2)
            setup = round(random.uniform(10_000, 150_000), 2)
        else:
            mrr   = round(random.uniform(1_000,  15_000), 2)
            setup = round(random.uniform(2_000,   30_000), 2)

        # Deals perdidos ou em prospecção têm valor 0
        if perdido or etapa == "Prospecção":
            mrr   = 0.0
            setup = 0.0

        empresa = empresas.sample(1).iloc[0]

        registros.append({
            "deal_id":            str(uuid.uuid4())[:10].upper(),
            "empresa_id":         empresa["empresa_id"],
            "nome_empresa":       empresa["nome_empresa"],
            "cnpj":               empresa["cnpj"],
            "pipeline":           pipeline,
            "etapa":              etapa,
            "vendedor_id":        vendedor["id"],
            "vendedor_nome":      vendedor["nome"],
            "data_criacao":       data_criacao.strftime("%Y-%m-%d"),
            "data_fechamento":    data_fechamento.strftime("%Y-%m-%d") if data_fechamento else None,
            "dias_ciclo":         dias_duracao,
            "vl_mrr":             mrr   if ganho else 0.0,
            "vl_setup":           setup if ganho else 0.0,
            "receita_total":      round((mrr + setup), 2) if ganho else 0.0,
            "sigla_proposta":     random.choice(["PROP", "PROP NEOGRID", "PROP PARCEIRO"]),
            "motivo_perda":       random.choice(MOTIVOS_PERDA) if perdido else None,
            "ultima_atualizacao": (data_criacao + timedelta(days=random.randint(0, 60))).strftime("%Y-%m-%d"),
        })

    return pd.DataFrame(registros)


# ── 4. LINE ITEMS ─────────────────────────────────────────────────────────────

def gerar_line_items(deals: pd.DataFrame) -> pd.DataFrame:
    deals_ganhos = deals[deals["vl_mrr"] > 0]
    tipos = ["MRR", "Setup", "Licença", "Implantação", "Suporte"]
    registros = []

    for _, deal in deals_ganhos.iterrows():
        n_itens = random.randint(1, 4)
        for _ in range(n_itens):
            tipo   = random.choice(tipos)
            valor  = round(random.uniform(500, 50_000), 2)
            inc    = round(valor * random.uniform(0, 0.15), 2)
            dec    = round(valor * random.uniform(0, 0.10), 2)
            registros.append({
                "line_item_id":            str(uuid.uuid4())[:8].upper(),
                "deal_id":                 deal["deal_id"],
                "tipo_cobranca":           tipo,
                "valor":                   valor,
                "incremento":              inc,
                "decremento":              dec,
                "valor_liquido":           round(valor + inc - dec, 2),
            })

    return pd.DataFrame(registros)


# ── 5. METAS ──────────────────────────────────────────────────────────────────

def gerar_metas() -> pd.DataFrame:
    quarters = ["Q1", "Q2", "Q3", "Q4"]
    anos     = [2025, 2026]
    registros = []

    for vendedor in VENDEDORES:
        for ano in anos:
            for quarter in quarters:
                base = 200_000 if vendedor["vertical"] == "CORPORATE" else 80_000
                meta = round(base * random.uniform(0.85, 1.30), 2)
                registros.append({
                    "vendedor_id": vendedor["id"],
                    "vendedor_nome": vendedor["nome"],
                    "vertical":    vendedor["vertical"],
                    "ano":         ano,
                    "quarter":     quarter,
                    "meta_receita": meta,
                })

    return pd.DataFrame(registros)


# ── MAIN ──────────────────────────────────────────────────────────────────────

def main():
    print("=" * 60)
    print("GERADOR DE DADOS MOCKADOS — SQL Analytics HubSpot")
    print("=" * 60)

    print("\n[1/5] Gerando empresas...")
    empresas = gerar_empresas(N_EMPRESAS)
    empresas.to_csv(OUTPUT_DIR / "empresas.csv", index=False)
    print(f"      ✓ {len(empresas)} empresas geradas")

    print("[2/5] Gerando vendedores...")
    vendedores = gerar_vendedores()
    vendedores.to_csv(OUTPUT_DIR / "vendedores.csv", index=False)
    print(f"      ✓ {len(vendedores)} vendedores gerados")

    print("[3/5] Gerando deals...")
    deals = gerar_deals(N_DEALS, empresas)
    deals.to_csv(OUTPUT_DIR / "deals.csv", index=False)
    ganhos  = deals[deals["receita_total"] > 0]
    perdidos = deals[deals["etapa"] == "Perdido"]
    print(f"      ✓ {len(deals)} deals gerados")
    print(f"        → {len(ganhos)} ganhos | {len(perdidos)} perdidos")

    print("[4/5] Gerando line items...")
    line_items = gerar_line_items(deals)
    line_items.to_csv(OUTPUT_DIR / "line_items.csv", index=False)
    print(f"      ✓ {len(line_items)} line items gerados")

    print("[5/5] Gerando metas...")
    metas = gerar_metas()
    metas.to_csv(OUTPUT_DIR / "metas.csv", index=False)
    print(f"      ✓ {len(metas)} registros de meta gerados")

    print("\n" + "=" * 60)
    print("RESUMO DOS ARQUIVOS GERADOS")
    print("=" * 60)
    for csv in sorted(OUTPUT_DIR.glob("*.csv")):
        df = pd.read_csv(csv)
        print(f"  {csv.name:<20} {len(df):>5} linhas  ·  {df.shape[1]} colunas")

    print(f"\n✓ Todos os arquivos salvos em: {OUTPUT_DIR.resolve()}")
    print("=" * 60)


if __name__ == "__main__":
    main()