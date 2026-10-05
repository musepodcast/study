"""Build authored translation/vocabulary JSON from reviewable source files."""
import json
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT/'app/assets/data'
DATA.mkdir(parents=True,exist_ok=True)
translations = {}
for line in (ROOT/'tools/translations_pt.tsv').read_text(encoding='utf-8').splitlines():
    number, question, answers = line.split('\t')
    translations[number] = dict(questionPortuguese=question, answersPortuguese=answers.split('|'))
(DATA/'translations_pt.json').write_text(json.dumps(translations,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
terms = '''Constitution|Constituição|Documento fundamental que estabelece a estrutura do governo e as principais leis do país.
Congress|Congresso|Órgão legislativo federal formado pelo Senado e pela Câmara dos Representantes.
amendment|emenda|Mudança ou acréscimo à Constituição.
rights|direitos|Liberdades e garantias protegidas por lei.
liberty|liberdade|Direito de agir e pensar livremente dentro da lei.
citizen|cidadão|Pessoa que possui a cidadania de um país.
representative|representante|Pessoa eleita para representar os moradores de um distrito na Câmara.
senator|senador|Pessoa eleita para representar um estado no Senado.
governor|governador|Chefe do poder executivo de um estado.
Supreme Court|Suprema Corte|Tribunal mais alto dos Estados Unidos.
Declaration of Independence|Declaração de Independência|Documento de 1776 que declarou a independência das colônias em relação à Grã-Bretanha.
President|presidente|Chefe do poder executivo federal.
Vice President|vice-presidente|Autoridade que assume a presidência se o presidente não puder exercer o cargo.
Speaker|presidente da Câmara|Líder da Câmara dos Representantes; não significa apenas alguém que fala.
vote|votar; voto|Escolher representantes ou decidir uma questão por meio de uma eleição.
law|lei|Regra oficial que deve ser cumprida.
federal|federal|Relativo ao governo nacional dos Estados Unidos.
state|estado|Uma das unidades que compõem os Estados Unidos.
capital|capital|Cidade onde fica a sede do governo; não confundir com dinheiro.
checks and balances|freios e contrapesos|Sistema em que cada poder limita e fiscaliza os demais.
judicial|judiciário|Poder que interpreta as leis e resolve disputas.
executive|executivo|Poder que administra o governo e faz cumprir as leis.
legislative|legislativo|Poder que cria as leis.
term|mandato|Período durante o qual uma pessoa exerce um cargo eletivo.
Cabinet|Gabinete|Grupo de autoridades que aconselha o presidente.
vetoes|veta|Rejeita um projeto de lei antes de sua aprovação final.
Oath of Allegiance|Juramento de Fidelidade|Promessas feitas ao se tornar cidadão dos Estados Unidos.
Pledge of Allegiance|Juramento à Bandeira|Declaração de lealdade aos Estados Unidos e à bandeira.
independence|independência|Condição de um país que governa a si mesmo.
slavery|escravidão|Sistema em que pessoas eram tratadas como propriedade e privadas de liberdade.
Civil War|Guerra Civil|Guerra entre o Norte e o Sul dos EUA, de 1861 a 1865.
Electoral College|Colégio Eleitoral|Sistema que determina a eleição do presidente.
Bill of Rights|Declaração de Direitos|As primeiras dez emendas à Constituição dos EUA.'''
vocabulary = [dict(term=t,translation=p,explanationPortuguese=e) for t,p,e in (line.split('|') for line in terms.splitlines())]
(DATA/'vocabulary_pt.json').write_text(json.dumps(vocabulary,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
