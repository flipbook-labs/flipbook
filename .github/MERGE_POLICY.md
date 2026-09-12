# Merge policy

This policy describes who owns a change and what must happen before it merges. Repository instructions and automated checks implement this policy, but this document is the source of truth when they disagree.

## Requirements for every pull request

Every change merges through a pull request using the repository template. Greptile must report 5/5 for the current head commit.

Greptile's required status is emitted by the review; it is not a separate review or charge. Each completed review counts as one Greptile review, including reviews automatically triggered by later commits. Batch related fixes when practical instead of creating review churn.

A Greptile finding does not become correct merely because it is blocking. Authors may fix it, reply with relevant context and request another review, or ask an administrator to bypass the check. If Greptile retains the finding and no administrator bypasses it, the code must change before merge.

## Ownership domains

| Domain            | Responsibility                                                                                                                                                              | Human approvals |
| ----------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------: |
| `flipbook-app`    | User-facing application structure, behavior, visual presentation, navigation, and Flipbook Next                                                                             |               1 |
| `flipbook-engine` | Every path outside the application-owned workspaces, including runtime and build machinery, Storyteller and ModuleLoader integration boundaries, and repository stewardship |     0 (current) |

The live GitHub ruleset is the enforcement point for application and engine ownership. Its ownership paths and merge requirements are managed centrally in the [Flipbook Labs GitHub governance stack](https://github.com/flipbook-labs/infra/tree/main/stacks/github). Increase the engine team's minimum approval count to one when a second member joins.

## Application review

Any pull request touching an application-owned path requires approval from `@flipbook-labs/flipbook-app`. Application review covers the user-facing result rather than only the implementation. Include screenshots, video, or the pull request's Storybook preview when the change affects visible appearance or interaction.

## Engine review

Engine ownership currently identifies responsibility and requests visibility without requiring a human approval. While the engine team has one member, engine changes become mergeable when the required checks, including Greptile 5/5, pass for the current head commit. Once the team has more than one member, engine changes also require one engine-team approval.

The administrator performing the merge remains responsible for the decision. Greptile does not merge pull requests and does not replace administrator judgment.

## Mixed changes

A pull request that touches both domains follows both paths and therefore requires application approval. Split a mixed change when the engine work is independently useful or when combining it with application work makes either responsibility harder to review. Do not split tightly coupled work solely to avoid application review.

Some files necessarily mix integration and presentation. Keep those application-owned until their engine boundary is independently reviewable. Ownership follows the current responsibility of the file, not the name of an imported dependency.

## Repository stewardship

Repository stewardship belongs to `@flipbook-labs/flipbook-engine` and follows the engine review path. The `@flipbook-labs/flipbook-admins` team remains the repository administration and bypass role, not a separate ownership domain.

## Administrator bypass

Members of `@flipbook-labs/flipbook-admins` may bypass required reviews or status checks when exercising administrator judgment. A PR-body note or comment can preserve useful context, but a public explanation is not required. Agents must never bypass a merge requirement or recommend concealing a bypass.

## Changing this policy

Changes to this policy, the pull request template, Greptile context, or the change-control skill belong to `@flipbook-labs/flipbook-engine`. Coordinate ownership changes across Flipbook and the centrally managed ruleset in the infrastructure repository so human guidance, agent guidance, and enforcement do not drift.
