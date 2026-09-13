# Contributing to Flipbook

Thanks for helping improve Flipbook. You can prepare a pull request without access to any Flipbook Labs secrets.

## Quick start

Install [Rokit](https://github.com/rojo-rbx/rokit/) before running the setup commands below. Roblox Studio is required only for manual plugin testing.

1. [Fork Flipbook](https://github.com/flipbook-labs/flipbook/fork), then clone your fork and add the main repository as `upstream`:

   ```sh
   git clone https://github.com/<your-account>/flipbook.git
   cd flipbook
   git remote add upstream https://github.com/flipbook-labs/flipbook.git
   ```

2. Create a branch from the latest `main`:

   ```sh
   git fetch upstream
   git switch -c my-change upstream/main
   ```

3. Install the pinned tools and packages, then create the local build configuration:

   ```sh
   rokit install
   lute run install
   cp .env.template .env
   ```

4. Make your change and run the secret-free contributor check:

   ```sh
   lute run check
   ```

5. Add one file under [`.changes/`](.changes/README.md) describing the user-visible effect of your pull request. Internal-only changes still use a patch entry.

6. Push your branch to your fork and open a pull request against `flipbook-labs/flipbook:main`.

Fork pull requests run standard builds without secrets. Cloud tests and storybook preview publishing use protected jobs and may wait for a maintainer to approve them. You do not need a Flipbook Labs Open Cloud key for this process.

See the [full onboarding guide](docs/docs/contributing/onboarding.md) for build options, local cloud testing, and using Flipbook to develop Flipbook.
