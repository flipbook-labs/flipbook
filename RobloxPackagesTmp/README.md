### Updating External Packages
- Follow https://roblox.atlassian.net/wiki/spaces/APT/pages/2602608774 to set up publishing for your external package. If you're publishing an existing package, the workflow is likely already set up.
- Create a branch for your upgrade PR in the [LuaApps](https://github.com/Roblox/lua-apps) repo
- Navigate to `content/LuaPackages` in your local [LuaApps](https://github.com/Roblox/lua-apps)
- Bump the version to the desired version number (e.g. 1.5.0 -> 1.6.0) in the [rotriever.toml](https://github.com/Roblox/lua-apps/blob/master/content/LuaPackages/rotriever.toml) file
- Run `rotrieve install` in `content/LuaPackages` to pull in the latest changes
- Commit everything to your branch and create a PR for review
- Squash and merge once approved

## Notes
- `rotrieve upgrade --packages <package>` was used in the past for git dependencies. Git dependencies are no longer allowed in `lua-apps` and usage of `rotrieve upgrade` is now deprecated as it may have unintended side effects if used on non git dependencies. You may still use `rotrieve upgrade` for local development if you are experimenting with a git dependency.