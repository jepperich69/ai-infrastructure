---
name: Empirical data pipeline status
description: State of the OSM spacing and GTFS frequency pipelines, locked city list, known data quality issues
type: project
---

The empirical pipeline has two scripts in `code/`:

**`download.py`** — OSM stop spacing via Overpass API. 20 km radius, all modes. Outputs `data/<City>_pt_spacing.csv` (seg-level, with lat/lon of each stop pair).

**`download_freq.py`** — GTFS headways via Mobility Database catalog. Outputs `data/<City>_pt_freq.csv`. Key fixes applied 2026-04-08: 4-tier bbox priority filter (blocks globally-corrupt feeds), min-stop_sequence per trip, log header validation.

**Locked 14-city European list** (urban–rural gradient paper):
London, Paris, Lyon, Brussels, Amsterdam, Oslo, Stockholm, Helsinki, Vienna, Prague, Warsaw, Madrid, Lisbon, Copenhagen.

**Known issues to fix before analysis:**
1. Copenhagen Metro (Metroselskabet): 0 active routes in freq data — calendar_dates edge case, needs investigation
2. Berlin/Dresden: GTFS has wrong agency (Brandenburg rural buses, not BVG). Needs direct BVG/VBB download + CITY_FEED_OVERRIDES dict in download_freq.py. (Berlin/Dresden are NOT in the 14-city list but may be added later.)
3. 6 cities dropped from spacing due to sparse OSM (S/R < 15): Houston, Atlanta, Bogota, Bangkok, Mumbai, RioDeJaneiro.

**Next build step:** `code/analyze.py` — join spacing + freq for 14 cities, add distance-from-centre variable, bin by 5 km rings, produce (G, h, d) dataset for urban–rural gradient analysis.

**Why:** The paper is about the spacing–frequency tradeoff and how it varies across the urban–rural gradient. Both datasets needed; the 14-city list was chosen for OSM and GTFS data quality across Europe.
