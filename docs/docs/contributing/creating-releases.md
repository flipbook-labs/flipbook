# Releases and Rollbacks

This guide walks you through how a change reaches Flipbook users, how to cut a release, and what to do when a release goes wrong. Its last section describes exactly how the release and rollback workflows behave, so you can check a run against it.

Flipbook ships to two Creator Store assets:

- [Flipbook](https://create.roblox.com/store/asset/8517129161) is the prod plugin. It updates only when you cut a release.
- [Flipbook (Dev)](https://create.roblox.com/store/asset/88523969718241) is the beta plugin. It updates on every push to `main`.

Every GitHub release keeps the `Flipbook.rbxm` it shipped, and Roblox keeps every version of both assets. So rolling back republishes an earlier build, and you never need to rebuild an old release to undo a bad one.

## From a pull request to users

1. A release-worthy pull request adds one Luau entry under [`.changes/`](https://github.com/flipbook-labs/flipbook/tree/main/.changes). The entry describes the change and whether it warrants a major, minor, or patch release.
2. When the pull request merges, the Release workflow publishes a beta build of `main` to Flipbook (Dev).
3. The same run uses [Changewrite](https://github.com/flipbook-labs/changewrite) to open or update a `Publish v{version}` pull request. It bumps the version and writes the changelog from every pending entry.
4. Merging the publish pull request tags the commit and creates a GitHub release with `Flipbook.rbxm` attached.
5. The published release starts another Release run, whose `publish-plugin` job publishes to the prod asset.

## Cut a release

1. Open the `Publish v{version}` pull request and review the version and the release notes it assembled.
2. Merge it.
3. Watch the [Actions tab](https://github.com/flipbook-labs/flipbook/actions) until the `publish-plugin` job finishes.

The required `publish-lock` status blocks merging the publish pull request while the Release workflow refreshes it. A failed or cancelled refresh leaves the lock in place, so a stale publish pull request can't create a release.

To preview the publish pull request without releasing anything, add the `debug:release-pr` label to any pull request. Changewrite then prepares the release on a separate debug branch and publishes nothing.

## When a publish fails

If `publish-plugin` fails, the GitHub release exists but the prod asset still has the previous version. Open the failed run in the Actions tab and choose **Re-run failed jobs**.

When a version or tag can't be published at all, a maintainer can run the Release workflow by hand with the `force-version` input. It opens a publish pull request that sets that exact version. Use it only to recover from a stuck version.

## Roll back a bad release

When a release reaches users and turns out to be broken, roll it back first. Fix it afterward.

1. In the Actions tab, open the **Rollback** workflow and choose **Run workflow**.
2. Pick `prod`, leave the version empty, and run it.

The run republishes the `Flipbook.rbxm` attached to the release before the current Latest release. It also does the following:

- It marks the restored release as Latest on GitHub.
- It reruns the Release workflow, so the publish pull request opens with a red caution banner saying prod is rolled back.
- It reports the rollback to PostHog and adds an annotation, as releases do.

If the restored release is also broken, run the workflow again with the version left empty. Each run steps back one more release. To restore a specific release instead, enter its tag, such as `v2.4.0`, as the version.

### Roll back beta

Run the same workflow with `beta`. Beta builds have no releases, so a beta rollback works from the asset's version history instead. With no version, it restores the Flipbook (Dev) version before the latest one. To restore a specific build, enter its asset version number, which the run's log prints. The next push to `main` publishes a new beta build over it, so a beta rollback lasts only until then.

### Undo a rollback

Run the Rollback workflow with `prod` and set the version to the newest release's tag. It republishes that release and marks it as Latest again, so the banner goes away.

### Ship the fix

Fix the problem in a normal pull request with a `.changes/` entry. The publish pull request picks it up and keeps showing the rollback banner. Merging it releases a new version, which becomes Latest, so the banner clears.

## How the workflows behave

This section is the reference for the Release and Rollback workflows. If a run does something this section doesn't describe, one of them is wrong.

### Rolling back prod

- A prod rollback publishes the `Flipbook.rbxm` attached to a published GitHub release, through the same publish script as a release with its build step skipped. Then it marks that release as Latest.
- With no version given, it restores the release before the current Latest release. With a tag given, it restores that release, which can be older or newer than Latest.
- It shares the `publish-plugin` job's concurrency group, so a rollback and a release publish never run at once.

Releases published before the prod publish started uploading the attached file ship an attachment that was built separately from what users got. Rolling back to one of those publishes that attached build.

### Rolling back beta

- A beta rollback asks Open Cloud to publish an earlier version of the Flipbook (Dev) asset again as a new version. It never rebuilds or uploads a file.
- With no version given, it restores the version before the latest. With a version number given, it restores that version, which must be older than the latest one.
- It shares the beta publish job's concurrency group, so it never runs at the same time as a beta publish.

### The publish pull request banner

Prod counts as rolled back when the Latest release isn't the newest published release. While that's true, every refresh of the publish pull request puts a caution banner at the top of its body. Publishing a new release makes it Latest, which clears the banner.

### Reporting

Each rollback sends a `ci_rolled_back` event to PostHog with its channel. For prod, the event also records the release that run restored, and an annotation marks the rollback on PostHog charts. Reporting never fails a rollback.

## Logging in to Wally registry in CI

In the event that publishing our Wally packages starts to fail this section shows how to update the login token.

:::warning
Your GitHub account must have permission to publish to the flipbook-labs org. To add a new account, update [owners.json](https://github.com/UpliftGames/wally-index/blob/main/flipbook-labs/owners.json) with your GitHub user ID.
:::

First run `wally login` locally and authenticate with your GitHub account.

```sh
wally login
[INFO ] Updating package index https://github.com/UpliftGames/wally-index...

Go to https://github.com/login/device
And enter the code: XXXX-XXXX

Awaiting authorization...
Authorization successful!
```

Open `~/.wally/auth.toml` and copy the generated GitHub token.

```toml
# This is where Wally stores details for authenticating with registries.
# It can be updated using `wally login` and `wally logout`.

[tokens]
"https://api.wally.run/" = "gho_XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
```

Then navigate to the organization's [secrets settings](https://github.com/organizations/flipbook-labs/settings/secrets/actions) and update `WALLY_REGISTRY_TOKEN` to use the new token to allow all flipbook-labs repos to publish to our scope.
