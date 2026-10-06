// Optional real-browser smoke test. npm install --prefix tools/browser playwright
// Set BROWSER_PATH to an installed Chromium/Edge executable, then node tools/browser_smoke.cjs.
const { chromium } = require('./browser/node_modules/playwright');
const fs = require('node:fs');
const path = require('node:path');
const assert = require('node:assert/strict');

(async () => {
  const browser = await chromium.launch({headless:true,
    ...(process.env.BROWSER_PATH ? {executablePath:process.env.BROWSER_PATH} : {channel:'chrome'}),
    args:['--use-angle=swiftshader','--enable-unsafe-swiftshader']});
  const context = await browser.newContext({viewport:{width:390,height:844},deviceScaleFactor:1});
  const page = await context.newPage();
  const errors = [], failedRequests = [];
  page.on('pageerror', e => errors.push(String(e)));
  page.on('response', r => {if(r.status() >= 400) failedRequests.push(`${r.status()} ${r.url()}`);});
  const output = path.join(__dirname,'../docs/screenshots');
  fs.mkdirSync(output,{recursive:true});
  async function contentContains(text) {
    await page.waitForFunction(expected => [...document.querySelectorAll('flt-semantics')].some(
      el => el.textContent.includes(expected) || (el.getAttribute('aria-label') || '').includes(expected)),text,{timeout:15000});
  }
  async function open(route) {
    await page.goto(`http://127.0.0.1:8088/study/#${route}`);
    await page.waitForFunction(() => document.querySelector('flt-semantics-placeholder') || document.querySelector('flt-semantics[role="button"]'),{},{timeout:30000});
    if(await page.locator('flt-semantics-placeholder').count()) {
      await page.locator('flt-semantics-placeholder').evaluate(el => el.click());
    }
    await page.getByRole('button',{name:'Configurações',exact:true}).waitFor({timeout:15000});
    await page.waitForTimeout(500);
  }
  try {
    await open('/');
    await page.screenshot({path:path.join(output,'home-390.png')});
    console.log('HOME', (await page.locator('flt-semantics').allTextContents()).join(' ').slice(0,180));
    await open('/question/23');
    assert.equal(await page.getByText('Who',{exact:true}).count(), 0);
    await page.screenshot({path:path.join(output,'listen-first-390.png')});
    await page.getByRole('button',{name:'Revelar pergunta',exact:true}).click();
    await page.getByRole('button',{name:'Revelar resposta',exact:true}).click();
    await page.getByText('Rick', {exact:true}).waitFor();
    await page.evaluate(() => {
      window.__spoken = [];
      window.__rates = [];
      window.__pauses = 0; window.__resumes = 0; window.__stops = 0;
      speechSynthesis.speak = utterance => { window.__lastUtterance = utterance; window.__spoken.push(utterance.text); window.__rates.push(utterance.rate); };
      speechSynthesis.cancel = () => { window.__stops++; };
      speechSynthesis.pause = () => { window.__pauses++; };
      speechSynthesis.resume = () => { window.__resumes++; };
    });
    await page.getByRole('button',{name:'Ouvir pergunta',exact:true}).click();
    await page.waitForFunction(() => window.__spoken.length > 0);
    assert.equal((await page.evaluate(() => window.__spoken))[0], 'Who is one of your state’s U.S. senators now?');
    await page.getByRole('button',{name:'Ocultar pergunta',exact:true}).click();
    assert.equal(await page.getByText('Who',{exact:true}).count(), 0);
    await page.getByRole('button',{name:'Ouvir pergunta',exact:true}).click();
    await page.waitForFunction(() => window.__spoken.length === 2);
    assert.equal(await page.getByText('Who',{exact:true}).count(), 0);
    await page.getByRole('button',{name:'Revelar pergunta',exact:true}).click();
    await page.getByRole('button',{name:'Pausar áudio',exact:true}).first().click();
    await page.getByRole('button',{name:'Continuar áudio',exact:true}).first().click();
    assert.equal(await page.evaluate(() => window.__pauses), 1);
    assert(await page.evaluate(() => window.__resumes) >= 2);
    await page.getByRole('button',{name:'Ouvir resposta',exact:true}).click();
    await page.waitForFunction(() => window.__spoken.length > 2);
    assert((await page.evaluate(() => window.__spoken))[2].includes('Rick Scott'));
    await page.evaluate(() => {
      const event = new Event('error');
      Object.defineProperty(event, 'error', {value:'interrupted'});
      window.__lastUtterance.dispatchEvent(event);
    });
    await page.waitForTimeout(300);
    assert(!(await page.locator('flt-semantics').allTextContents()).join(' ').includes('O áudio não está disponível'));
    console.log('PASS: browser TTS adapter submits official English question and configured answers');
    await page.getByRole('button',{name:'Parar áudio',exact:true}).first().click();
    await page.waitForTimeout(250);
    assert.equal(await page.getByRole('button',{name:'Pausar áudio',exact:true}).count(), 0);
    await page.getByText('Who',{exact:true}).click();
    await page.waitForFunction(() => window.__spoken.at(-1) === 'Who');
    await page.getByRole('button',{name:/1\.0×/}).click();
    await page.getByRole('menuitem',{name:'0.5×',exact:true}).click();
    await page.getByText('Rick',{exact:true}).click();
    await page.waitForFunction(() => window.__spoken.at(-1) === 'Rick');
    assert.equal(await page.evaluate(() => window.__rates.at(-1)), 0.5);
    await page.evaluate(() => window.__lastUtterance.dispatchEvent(new Event('end')));
    await page.waitForTimeout(250);
    assert.equal(await page.getByRole('button',{name:'Pausar áudio',exact:true}).count(), 0);
    console.log('PASS: pause/resume/stop, question and answer word pronunciation, speed, natural completion');
    await page.getByRole('button',{name:'Já sei',exact:true}).click();
    await page.getByRole('button',{name:'Desmarcar já sei',exact:true}).click();
    await page.getByRole('button',{name:'Já sei',exact:true}).click();
    await page.getByRole('button',{name:'Precisa de prática',exact:true}).click();
    await page.getByRole('button',{name:'Desmarcar prática',exact:true}).click();
    await page.getByRole('button',{name:'Favorita',exact:true}).click();
    await page.getByRole('button',{name:'Remover favorita',exact:true}).click();
    await page.screenshot({path:path.join(output,'study-390.png')});
    await page.reload();
    await page.locator('flt-semantics-placeholder').waitFor({timeout:30000});
    await page.locator('flt-semantics-placeholder').evaluate(el => el.click());
    await contentContains('PERGUNTA 23 DE 128');
    await open('/progress');
    await contentContains('1 / 128');
    console.log('PASS: deep-link refresh and browser local-storage persistence');
    for(const width of [360,390,412,768,1440]) {
      await page.setViewportSize({width,height:900});
      await open('/');
      assert(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth));
      await page.screenshot({path:path.join(output,`home-${width}.png`)});
    }
    await open('/test');
    await page.getByRole('button',{name:'Iniciar simulado oficial',exact:true}).click();
    for(let i=0; i<12; i++) {
      assert.equal(await page.getByRole('button',{name:'Revelar pergunta',exact:true}).count(), 1);
      if (i === 0) {
        await page.getByRole('button',{name:'Revelar pergunta',exact:true}).click();
        assert.equal(await page.getByRole('button',{name:'Ocultar pergunta',exact:true}).count(), 1);
      }
      await page.getByRole('button',{name:'Mostrar resposta',exact:true}).click();
      await page.waitForTimeout(250);
      await page.getByRole('button',{name:'Correta',exact:true}).click();
      await page.waitForTimeout(250);
    }
    await contentContains('APROVADO');
    await page.screenshot({path:path.join(output,'passed-desktop.png')});
    assert.deepEqual(errors,[]); assert.deepEqual(failedRequests,[]);
    console.log('PASS: browser startup, all five widths, simulation pass, no JS errors or failed asset requests');
  } catch(e) {
    await page.screenshot({path:path.join(output,'failure.png')});
    console.error((await page.locator('body').innerHTML()).slice(0,5000));
    console.error(e); process.exitCode = 1;
  } finally { await browser.close(); }
})();
