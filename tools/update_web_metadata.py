import json
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]
p = ROOT/'app/web/index.html'
t = p.read_text(encoding='utf-8')
t = t.replace('A new Flutter project.','Study the 2025 U.S. citizenship civics test, with Brazilian Portuguese help.').replace('civics_study','U.S. Civics Study')
t = t.replace('<body>','<body style="background:#faf8f4">\n  <noscript>This study app requires JavaScript. Official material: https://www.uscis.gov/citizenship</noscript>')
p.write_text(t,encoding='utf-8')
p = ROOT/'app/web/manifest.json'
j = json.loads(p.read_text())
j.update(name='U.S. Civics Study',short_name='Civics Study',background_color='#faf8f4',theme_color='#203c60',description='2025 Citizenship Test with Portuguese study help.')
p.write_text(json.dumps(j,indent=2)+'\n',encoding='utf-8')
