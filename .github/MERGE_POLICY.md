# Merge policy

This policy describes who owns a change and what must happen before it merges. Repository instructions and automated checks implement this policy, but this document is the source of truth when they disagree.

## Requirements for every pull request

Every change merges through a pull request. The pull request must use the repository template, pass the required build and test checks, and receive a 5/5 Greptile review for its current head commit.

Greptile's required status is emitted by the review; it is not a separate review or charge. Each completed review counts as one Greptile review, including reviews automatically triggered by later commits. Batch related fixes when practical instead of creating review churn.

A Greptile finding does not become correct merely because it is blocking. Authors may fix it, reply with relevant context and request another review, or ask an administrator to bypass the check. If Greptile retains the finding and no administrator bypasses it, the code must change before merge.

## Ownership domains

| Domain            | Responsibility                                                                                                                                                                 | Human approvals |
| ----------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | --------------: |
| `flipbook-app`    | User-facing application structure, behavior, visual presentation, navigation, and Flipbook Next                                                                                |               1 |
| `flipbook-engine` | The runtime and build machinery that stands Flipbook up, including Storyteller, ModuleLoader, story loading and rendering, controls plumbing, and their integration boundaries |               0 |

The version-controlled `.github/ruleset.json` records the proposed application and engine ownership, team assignment, approval counts, required checks, and administrator bypass. The live GitHub ruleset enforces the policy. During this trial, administrators update the live ruleset through GitHub and keep the JSON record aligned with intentional changes. The general approval count is zero, and required code-owner review is disabled so the zero-approval engine domain remains non-blocking.

## Application review

Any pull request touching an application-owned path requires approval from `@flipbook-labs/flipbook-app`. Application review covers the user-facing result rather than only the implementation. Include screenshots, video, or the pull request's Storybook preview when the change affects visible appearance or interaction.

New reviewable commits dismiss an existing application approval. The application team must review the current result, not an earlier revision.

## Engine review

Engine ownership identifies responsibility and requests visibility without requiring a human approval. Engine changes become mergeable when the required checks, including Greptile 5/5, pass for the current head commit.

The maintainer performing the merge remains responsible for the decision. Greptile does not merge pull requests and does not replace maintainer judgment.

## Mixed changes

A pull request that touches both domains follows both paths and therefore requires application approval. Split a mixed change when the engine work is independently useful or when combining it with application work makes either responsibility harder to review. Do not split tightly coupled work solely to avoid application review.

Some files necessarily mix integration and presentation. Keep those application-owned until their engine boundary is independently reviewable. Ownership follows the current responsibility of the file, not the name of an imported dependency.

## Administrator bypass

Organization administrators may bypass required reviews or status checks when exercising maintainer judgment. A PR-body note or comment can preserve useful context, but a public explanation is not required. Agents must never bypass a merge requirement or recommend concealing a bypass.

## GitHub ruleset

The default-branch ruleset should enforce the following configuration:

- Pull requests are required.
- The general approving-review count is zero.
- Required code-owner review is disabled.
- `flipbook-app` is a required reviewer with one approval for application-owned paths.
- `flipbook-engine` is a required reviewer with zero approvals for engine-owned paths.
- Greptile 5/5 and the repository's build, analysis, test, and documentation checks are required.
- New reviewable commits dismiss existing approvals.
- Squash is the only merge method, linear history is required, and branch deletion and force-push protections remain enabled.
- Organization administrators retain pull-request bypass permission.

The required-reviewer patterns in `.github/ruleset.json` are the reviewed ownership map. Application review initially covers all of `workspace/flipbook-core/**/*` and `workspace/flipbook-next/**/*`. When maintainers encounter application paths that should instead be engine-owned, add the positive engine pattern and matching application exclusion together.

## Changing this policy

Changes to this policy, `.github/ruleset.json`, the pull request template, Greptile context, or the change-control skill belong to repository administrators. Update all affected representations in one pull request so human guidance, agent guidance, and enforcement do not drift.
