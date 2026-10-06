# Reusable update prompt

Copy this prompt into Codex, replacing the bracketed request:

```text
Update my Flutter civics study app in C:\Users\isaac\test_dev\study.
Repository: https://github.com/musepodcast/study
Production: https://musepodcast.github.io/study/
Branch: test_dev. Pushing this branch automatically publishes production.

Requested changes:
[Describe the features, fixes, or design changes I want.]

Read AGENTS.md and README.md. Implement the requested changes completely.
Keep Brazilian Portuguese as the default interface and English selectable.
Preserve the official USCIS English questions and accepted answers, English
audio, saved progress, mobile layouts, and official simulation scoring.
Keep translations and current officeholder configuration separate from
official source content. Verify official government sources if changing
current answers. Do not introduce a backend unless the requested feature
requires one.

Run dependency resolution, formatting, analysis, relevant tests, official
content validation, and the /study/ release web build. Fix failures and update
documentation where needed. Explain what changed, what passed, and any checks
that could not run.

Leave the changes local for me to review. Do not bump the release version,
commit, or push: I will run tools/publish.ps1 when ready to publish.
```
