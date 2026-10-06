# First-version verification — October 4, 2026

**Listening-first update — October 5, 2026:** question text now starts hidden in study and official simulation, with independent question/answer reveal actions. Portuguese question help and vocabulary are gated by question visibility. New widget tests verify hidden audio playback, reveal/hide, answer reveal while the question stays hidden, unchanged progress on question reveal, and reset after study navigation and test grading. All **34 tests**, dependency resolution, formatting, analysis, official-content validation, and the release web build pass on Windows. Headless Edge confirms hidden questions have no word controls until revealed, question audio works while hidden, single-word pronunciation and playback controls still work, and every simulation question resets to hidden. Browser reload/persistence, five widths, and the official pass flow also pass with no JavaScript errors or failed assets. The 390px hidden-question screenshot was visually reviewed. Changes remain local, with no version bump, commit, or push.

**Local audio and study-control update:** dependency resolution, formatting, analysis, all **32 tests**, official-content validation, and the `/study/` release build pass on Windows. Added tests cover word hit testing, pause/resume/stop UI, selected speed, legacy speed migration, undo persistence without losing study counts, native plugin method calls, and stopping during native configuration. Headless Edge confirms the browser adapter submits question/answer/individual-word text at the selected rate; pause, resume, cancellation, and natural completion update controls correctly. Undo actions, saved progress, five viewport widths, deep-link refresh, and the official 12-correct pass flow also pass, with no JavaScript errors or failed asset requests. Browser speech methods are intercepted for deterministic checks; audible playback and physical Android/iOS pause behavior remain device checks. Changes are local, with the release version unchanged; no commit or production push was performed for this update.

Workspace: `C:\Users\isaac\test_dev\study`, branch `test_dev` (initial repository, no commits yet). Flutter 3.41.6 / Dart 3.11.4. One app source tree; production is not published by this task.

**Subsequent changes verified on Windows:** after the initial results below, the user reported unavailable audio in Windows Chrome/Edge and requested a Portuguese-default interface. The source now uses direct browser speech synthesis, fresh utterances, local English voice preference, and ignores expected interruption/cancellation. The interface defaults to pt-BR with a persisted English setting; official study content is kept separate. Dependency resolution, formatting, analysis, all **28 tests**, official-content validation, and the release web build now pass. The language persistence widget test creates its controller in the test zone before initializing file assets with `runAsync`, keeping its persistence future in the correct zone. The release artifact includes `index.html` with `/study/` base href. The table below retains the initial build's results; browser audio interruption checks and Docker checks have not been rerun for the later changes.

| Check | Result |
| --- | --- |
| Flutter project targets | Web, Android, and iOS generated |
| `flutter pub get` | Passed on Windows and in Docker |
| `dart format` and format validation | Passed |
| `flutter analyze` | No issues, Windows and Docker |
| `flutter test` | **25 tests passed**, Windows and Docker |
| `python tools/validate_data.py` | Passed, host and Docker |
| Official question count/uniqueness | Exactly 128 IDs and numbers, 1–128 |
| English source fidelity | Every question and accepted answer bullet matches source text after documented whitespace normalization |
| Independent PDF extraction | Archived text matches a fresh extraction of the supplied PDF exactly |
| Portuguese | All 128 questions and every corresponding answer bullet populated; UTF-8 audit passed |
| 65/20 | All 20 official starred markings verified against PDF |
| Location/current configuration | Pensacola, Escambia County, Florida, FL-01, Tallahassee; separate verified officials data |
| Simulation scoring | No duplicate selections, pass at 12, fail on mathematical impossibility, maximum 20; tested over 200 randomized scoring runs |
| Extra practice | All seven collections tested for correct size and ordering selection |
| Local persistence | Serialization/reload, favorites, statuses, history, reset/cancel, storage failure; browser reload confirmed |
| Mobile/tablet/desktop | All six screens tested at 360/390/412/768/1440px; bilingual long answers; 360px dark theme with 150% text |
| Real browser | Headless Microsoft Edge startup, five viewport screenshots, official simulation pass, deep-link refresh, stored progress; no JavaScript errors or failed asset requests |
| Browser audio adapter | Actual Flutter web adapter submits the official English question and configured answers to intercepted browser speech synthesis |
| Production web build | Release `/study/` build passed on Windows and in Docker |
| GitHub workflows | YAML parsed; CI branch triggers, main-only deployment job guards, artifact path and permissions checked |
| VS Code/native metadata | JSON, Android manifest/TTS service query, iOS plist parsed and checked |
| Docker | Compose configuration, image build, pub get, analysis, all tests, data validation, web release build passed |

The visual review used actual browser screenshots of the phone study screen and phone/desktop home layouts. Generated screenshots and browser tooling are ignored by Git. To reproduce the optional browser smoke test:

```sh
npm install --prefix tools/browser playwright
python tools/serve_preview.py
# In a second terminal, with Chrome installed:
node tools/browser_smoke.cjs
```

For Edge or another installed Chromium executable, set `BROWSER_PATH` first. On Windows PowerShell:

```powershell
$env:BROWSER_PATH = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
node tools/browser_smoke.cjs
```

The preview serves localhost:8088 beneath `/study/`, matching production. The browser script uses a fresh temporary profile and leaves its test progress isolated from normal user profiles. It enables Flutter's accessibility semantics for automated navigation.

Remaining environment/product limits:

- Android and iOS source exists, but physical Samsung/iPhone execution and native release signing/builds were not performed. iOS signing requires macOS/Xcode.
- Audio invocation and failure fallback were verified; audible output on a real phone depends on available device voices. Browser speech was intercepted for the deterministic smoke test.
- `flutter_tts` emits WebAssembly dry-run compatibility warnings. The successful production build uses Flutter's default JavaScript target; `--wasm` is not supported by this v1 dependency combination.
- Portuguese is unofficial, authored assistance with an obvious-error review, not a certified translation; a native-speaker review is advisable before broad distribution.
- No runtime official updates, cloud synchronization, speech-recognition grading, or cold-offline guarantee. The 65/20 collection is study-only.
- GitHub Actions/Pages configuration now deploys from `test_dev` per the user's preference. Remote CI/deployment was not run by this task. Enable Pages with GitHub Actions and allow `test_dev` in any `github-pages` environment branch restrictions before pushing.

The USCIS endpoint returned HTTP 403 during retrieval; the user-supplied USCIS PDF was archived and used as the canonical source. Current officeholders were checked against the government links in [content maintenance](content-maintenance.md).
