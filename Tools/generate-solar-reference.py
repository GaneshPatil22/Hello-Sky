#!/usr/bin/env python3
"""Regenerate the solar reference fixtures used by SkyCoreTests.

The engine is checked against `astral`, an independent implementation, rather
than against itself. Run this when the fixture cities or dates change:

    python3 -m venv .venv && .venv/bin/pip install astral
    .venv/bin/python Tools/generate-solar-reference.py \
        > Packages/SkyCore/Tests/SkyCoreTests/Fixtures/solar-reference.json
"""
import datetime, json, zoneinfo
from astral import LocationInfo, sun

CITIES = [
    ("london","London",51.51,-0.13,"Europe/London"),
    ("new-york","New York",40.71,-74.0,"America/New_York"),
    ("sydney","Sydney",-33.87,151.21,"Australia/Sydney"),
    ("tokyo","Tokyo",35.68,139.69,"Asia/Tokyo"),
    ("rio-de-janeiro","Rio de Janeiro",-22.91,-43.17,"America/Sao_Paulo"),
    ("nairobi","Nairobi",-1.29,36.82,"Africa/Nairobi"),
    ("reykjavik","Reykjavik",64.15,-21.94,"Atlantic/Reykjavik"),
    ("mumbai","Mumbai",19.08,72.88,"Asia/Kolkata"),
    ("kathmandu","Kathmandu",27.72,85.32,"Asia/Kathmandu"),
]
# Solstices, equinoxes, a leap day, and a DST-transition weekend.
DATES = ["2026-03-20","2026-06-21","2026-09-22","2026-12-21","2028-02-29","2026-10-22","2026-03-29","2026-11-01"]

rows=[]
for cid,name,lat,lon,tz in CITIES:
    obs = LocationInfo(name, "", tz, lat, lon).observer
    for d in DATES:
        day = datetime.date.fromisoformat(d)
        zone = zoneinfo.ZoneInfo(tz)
        try:
            # tzinfo makes astral resolve the events for the LOCAL date, so
            # sunrise always precedes sunset. Without it both are taken from the
            # UTC date and can come back in the wrong order.
            rise = sun.sunrise(obs, day, tzinfo=zone).astimezone(datetime.timezone.utc)
            sset = sun.sunset(obs, day, tzinfo=zone).astimezone(datetime.timezone.utc)
            if sset < rise:
                # Near the Arctic circle the sunset that ends this local day
                # falls just after local midnight, so it belongs to the next date.
                nxt = day + datetime.timedelta(days=1)
                sset = sun.sunset(obs, nxt, tzinfo=zone).astimezone(datetime.timezone.utc)
            noon = sun.noon(obs, day, tzinfo=zone).astimezone(datetime.timezone.utc)
        except ValueError:
            continue
        assert rise < noon < sset, (cid, d, rise, noon, sset)
        rows.append({"city":cid,"date":d,
                     "sunrise":rise.isoformat().replace("+00:00","Z"),
                     "sunset":sset.isoformat().replace("+00:00","Z"),
                     "noon":noon.isoformat().replace("+00:00","Z"),
                     "latitude":lat,"longitude":lon})
print(json.dumps(rows, indent=2))
