# Authoring guide

How the course is written, so new and changed material keeps the same standard. Run every check in [CONTRIBUTING.md](../CONTRIBUTING.md#run-every-check) before opening a pull request.

## Lesson format

A lesson is `<level>/lessons/NN_topic.md`. The generated `NN_topic.sql` next to it replays its examples. Every lesson has, in this order:

1. `# NN · Title`
2. A quote block with **You will learn** (one sentence), **Time** and **Before this** (links).
3. One paragraph of motivation: the real question this lesson answers.
4. `**Run the whole lesson:**` with the `run_sql.py` command.
5. Three to six numbered sections `## 1. …`. Each teaches one idea: a short explanation, an example, its result, and what to notice.
6. `## Common mistakes`: a table of *mistake / what happens / fix*.
7. `## Your turn`: the `<!-- exercises -->` marker, filled automatically.
8. `## Quick quiz`: the `<!-- quiz -->` marker, filled automatically.
9. `## Summary`: four or five bullets.
10. `**Next:**` link.

The tests enforce this structure and a minimum length.

## Examples and results

- Write examples as ```sql blocks. **Never type results by hand.** Run `python tools/lessons.py`: it executes every example of a lesson in order on one fresh sample database and writes the result tables between `<!-- result -->` markers.
- Examples share state within a lesson. Wrap temporary changes in `BEGIN; … ROLLBACK;` so later examples see the original data, unless the lesson deliberately builds on the change.
- Mark an example that must fail with ```sql error; the error message is shown and the build fails if it unexpectedly succeeds.
- Mark fragments, pseudo-code and other dialects with ```sql norun.
- Every number quoted in prose must match a result on the page. Re-read the prose after changing an example.
- CI runs `python tools/lessons.py --check`, so a stale result fails the build.

## Exercises

See [CONTRIBUTING.md](../CONTRIBUTING.md#add-or-change-a-practice-exercise) for the fields. Standards:

- **One correct result.** Name the output columns, the filter and the full sort order (with a tie-breaker).
- **Two to six graded exercises per lesson**, from direct application to a small twist. The tests require at least two.
- **The edge fixture must matter.** Write the most likely wrong answer and confirm the checker rejects it. If it passes, tighten the prompt or extend `PRACTICE_EDGE_SQL`.
- **Hints:** (1) a nudge about the idea, (2) the approach, (3) near-syntax with gaps. A hint must never be the whole answer; a test checks this.

## Quizzes

Three or four questions per lesson, three options each.

- Each question tests a misconception the lesson addresses, not trivia.
- Wrong options are plausible mistakes, not jokes.
- `section` names the lesson section to re-read; `explain` is shown after a correct answer.
- Answers are stored as hashes (`python tools/quiz.py --fingerprint basics/05 2 c`). Spread correct letters across a, b and c; a test fails if one letter dominates.

## Worked examples

`<level>/worked_examples/NN_topic.md`, six per level, rendered by the same builder as lessons. Each has: **Problem**, `## 1. Plan`, `## 2. Tempting attempt` (run it and show why it's wrong), `## 3. Fix`, `## 4. Test it`, and **Practise next** links to exercises.

## Projects

`<level>/projects/NN_topic.md` + a runnable reference `NN_topic.sql`. A project brief has a scenario, numbered tickets with **acceptance criteria**, stretch goals and the shared rubric. Acceptance criteria must be checkable on the sample data.

## Concept map

[`concepts.json`](concepts.json) lists what each lesson introduces and which earlier lessons it builds on. When a lesson starts relying on an idea, add the lesson that teaches it to `builds_on`. Tests check that every lesson is mapped, that prerequisites come earlier in the course, and that no concept is introduced twice.

## Style

- Short sentences, second person, present tense. Explain *why* before *how*.
- SQL keywords in capitals, `snake_case` identifiers, table aliases on every join.
- Money in integer cents; dates as ISO-8601 text.
- SQLite is the runtime. Mention PostgreSQL differences where they would surprise a learner; full PostgreSQL material lives in `advanced/postgresql/`.
