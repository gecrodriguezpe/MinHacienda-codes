# gtrends_functions_verbose.py
# ------------------------------------------------------------
# Robust Google-Trends downloader with tenacity-based retries
#       + consola “human friendly” para saber qué se descarga
# ------------------------------------------------------------
import logging
import time
from pathlib import Path
from typing import List

import pandas as pd
import requests
from pytrends.request import TrendReq
from pytrends.exceptions import TooManyRequestsError
from tenacity import (
    retry,
    retry_if_exception_type,
    stop_after_attempt,
    wait_exponential,
)

# ---------- CONSTANTS & GLOBAL CONFIG --------------------------------------

USER_AGENT = (
    "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 "
    "(KHTML, like Gecko) Chrome/116.0 Safari/537.36"
)
RESBACKOFF_FACTOR = 0.5
MAX_ATTEMPTS = 7  # 1 original + 6 reintentos

# ---------- TrendReq FACTORY -----------------------------------------------

def _make_trend_session() -> TrendReq:
    return TrendReq(
        hl="es-419",
        tz=360,
        retries=3,                        # extra safety inside pytrends
        backoff_factor=RESBACKOFF_FACTOR, # “resbackoff_factor”
        timeout=(10, 25),
        requests_args={"headers": {"User-Agent": USER_AGENT}},
    )

_PYTRENDS = _make_trend_session()        # sesión reutilizable

# ---------- LOW-LEVEL CALL WITH TENACITY -----------------------------------

def _tenacity_retry():
    return retry(
        retry=retry_if_exception_type(
            (TooManyRequestsError, requests.exceptions.RequestException)
        ),
        wait=wait_exponential(multiplier=60, min=60, max=1_800),
        stop=stop_after_attempt(MAX_ATTEMPTS),
        reraise=True,
    )

@_tenacity_retry()
def _interest_over_time(kw_batch: List[str]) -> pd.DataFrame:
    # ↳ Mensaje de consola para todo el batch
    print(f"📥 Consultando batch: {', '.join(kw_batch)}")
    _PYTRENDS.build_payload(kw_list=kw_batch, timeframe="today 5-y")
    return _PYTRENDS.interest_over_time()

# ---------- PUBLIC API ------------------------------------------------------

def busqueda_google_trends(
    input_file: str | Path,
    output_file: str | Path,
    sector_name: str,
    group_size: int = 5,
    words_before_stop: int = 1,
    slp_time_words: int = 30,
    slp_time_groups: int = 60,
) -> None:

    # 1. Leer palabras clave
    df_keywords = pd.read_excel(input_file, sheet_name=sector_name)
    kw_list = df_keywords["palabra"].dropna().astype(str).tolist()
    total = len(kw_list)

    logging.info("Sector %s → %d keywords", sector_name, total)
    print(f"=== {sector_name}: {total} palabras ===")

    # 2. Descargar por batches
    collected_frames: list[pd.DataFrame] = []
    for i in range(0, total, group_size):
        batch = kw_list[i : i + group_size]
        batch_id = i // group_size + 1
        print(f"\n🗂️  Batch {batch_id}  ({i + 1}-{i + len(batch)} de {total})")

        # Mensaje por palabra (opcional; comenta si fuera demasiado verboso)
        for w in batch:
            print(f"   → Buscando: {w}")

        try:
            df_batch = _interest_over_time(batch)
            collected_frames.append(df_batch)
            print("   ✓ Batch descargado\n")
        except Exception as err:
            logging.error("Failed after retries: %s", err)
            raise

        # Pausas amistosas
        if i + group_size < total:                # (no dormir tras el último)
            time.sleep(slp_time_words)

        if words_before_stop and batch_id % words_before_stop == 0:
            print(f"⏸  Pausa de grupo {slp_time_groups}s")
            time.sleep(slp_time_groups)

    # 3. Guardar resultados
    final_df = pd.concat(collected_frames, axis=1)
    final_df.to_csv(output_file)
    logging.info("✓ Saved %s", output_file)
    print(f"\n🎉 Descarga terminada: {output_file}")

# ---------- CLI para smoke-test ---------------------------------------------

if __name__ == "__main__":
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s [%(levelname)s] %(message)s",
        datefmt="%H:%M:%S",
    )
    busqueda_google_trends(
        input_file="bases_de_datos/input/gtrends_input.xlsx",
        output_file="bases_de_datos/output/pib_agregado_gtrends.csv",
        sector_name="PIB_agregado",
    )
