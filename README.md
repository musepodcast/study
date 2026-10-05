# U.S. Civics Study

A calm, mobile-first Flutter app for the **USCIS 2025 citizenship civics test**, built for a Brazilian Portuguese-speaking learner in Pensacola, Florida. Official English comes first; Portuguese is study assistance. The app runs entirely on the device, without accounts or a backend.

Production target: **https://musepodcast.github.io/study/**. Development and production both use `test_dev`: pushing this branch publishes the app after validation passes. This repository contains one source tree.

## Features

- All 128 official questions and accepted English answer bullets from the supplied USCIS PDF, with Brazilian Portuguese translations of every question and answer.
- Flash cards, restrained reveal animation, official/random order, favorites, mastered and Needs Practice status.
- English Only, English + Portuguese, and Portuguese Help on Tap (default); reusable vocabulary help.
- Brazilian Portuguese menus and controls by default; switch the interface to English in Settings → App language. This preference is saved independently of study help. Existing saved settings migrate without deleting progress.
- Device/browser English speech, repeat, answer audio, normal/slow rates, and graceful fallback.
- Oral, self-graded **OFFICIAL TEST SIMULATION**: 20 unique random questions maximum, immediate pass at 12 correct, immediate failure once passing is impossible.
- Extra flash-card collections: Random 10/20, all 128 random/in order, favorites, Needs Practice, and the 20 starred 65/20 questions.
- Question search, category/status filters, progress dashboard, test history, and confirmed reset.
- Material 3 light/dark/system themes, responsive constrained layouts, accessible controls and text scaling.

## Requirements and setup

Use Flutter **3.41.6 stable** (Dart 3.11), Git, and Python 3.12+ for data validation. Android development also needs Android Studio/SDK and an emulator or USB-connected device. iOS builds require macOS, Xcode, and its toolchain; signing requires an Apple developer setup. Docker Desktop with Linux containers is an alternative for web builds/tests.

From the repository root:

```sh
git switch test_dev
cd app
flutter pub get
flutter run -d chrome
```

For Android, enable USB debugging or start an emulator, run `flutter devices`, then `flutter run -d <android-device-id>` from `app/`. On macOS, open an iOS simulator and use `flutter run -d <ios-device-id>`. Flutter generated standard `android/` and `ios/` targets; review application IDs and release signing before store distribution. Android release defaults are not production signing credentials.

VS Code: open the repository root, install the Dart and Flutter extensions, choose **Run Flutter Web** or **Run Flutter Android** in Run and Debug. For Android, select your emulator/device in the status bar first. Tasks provide pub get, analysis, testing, content validation, and both web build variants. Paths are portable.

## Verify and build

```sh
cd app
flutter pub get
dart format lib test
flutter analyze
flutter test
flutter build web --release --base-href /study/ --no-web-resources-cdn
cd ..
python tools/validate_data.py
```

`app/build/web` is the static release. Use a static server that maps it under `/study/`, or run Flutter locally with `flutter run -d chrome`. For root-hosted deployments, omit `--base-href /study/`. `--no-web-resources-cdn` packages renderer resources with the site, avoiding runtime renderer CDN requests. No custom service worker is installed, and a cold offline load is not guaranteed.

Tests cover content parsing, malformed records, counts/unique IDs/numbers, translations, 65/20 markings, dynamic/location answers and fallback, randomized official scoring, serialization/reload, storage failure, study rendering, vocabulary, audio fallback, simulation history, search, reset confirmation, themes, and layouts at 360/390/412/768/1440px with enlarged text.

## Docker

The Dockerfile builds a pinned Flutter environment from the official Flutter Git repository on Ubuntu. No backend/database containers exist. From the repository root:

```sh
docker compose build
docker compose run --rm flutter flutter pub get
docker compose run --rm flutter flutter analyze
docker compose run --rm flutter flutter test
docker compose run --rm flutter python3 ../tools/validate_data.py
docker compose run --rm flutter flutter build web --release --base-href /study/ --no-web-resources-cdn
docker compose run --rm --service-ports flutter flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080
```

Open localhost:8080 for the last command. Docker needs network access on first build/pub get. Named volumes isolate Linux pub cache and `.dart_tool` from the host SDK; run `flutter pub get` when changing environments. Generated builds appear on the host under `app/build`. Docker supports web development/testing/builds; it does not run Xcode or sign iOS apps. Signed iOS builds require macOS/Xcode.

## Architecture and repository layout

```text
app/lib/
  app/             Application routing and ChangeNotifier controller
  core/            Pure official-test business logic
  models/          Questions, settings, progress, test results
  repositories/    ContentRepository and asset implementation
  services/        StorageService and SpeechService interfaces/adapters
  screens/         Home, study, test, questions, progress, settings
  widgets/         Cards, audio, navigation, notices, reset
  theme/           Shared Material 3 theme
app/assets/data/   Official content, translations, vocabulary, configuration
app/test/          Unit and widget tests
app/web/           Static web host and app icons
app/android/       Standard Android source
app/ios/           Standard iOS source
docs/              Source PDF/text, content maintenance, verification
tools/             Import, validation, authored translation/vocabulary sources
.github/workflows/ CI and production-only Pages deployment
.vscode/           Portable development settings, launchers, tasks
```

UI talks to a small `StudyController`. Content loading, local persistence, and speech are behind interfaces that tests replace. Future FastAPI accounts, content management, analytics, or synchronization can replace/add repository adapters while retaining UI and scoring logic. No backend is implemented or required.

Dependencies: `shared_preferences` uses platform-supported local preferences/browser storage through a service; `flutter_tts` provides native/browser speech; `url_launcher` opens the USCIS source; `cupertino_icons` supplies Flutter's default iOS navigation icons. Flutter's built-in ChangeNotifier handles state. `pubspec.lock` is included for reproducible application dependencies.

## Content, Portuguese, and configured answers

`app/assets/data/civics_2025.json` contains official English plus clearly named Portuguese fields, category, dynamic metadata, vocabulary references, and 65/20 flags. English is imported directly from `docs/uscis-2025.txt`, extracted from the user-supplied official PDF. Layout whitespace is normalized; the trailing asterisk becomes `special65_20`. All official answer bullets, including bracketed acceptance guidance and optional wording, are preserved. Dynamic placeholders are never overwritten in the official data.

Authored Portuguese translations live separately in `translations_pt.json`, with their reviewable source in `tools/translations_pt.tsv`. `vocabulary_pt.json` is reusable term/translation/explanation data. Relevant terms appear as tappable chips in study; vocabulary is hidden in English Only and in official simulation. `tools/build_support_data.py` regenerates translation/vocabulary JSON from authored sources; `tools/import_civics.py` combines them into the app bundle. See [content maintenance](docs/content-maintenance.md) before updating anything.

Location is in `location_profile.json`: Pensacola, Escambia County, Florida, FL-01, Tallahassee. Current national/state officeholders are in `dynamic_answers.json`, with a verification date and authoritative source URLs. Initial Florida answers: **Jimmy Patronis**, **Rick Scott**, **Ashley Moody**, **Ron DeSantis**. National answers: Donald J. Trump, JD Vance, Mike Johnson, John G. Roberts, Jr.; verified against government sources on October 4, 2026. Change an official's English/Portuguese arrays and verification date in that file, validate, and rebuild; no widget edits are needed. Change state capital and learner location in the location file, and update the corresponding officials together when moving. Names are static, never scraped at runtime.

The UI labels configured current answers separately and shows the configured location for local questions. If a config file is missing, official placeholder guidance is shown with a fallback message; the app remains usable. Applicants must give the official in office **at their interview**, so verify these values again before the interview.

## Audio and local progress

Speech is initiated by a user tap, prefers en-US with an installed voice, and falls back to the device default. Web uses the browser Speech Synthesis API directly, with a fresh utterance per tap and synchronous initiation to preserve browser user activation. Native Android/iOS uses `flutter_tts`. Expected cancellation during repeat/navigation does not show an unavailable-audio message. No prerecorded MP3s or cloud audio service are needed. Download an English voice on Android for offline speech; browser/device voice behavior varies. Missing or failing TTS leaves all written content usable.

Progress/settings are serialized together under `civics_study.v1`. Queued writes preserve the order of updates. Favorites alone do not mark questions studied; revealing a study answer or grading a simulation does. Storage read/write errors show a notice while keeping the session usable. Completed official simulations are stored once; unfinished tests are not recorded. Scores are correct/actually asked, and the dashboard averages those percentages. Reset deletes progress/favorites/history after confirmation and retains settings. Data is device/browser-specific and is lost if the user clears app/browser storage. There is no cloud sync/export in v1.

## GitHub workflow and Pages

Feature work integrates into `test_dev`; CI runs on pull requests and pushes to `test_dev`/`main`, checking formatting, analysis, tests, data, and a release build. Pushing `test_dev` also runs the production Pages workflow. No merge into `main` is required, and neither workflow merges branches automatically.

To enable production, select **Settings → Pages → Source: GitHub Actions** in GitHub. If the `github-pages` environment has a deployment branch restriction, permit `test_dev`. `pages.yml` runs on a `test_dev` push (or manual invocation on `test_dev`), repeats validation before building with `/study/`, uploads the static artifact, and deploys via supported GitHub Pages actions. The job condition rejects manual runs on other branches. A failed validation stops deployment and keeps the previous successful website published.

Commit and publish from the repository root:

```sh
git switch test_dev
git add .
git commit -m "Update civics study app"
git push -u origin test_dev
```

Wait for **Production GitHub Pages** to succeed in the repository's Actions tab, then open **https://musepodcast.github.io/study/**.

If you see a GitHub Pages 404, open the full `/study/` address, confirm `.github/workflows/pages.yml` has been committed and pushed, and check that its deployment job succeeded in Actions. Pages must use **GitHub Actions**, rather than publishing the repository root from a branch: the deployable `index.html` is generated in `app/build/web`, not stored at the repository root.

Flutter's default **hash routing** is retained: `/study/#/study`, `#/test`, `#/questions`, `#/progress`, `#/settings`, and `#/question/23`. Refreshing these routes requests the static index and avoids GitHub Pages 404s. Extra filtered practice collections are session navigation arguments; a refresh opens default Study instead of preserving the temporary collection.

## Limitations and disclaimer

- Official test simulation is self-graded, without speech recognition. Follow the requested number of answers when checking yourself.
- 65/20 support is a study filter/collection, not a special scoring simulator. Eligible applicants use the USCIS 10-question/6-correct special test; the standard simulator always uses 20/12 rules.
- Portuguese translations are unofficial, authored study help and should receive a native-speaker review before a broad release. They never replace official English.
- Physical Android/iOS testing, store signing, and Docker execution depend on those environments; see [verification](docs/verification.md) for checks actually performed.
- The production build uses Flutter's default JavaScript target. The TTS package emits WebAssembly dry-run warnings; a `--wasm` build is not supported by this v1 dependency combination.
- Current officials require manual updates, progress has no cloud backup, and initial loading requires the static site to be available.

This study tool is not affiliated with or endorsed by U.S. Citizenship and Immigration Services. Official civics questions and answers are sourced from USCIS. [Official 2025 questions and answers](https://www.uscis.gov/sites/default/files/document/questions-and-answers/2025-Civics-Test-128-Questions-and-Answers.pdf).
