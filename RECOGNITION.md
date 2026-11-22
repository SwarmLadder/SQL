# Recognition rules

There are two ways to get your name on this course. Both are checked automatically, then confirmed by a maintainer.

| Track | Who it's for | Where your name goes | How you qualify |
|---|---|---|---|
| **1. Contributors** | People who improve the course | [CONTRIBUTORS.md](CONTRIBUTORS.md) | A pull request that improves the course is **merged** |
| **2. Achievers** | Learners who finish a level | [ACHIEVEMENTS.md](ACHIEVEMENTS.md) | Every graded exercise of a level **passes**, verified by CI and approved by a maintainer |

## Track 1: Contributors

1. Read [CONTRIBUTING.md](CONTRIBUTING.md) and open a pull request: a fix, a clearer explanation, a new exercise, a better edge case, a translation...
2. CI must pass (see "Run and test" in the [README](README.md#run-and-test)).
3. When a maintainer merges it, the **Credit contributors** workflow adds you to `CONTRIBUTORS.md`. You don't need to edit that file yourself.

**Counts:** content fixes, new or improved lessons, exercises, hints, edge-case fixtures, tests, tooling, translations, accessibility improvements.
**Doesn't count:** whitespace-only changes, mass automated edits, or PRs labelled `no-credit` by a maintainer (e.g. reverts).

## Track 2: Achievers

A level (Basics, Intermediate or Advanced) is complete when **both** of these pass from your own files:

| Level | Graded practice (`practice/starter/`) | Interview challenges (`interview/starter/`) | Total |
|---|---:|---:|---:|
| Basics | 20 (`PB01`–`PB20`) | 16 (`B01`–`B16`) | 36 |
| Intermediate | 20 (`PI01`–`PI20`) | 16 (`I01`–`I16`) | 36 |
| Advanced | 16 graded (`PA..`) | 16 (`A01`–`A16`) | 32 |

Written exercises (`PA02`, `PA12`, `PA16`, `PA20`) are discussion prompts and are not graded automatically. You are still encouraged to answer them in your claim PR description.

Check yourself before claiming:

```bash
python tools/verify_level.py basics
```

### How to claim

1. **Fork** this repository and write your answers in your fork's `practice/starter/*.sql` and `interview/starter/*.sql` files.
2. Add a claim file named after your GitHub login, `achievements/claims/<your-login>.md`:
   ```
   level: basics
   name: Your Name        # optional, how you want to be listed
   ```
3. Open a pull request from your fork. It may change **only** your answer files and your claim file.
4. The **Verify achievement** check runs `tools/verify_level.py` on your work.
5. A maintainer reviews the PR. If everything is green and honest, they add the label `achievement-approved`.
6. The **Record achievement** workflow adds you to `ACHIEVEMENTS.md`, thanks you, and **closes the PR without merging**, so your answers never become part of the course.

Claim one level at a time. Each level has its own row.

### Honesty rules

- Your work must be your own. Discussing ideas is fine; copying someone else's answers or the files in `practice/answers/` and `interview/reference/` is not. Those reference files exist so contributors can maintain the checker; reading them before you have solved an exercise only cheats you.
- Don't modify or bypass the checker, the datasets or the workflows. A claim PR that touches anything outside the allowed files is rejected automatically.
- Be aware that a pull request is public: anyone can read the answers in it. That's normal for open source, but please don't copy from other people's claim PRs.

## For maintainers

Before adding `achievement-approved`:

- [ ] The **Verify achievement** check is green on the latest commit.
- [ ] The PR touches only `practice/starter/*.sql`, `interview/starter/*.sql` and the author's own claim file. The record workflow re-checks this through the API, but look anyway.
- [ ] Skim the answers for answers copied verbatim from `practice/answers/` or `interview/reference/`.

The record workflow never runs code from the PR. It reads the changed-file list, the claim file and the check result through the GitHub API, then edits `ACHIEVEMENTS.md` on `main`. If `main` is protected, allow the GitHub Actions bot to push, or record achievements by hand with `python tools/recognition.py achievement ...`.

One-time setup: create the labels `achievement-approved`, `achievement-claim` and `no-credit`.
