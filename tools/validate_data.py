"""Validate all content and compare every official English field to source text.

Uses only Python's standard library. Run from any directory.
"""
import hashlib
import json
from pathlib import Path
from import_civics import official_records

ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT/'app/assets/data'


def load(name):
    return json.loads((DATA/f'{name}.json').read_text(encoding='utf-8'))


def validate():
    data = load('civics_2025')
    assert data['version'] == '2025'
    assert data['source'].startswith('https://www.uscis.gov/')
    assert data['sourceSha256'] == hashlib.sha256((ROOT/'docs/uscis-2025.pdf').read_bytes()).hexdigest(), 'Source PDF changed'
    questions = data['questions']
    assert len(questions) == 128, 'Expected exactly 128 questions'
    assert len({q['id'] for q in questions}) == 128, 'Duplicate IDs'
    assert {q['number'] for q in questions} == set(range(1,129)), 'Missing/duplicate numbers'
    assert sum(q['special65_20'] for q in questions) == 20
    translations = load('translations_pt')
    vocabulary = load('vocabulary_pt')
    terms = {v['term'] for v in vocabulary}
    assert len(terms) == len(vocabulary)
    for v in vocabulary:
        assert all(isinstance(v[k],str) and v[k].strip() for k in ['term','translation','explanationPortuguese'])
    canonical = {q['number']:q for q in official_records()}
    expected_dynamic = {23:'senators',29:'representative',30:'speaker',38:'president',39:'vicePresident',57:'chiefJustice',61:'governor',62:'stateCapital'}
    for q in questions:
        n = q['number']
        for key,value in canonical[n].items():
            assert q[key] == value, f'Official source mismatch: question {n}, {key}'
        assert q['id'] == f'civics-2025-{n:03}'
        assert isinstance(q['dynamic'],bool) and isinstance(q['special65_20'],bool)
        assert q['dynamic'] == (n in expected_dynamic)
        assert q['dynamicType'] == expected_dynamic.get(n)
        assert q['questionEnglish'].strip() and q['questionPortuguese'].strip()
        assert len(q['answersEnglish']) == len(q['answersPortuguese']) > 0
        assert all(isinstance(a,str) and a.strip() for a in q['answersEnglish']+q['answersPortuguese'])
        assert q['questionPortuguese'] == translations[str(n)]['questionPortuguese']
        assert q['answersPortuguese'] == translations[str(n)]['answersPortuguese']
        assert set(q['vocabulary']) <= terms
        assert '\ufffd' not in json.dumps(q,ensure_ascii=False), f'Bad Unicode: {n}'
    location = load('location_profile')
    for key in ['city','county','state','stateCode','congressionalDistrict','stateCapital']:
        assert isinstance(location[key],str) and location[key].strip()
    current = load('dynamic_answers')
    assert len(current['verifiedOn']) == 10
    assert set(current['answers']) == set(expected_dynamic.values())-{'stateCapital'}
    for key,value in current['answers'].items():
        assert len(value['english']) == len(value['portuguese']) > 0, key
        assert all(isinstance(a,str) and a.strip() for a in value['english']+value['portuguese'])
        assert value['source'].startswith('https://')
    print('PASS: 128 unique official questions; all English answers match source; complete Portuguese; 20 correct 65/20 markings; vocabulary and current/location configuration valid.')


if __name__ == '__main__':
    validate()
