# Creating Releases

Releases are automated via [Changewrite](https://github.com/flipbook-labs/changewrite). Every release-worthy pull request adds a Markdown entry under [`.changes/`](https://github.com/flipbook-labs/flipbook/tree/main/.changes) describing the change and whether it warrants a major, minor, or patch release.

Every push to `main` collects the pending entries and opens or updates a `Publish v{version}` pull request. Merging that pull request:

1. Tags the commit and creates the GitHub release with `Flipbook.rbxm` attached.
2. Triggers the `publish-plugin` job, which publishes to the Roblox Creator Store.

To cut a release, review the assembled notes and version in the auto-generated publish pull request, then merge it. To preview that pull request without publishing, add the `debug:release-pr` label to a pull request; Changewrite uses a separate debug branch and prepare-only mode.

Check out the [Actions tab](https://github.com/flipbook-labs/flipbook/actions) after merging to monitor the deployment.
