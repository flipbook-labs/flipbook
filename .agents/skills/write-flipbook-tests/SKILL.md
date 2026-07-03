---
name: write-flipbook-tests
description: "Test-quality discipline: how to write unit tests that specify intended behavior and can actually fail. Use when: writing or modifying unit tests/specs, adding test coverage for new or existing code, deciding whether a test is good enough, or a test you wrote fails and you are tempted to change the test. For test mechanics (running, placement, Jest idioms, evidence tiers), see flipbook-validation-and-qa."
type: process
---

# Write Flipbook Tests

The discipline for writing tests worth keeping: what a test is *for*, the red-first gate every test must pass through, the moves that are forbidden, and what "good" looks like with verified exemplars. **Scope:** test quality and authoring discipline only — this skill owns *whether a test is any good*, not how the test infrastructure works.

## When NOT to use this skill

Use `flipbook-validation-and-qa` for test mechanics: spec file placement and naming, Jest-Luau idioms, the three validation tiers, the test inventory, and what counts as evidence in a PR. Use `run-flipbook-checks` for the lint/analyze/test command quick-reference. Use `flipbook-debugging-playbook` when an *existing* test fails and you need symptom→triage. Use `flipbook-story-controls-campaign` for controls-specific validation gates.

## 1. The objective — what a test is for

You are **specifying intended behavior**, not making CI green. A test's entire value is its ability to fail when the code is wrong. A suite that passes no matter what the code does is worse than no suite: it manufactures false confidence and substitutes for looking.

Corollary: when writing tests for existing code, the question is never "what does this code do?" (transcribing current behavior freezes in its bugs) — it is "what is this code *supposed* to do?" Derive that from the public contract, the docs, the story files, and the call sites. If intended behavior is genuinely ambiguous, say so in the PR instead of silently canonizing whatever the code happens to do today.

## 2. The red-first gate — every test must be seen failing

A test that has never failed is unproven. Before declaring any test done, it must pass through one of these two gates:

**New behavior (test-first):**

1. Write the test against the intended contract.
2. Run it (`lute run test --filter "<SpecName>"`) and confirm it fails **for the expected reason** — the assertion you wrote, not a require error or typo.
3. Implement, then confirm it goes green.

A test that passes the moment it is written is suspect — it is either testing nothing or testing something that already worked (fine, but then the break-the-code gate below applies).

**Existing code (break-the-code / hand-rolled mutation):**

1. Write the test; it will pass immediately.
2. Deliberately break the module under test — flip a comparison (`>=` → `>`), return early, nil out a field, swap a branch.
3. Run the filtered suite and confirm your test goes **red**.
4. Revert the break and confirm green.

If no deliberate break makes the test fail, the test is decorative — fix it or delete it. Do not leave it in the suite.

**When the gate cannot run:** cloud tests require `ROBLOX_API_KEY` (see `flipbook-validation-and-qa`, "Honest Fallback"). If it is unavailable, the red-first gate is *blocked, not waived*. State this explicitly in the PR ("tests written but not seen red/green in this environment") — never imply the gate passed. Lint and analyze still run offline and must pass.

## 3. Forbidden moves

These are the ways agents (and tired humans) game a test suite. All of them are prohibited:

- **Weakening to green.** A red test is a *finding*, never an obstacle. Do not delete a test, weaken an assertion, broaden a matcher, or add `.skip` to get to green until you have diagnosed whether the code or the test is wrong — and said which, out loud, in the PR or commit message.
- **Tautologies.** Never assert the implementation against itself (calling the function to compute the expected value, re-deriving `expected` with the same logic as the code under test). Expected values are written as literals or derived independently.
- **Mocking the unit under test.** Mocks exist to sever a dependency, never to replace the thing you claim to be testing. If the assertion checks that a mock was called with what you told the mock to receive, you have tested the mock.
- **Vacuous assertions.** No `toBeDefined()` / `never.toBeNil()` where a concrete value is assertable. Assert the value, the shape, or the observable effect.
- **Behavior transcription.** Do not generate the expected value by running the code and pasting its output. That is a snapshot of current behavior, bugs included (see §1).
- **Coverage theater.** Do not add tests whose only purpose is touching lines. Every test must encode a claim about intended behavior that the break-the-code gate can validate.

## 4. What good looks like — rubric and exemplars

The rubric, distilled from the hand-written suites in this repo family:

- **Names are behavioral specs.** `"the callback is run immediately on the first execution"`, `"updates when a non-matching Instance becomes a match"` — a reviewer should be able to read only the test names and know the module's contract. Not `"test callback"`, not `"works correctly"`.
- **Test the public contract, not internals.** Assert what a caller observes (return values, rendered Instances, thrown errors, callback invocations) — never private state, call order of internals, or intermediate representations.
- **Real objects first; mocks only to sever.** Prefer real `Instance` trees, real stores, real renders. Reach for `jest.fn()` only when a dependency is slow, nondeterministic, or outside the unit's contract.
- **Error and edge paths are first-class.** Every happy-path group should be accompanied by the boundary and failure cases: out-of-range, malformed input, empty, `toThrow` with a message match.
- **Shared fixtures over ad-hoc setup.** Use and extend the existing test helpers rather than re-rolling setup per test; `beforeEach`/`afterEach` (with mock resets) to prevent test pollution.
- **Arrange-Act-Assert**, one behavior per test; multiple assertions are fine when they verify a single cohesive behavior.

**In-repo exemplars** (verified present; read before writing similar tests):

- `workspace/flipbook-core/src/Common/usePrevious.spec.luau` — hook testing through real Instances: renders a `HookTester` component (grep `HookTester`), drives state from outside via a `BindableEvent`, asserts on rendered `TextLabel.Text`. Caller-observable behavior only.
- `workspace/flipbook-core/src/StoryControls/createStoryControlsStore.spec.luau` — store contract testing, including non-obvious edge cases like signal identity (grep `same getter reference`).

**Gold-standard sibling exemplars** in the Storyteller checkout (`../storyteller/`; if the sibling checkout is absent, rely on the in-repo exemplars above):

- `../storyteller/src/debounce.spec.luau` — `jest.useFakeTimers()` for deterministic async; every assertion is about what the *caller* observes, never the internal cooldown state.
- `../storyteller/src/controls/hydrateControls.spec.luau` — systematic error-path coverage: each control type's describe block carries its own `toThrow` cases alongside the happy path.
- `../storyteller/src/loadStoryModule.spec.luau` — malformed-input testing (`toThrow("Story is malformed")`), fixture factories, `beforeEach` setup with `jest.resetAllMocks()` teardown.
- `../storyteller/src/stores/query.spec.luau` — real Instance hierarchies built with the `new` helper; async assertions via `waitFor` instead of sleeps.
- `../storyteller/src/test-utils/` — the fixtures-over-setup pattern: `renderHook.luau`, `waitFor.luau`, `new.luau`, `createStory.luau`.

## 5. React components: test what the user observes

Flipbook's component tests render into real Instances. The guiding principle: **the more a test resembles how the component is actually used, the more it proves.**

- Query the rendered output (`FindFirstChildWhichIsA`, `FindFirstChild(name, true)`) and assert on observable properties (`Text`, visibility, child count) — not on hook state, props plumbing, or render counts.
- Drive behavior the way the app does: fire events/signals, re-render with new props, wrap every render and event in `ReactRoblox.act()`.
- Unmount and assert cleanup (`#container:GetDescendants()` returns to baseline) when the component owns resources.
- For pure UI with no logic, a `.story.luau` covered by the stories smoke test may be sufficient — see the story-only justification in `flipbook-validation-and-qa`. Write a dedicated spec when the component has *behavior*: conditional rendering, state transitions, event handling.

The Jest-Luau idioms table (imports, `act()`, `BindableEvent` reactivity) lives in `flipbook-validation-and-qa` — do not guess at Node-style Jest APIs.

## 6. Pre-done checklist

Before declaring test work complete, confirm every line:

- [ ] Every new/changed test has been seen **red** at least once — via test-first failure or a deliberate break (§2). If the gate was blocked (no API key), the PR says so explicitly.
- [ ] Test names read as behavioral specs; a reviewer could reconstruct the contract from names alone.
- [ ] No forbidden moves (§3): no tautologies, no mocked subject, no vacuous assertions, no weakened-to-green tests, no transcribed behavior.
- [ ] Error/edge paths are covered, not just the happy path.
- [ ] Existing test helpers were used (or extended) instead of duplicating setup.
- [ ] If a pre-existing test was modified or deleted, the PR explains why the *test* was wrong, not just that it now passes.

---

## Provenance and Maintenance

**Date stamped:** 2026-07-03.

**Re-verify these claims when this skill next loads:**

- In-repo exemplars exist: `ls workspace/flipbook-core/src/Common/usePrevious.spec.luau workspace/flipbook-core/src/StoryControls/createStoryControlsStore.spec.luau`
- Exemplar anchors present: `grep -l "HookTester" workspace/flipbook-core/src/Common/usePrevious.spec.luau` and `grep -l "same getter reference" workspace/flipbook-core/src/StoryControls/createStoryControlsStore.spec.luau`
- Sibling exemplars exist (skip if no sibling checkout): `ls ../storyteller/src/debounce.spec.luau ../storyteller/src/controls/hydrateControls.spec.luau ../storyteller/src/loadStoryModule.spec.luau ../storyteller/src/stores/query.spec.luau ../storyteller/src/test-utils/`
- Filtered test runs still work as documented: `grep "args:add(\"filter\"" .lute/test.luau`
- The stories smoke test still exists (backs the story-only guidance in §5): `ls workspace/flipbook-core/src/stories.spec.luau`
