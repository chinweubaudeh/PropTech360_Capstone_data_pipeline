from pathlib import Path
import csv
import random
from datetime import date, timedelta

rng = random.Random(3602026)
root = Path('data')
raw = root / 'raw'
raw.mkdir(parents=True, exist_ok=True)
for folder in ['quarantine', 'curated']:
    (root / folder).mkdir(parents=True, exist_ok=True)

def write_csv(name, rows):
    path = raw / name
    with path.open('w', newline='', encoding='utf-8') as stream:
        writer = csv.DictWriter(stream, fieldnames=list(rows[0]))
        writer.writeheader()
        writer.writerows(rows)
    print(f'{path}: {len(rows):,} rows')

cities = ['Lagos', 'Abuja', 'Ibadan', 'Port Harcourt']
properties = [dict(property_id=f'P{i:03}', property_name=f'MetroSpace Tower {i:02}',
                   city=cities[(i-1) % len(cities)]) for i in range(1, 13)]
units = []
for p in properties:
    for j in range(1, 21):
        units.append(dict(unit_id=f"{p['property_id']}-U{j:03}", property_id=p['property_id'],
                          floor_area_sqm=rng.choice([45, 60, 75, 90, 120, 150]), active=1))
leases = []
for i, unit in enumerate(units, start=1):
    if rng.random() < 0.22:  # intentionally vacant unit
        continue
    start = date(2025, rng.randint(1, 12), rng.randint(1, 25))
    end = date(2026, rng.randint(3, 12), rng.randint(1, 28)) if rng.random() < 0.27 else None
    leases.append(dict(lease_id=f'L{i:05}', unit_id=unit['unit_id'],
                       start_date=start.isoformat(), end_date=end.isoformat() if end else '',
                       monthly_rent_usd=rng.choice([650, 800, 975, 1200, 1500, 1800, 2200])))
priorities = ['CRITICAL', 'HIGH', 'MEDIUM', 'LOW']
work_orders = []
for i in range(1, 1501):
    unit = rng.choice(units)
    opened = date(2026, rng.randint(1, 6), rng.randint(1, 28))
    resolved = rng.random() < 0.82
    response = round(rng.uniform(1, 96), 1)
    work_orders.append(dict(work_order_id=f'WO{i:06}', unit_id=unit['unit_id'],
        opened_date=opened.isoformat(), closed_date=(opened + timedelta(days=rng.randint(0, 15))).isoformat() if resolved else '',
        priority=rng.choice(priorities), response_hours=response if resolved else '',
        cost_usd=round(rng.uniform(20, 1250), 2), status='RESOLVED' if resolved else 'OPEN'))
months = [f'2026-{m:02}-01' for m in range(1, 7)]
readings = []
for unit in units:
    for month in months:
        readings.append(dict(reading_id=f'R{len(readings)+1:06}', unit_id=unit['unit_id'],
                             reading_month=month, energy_kwh=round(rng.uniform(100, 1250), 2)))
# Known intentionally dirty records; do not remove these from the raw source.
work_orders.append(work_orders[8].copy())                     # exact duplicate
work_orders[34]['unit_id'] = 'P999-U999'                       # unknown parent
work_orders[52]['response_hours'] = ''                         # resolved with missing response
work_orders[63]['cost_usd'] = '-300'                           # invalid negative repair cost
readings[17]['energy_kwh'] = '-45'                             # invalid negative consumption
readings[34]['unit_id'] = 'P999-U999'                           # unknown unit
units.append(units[4].copy())                                 # duplicate identifier
for name, rows in [('properties.csv', properties), ('units.csv', units), ('leases.csv', leases),
                   ('work_orders.csv', work_orders), ('meter_readings.csv', readings)]:
    write_csv(name, rows)
print('Raw fixture ready. Retain a copy before any transformations.')