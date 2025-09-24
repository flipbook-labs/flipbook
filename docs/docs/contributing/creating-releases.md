# Creating Releases

Once ready to cut a new release, bump the version in `wally.toml` and merge it to the main branch.

After this point, to publish the new version you must create a new GitHub release, matching the tag to the version bump.

From there, our GitHub Actions will handle building Flipbook to an rbxm, attaching it to the release under the "Assets" list, and publish it to the Wally registry for consumption.

Check out the [Actions](https://github.com/flipbook-labs/flipbook/actions) tab after publishing the release to check the status of the deployment.

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
