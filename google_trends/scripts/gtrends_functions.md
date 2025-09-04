# **gtrends_functions_verbose** – Developer Guide
Robust Google-Trends downloader with automatic retries, polite throttling and real-time console feedback.

---

## 1 . Overview
`gtrends_functions_verbose.py` wraps **pytrends** with an exponential-back-off retry strategy (powered by **tenacity**) so your script can keep downloading keywords even when Google throws transient *HTTP 429* or network errors.  
A single, reusable `TrendReq` session is shared across the whole run, and the helper prints progress for every batch *and* every keyword so you always know what is happening.

---

## 2 . Key Features

| Feature | Where implemented |
|---------|------------------|
| Custom **User-Agent** & builtin urllib3 back-off | `USER_AGENT`, `_make_trend_session()` |
| Exponential retry on 429 / network faults | `_tenacity_retry()` decorator |
| Batch request (≤ 5 keywords) with progress messages | `_interest_over_time()` |
| High-level orchestration & CSV export | `busqueda_google_trends()` |

---

## 3 . Dependencies

```text
pandas
requests
pytrends >= 4.9.0
tenacity
