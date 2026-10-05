"""Import official English from the supplied USCIS PDF text; never translate it here.

Extract PDF with pypdf first (see docs/content-maintenance.md). This importer only
normalizes layout whitespace and moves the 65/20 asterisk into metadata.
"""
import hashlib
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / 'app/assets/data'


def official_records():
    text = (ROOT / 'docs/uscis-2025.txt').read_text(encoding='utf-8')
    lines = []
    for line in text.splitlines():
        line = line.strip()
        if not line or re.fullmatch(r'\d+ of 19', line) or line == 'uscis.gov/citizenship':
            continue
        if line in ('AMERICAN GOVERNMENT', 'AMERICAN HISTORY', 'SYMBOLS AND HOLIDAYS'):
            continue
        if re.match(r'^[ABC]: ', line) or line.startswith('For a complete list of tribes'):
            continue
        lines.append(line)
    text = '\n'.join(lines)
    matches = list(re.finditer(r'(?m)^(\d+)\.\s+', text))
    records = []
    for i, match in enumerate(matches):
        number = int(match[1])
        block = text[match.end():matches[i+1].start() if i+1 < len(matches) else len(text)]
        parts = block.split('•')
        question = ' '.join(parts[0].split())
        special = question.endswith('*')
        question = question.removesuffix('*').strip()
        category = ('Principles of American Government' if number <= 15 else
                    'System of Government' if number <= 62 else
                    'Rights and Responsibilities' if number <= 72 else
                    'Colonial Period and Independence' if number <= 89 else
                    '1800s' if number <= 99 else
                    'Recent American History' if number <= 118 else
                    'Symbols' if number <= 124 else 'Holidays')
        records.append(dict(id=f'civics-2025-{number:03}', number=number,
                            questionEnglish=question,
                            answersEnglish=[' '.join(p.split()) for p in parts[1:]],
                            special65_20=special, category=category))
    assert len(records) == 128
    assert [q['number'] for q in records] == list(range(1,129))
    assert sum(q['special65_20'] for q in records) == 20
    return records


if __name__ == '__main__':
    DATA.mkdir(parents=True, exist_ok=True)
    records = official_records()
    translations = json.loads((DATA / 'translations_pt.json').read_text(encoding='utf-8'))
    vocabulary = json.loads((DATA / 'vocabulary_pt.json').read_text(encoding='utf-8'))
    dynamic = {23:'senators', 29:'representative', 30:'speaker', 38:'president',
               39:'vicePresident', 57:'chiefJustice', 61:'governor', 62:'stateCapital'}
    for q in records:
        pt = translations[str(q['number'])]
        assert len(pt['answersPortuguese']) == len(q['answersEnglish']), q['number']
        q.update(pt)
        q['dynamic'] = q['number'] in dynamic
        q['dynamicType'] = dynamic.get(q['number'])
        haystack = (q['questionEnglish'] + ' ' + ' '.join(q['answersEnglish'])).lower()
        q['vocabulary'] = [v['term'] for v in vocabulary if re.search(r'\b'+re.escape(v['term'].lower())+r'\b',haystack)]
    result = dict(version='2025', source='https://www.uscis.gov/sites/default/files/document/questions-and-answers/2025-Civics-Test-128-Questions-and-Answers.pdf',
                  sourceSha256=hashlib.sha256((ROOT/'docs/uscis-2025.pdf').read_bytes()).hexdigest(), questions=records)
    (DATA/'civics_2025.json').write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    print('Imported 128 official questions, 20 special 65/20 questions, and Portuguese translations.')
