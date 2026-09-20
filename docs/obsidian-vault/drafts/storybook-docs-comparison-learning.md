# Storybook.js vs. Flipbook docs — learning-effectiveness report

> [!note]
> Scratch report reframing the [[storybook-docs-comparison-coverage|coverage comparison]]
> around **learning effectiveness** (instructional design / pedagogy) rather than
> feature/content coverage. The question driving it: _does Storybook teach the reader with
> objectively better methods than we do?_ This report is the basis for the implementation
> plan. Lives in `drafts/` (build-excluded). Status: **awaiting review**.

## Framing: coverage vs. teaching

The coverage report mixed two things: **coverage gaps** ("you don't have a page on X") and
**teaching gaps** (how well the pages you _do_ have build understanding). Through a
learning-effectiveness lens most coverage items drop out, and a smaller set of _method_
differences rise to the top. Writing a reference page makes the docs more _complete_; it
does not make them _teach better_.

## Does Storybook teach with objectively better methods? On three dimensions, yes.

These are established instructional-design techniques where Storybook executes and Flipbook
doesn't — method differences, not page-count differences.

1. **Worked examples you can manipulate, before blank-page construction.** Storybook's
   onboarding ships working example stories + an interactive tour; the reader pokes at a
   _running_ artifact and modifies it. Flipbook's `usage/getting-started` asks the reader to
   author two files correctly from scratch before anything renders. The "worked-example
   effect" and "completion-problem effect" are among the most replicated findings in
   instructional design: for novices, studying/tweaking a working example beats constructing
   from zero. Storybook reaches a first success in one command; Flipbook requires
   internalizing `storyRoots`, file extensions, ReplicatedStorage placement, _and_ correct
   syntax before the first win. Delayed first success is a real motivation/retention cost.
2. **Motivation before mechanics.** Storybook leads with _Why Storybook?_, building the
   mental schema (isolation, edge cases, UI variations) before any syntax. Flipbook
   compresses the "why" into one sentence and goes straight to install, so details land on
   no scaffold.
3. **One concept per page, progressively sequenced.** Storybook's path is render → args →
   controls → play → decorators, each isolated. Flipbook's `usage/writing-stories` carries
   frameworks + the `packages` object + global-vs-per-story override + a tip in one page —
   multiple new concepts at once, a cognitive-load failure mode.

## How this re-ranks the recommendations

**Falls away (coverage, not pedagogy):** testing page, decorators page, FAQ,
naming/hierarchy page. Real, but completeness — out of scope for _teaching effectiveness_.

**Rises sharply:**

- **Stub and broken pages become the #1 problem, for a sharper reason.** A broken example
  doesn't just frustrate — it _actively mis-teaches_. The Hoarcekat guide teaches the
  deprecated `roact =` API and ships invalid Luau, so a learner who trusts it learns the
  wrong thing and can't tell whether a failure is theirs or the doc's. Worse than a missing
  page. Same for the visible "coming soon" stubs (`typechecking`, `migrating-ui-labs`) —
  they break the implicit promise that a nav link leads to learning.
- **Onboarding-as-learning** — shipping a starter `.rbxm` with example stories the reader
  can open and tweak — becomes the highest-impact change, because it imports Storybook's
  actual _method_ (manipulable worked example), not just its content.

## Two pedagogy problems the coverage pass under-weighted

- **The "explanation" docs contain no explanation.** In the Diátaxis model (tutorial /
  how-to / reference / explanation), the `concepts/` pages are the _explanation_ tier. But
  `concepts/story` is two sentences that redirect to the API table and `concepts/storybook-js`
  is one. They're reference pointers wearing an explanation hat — the understanding-building
  layer is structurally present but empty. A pure teaching failure, independent of features.
- **Framework pages repeat without abstracting.** `frameworks/react` stacks `Default` then
  `Storyteller` code with zero prose. Good teaching _names the contrast_ ("use Storyteller
  when you want typed stories; the difference is X"). Stacked code forces the reader to
  reverse-engineer the lesson — the opposite of scaffolding.

## Where Storybook is _not_ a better teacher (don't over-correct)

- **Sprawl is its own pedagogy failure.** Storybook's docs are huge, with Chromatic upsell
  and 20+ framework branches — high extraneous load, easy to get lost. For a small tool,
  Flipbook's brevity could be a genuine teaching _advantage_ if it were intentional rather
  than incomplete.
- **Flipbook's one real tutorial already uses good method.** The (broken) Hoarcekat guide is
  the only place Flipbook teaches by progressive build-up (migrate → add summary → add
  controls, each step motivated). The pedagogy structure is right; the execution (broken
  code, deprecated API, missing images) fails it. Fix it and it becomes the best teaching
  asset.
- **`usage/deploying-storybooks` is a better how-to than much of Storybook's Sharing
  section** — task-scoped, complete, copy-pasteable. As a how-to (not a tutorial) it's right
  and should not be "tutorial-ified."

## Net

Storybook teaches objectively better on three specific, evidence-backed methods —
manipulable worked examples in onboarding, why-before-how, and one-concept-at-a-time
sequencing. The gap is a _method_ gap, not a page-count gap. Highest-leverage moves for
learning effectiveness:

1. Ship a tweakable example storybook (worked-example onboarding).
2. Fix or hide the mis-teaching pages (broken/stub).
3. Put actual explanation into the concept tier.
4. Sequence the core path one concept at a time; name the contrasts on framework pages.

The testing/decorators/FAQ items from the coverage report are real but are completeness,
not teaching.
