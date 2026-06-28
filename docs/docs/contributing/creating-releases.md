# Creating Releases

Releases are automated via [Changewrite](https://github.com/flipbook-labs/changewrite). Every push to `main` triggers a check; if there are unreleased commits, a `Publish v{version}` PR is opened automatically. Merging that PR:

1. Tags the commit and creates the GitHub release with `Flipbook.rbxm` attached.
2. Triggers the `publish-plugin` job, which publishes to the Roblox Creator Store.

To cut a release, merge your work to `main`, then review and merge the auto-opened `Publish v{version}` PR.

Check out the [Actions tab](https://github.com/flipbook-labs/flipbook/actions) after merging to monitor the deployment.

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
