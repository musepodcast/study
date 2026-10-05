# Repository instructions

Read these instructions and README.md before modifying anything.

- Protect official USCIS English wording. Never silently rewrite questions or invent accepted answers. The source PDF and extracted text in docs/ are authoritative; only layout whitespace and the separate asterisk metadata are normalized.
- Keep Brazilian Portuguese assistance separate from official English. Content belongs in assets/data, never in widgets.
- Current learner location: Pensacola, Florida, Escambia County, FL-01. Configured representative: Jimmy Patronis; senators: Rick Scott and Ashley Moody; governor: Ron DeSantis. Names belong in dynamic_answers.json and location information in location_profile.json; keep them easy to update and verify government sources.
- Maintain one Flutter source tree and GitHub Pages hash routing with /study/ base href.
- Do not add FastAPI, databases, authentication, or backend dependencies without a real requirement.
- Integrate on test_dev. Per the user's deployment preference, pushes to test_dev publish production after validation passes. Do not merge into main for deployment.
- Keep official simulation random and unique, maximum 20, pass immediately at 12, fail when reaching 12 is impossible. 65/20 study must not change normal simulation.
- Before finishing run dart format, flutter pub get, flutter analyze, flutter test, python tools/validate_data.py, and the web release build. Preserve meaningful tests and check phone widths.
