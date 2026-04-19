---
notion-id: 12f95b79-12f8-809b-9842-f96897b55438
base: "[[Proposals.base]]"
Author:
  - Marin Minnerly
Tags: []
Status: Not started
Created: 2024-10-30T12:09:00
Approval: Drafting
aliases: [Possible Solutions]
linter-yaml-title-alias: Possible Solutions
---

Storyteller will be available on Wally as an avenue for the community to use the same types as Flipbook does internally.

sIt would also be handy to allow the Flipbook plugin to manage typedefs so Studio-only users have an avenue for typing their modules.

# Possible Solutions

|   | Option 1: Install Storyteller through package manager | Option 2: Flipbook can import Storyteller | Option 3: Flipbook can import typedefs |
| --- | --- | --- | --- |
| Description | Instruct users to install Storyteller through package managers and import it in their Storybooks and Stories to get typechecking | Allow Flipbook (either via  button click or implicitly) to import Storyteller to a static location in an experience | Same as Option 2, but only for Storyteller’s exported types, no other members |
| Pros & Cons | ✅ Wally is easily accessible to external workflows<br>✅ Can support other package managers like Pesde<br>⛔ Users that aren’t onboarded with external workflows won’t be able to use it | ✅ <br>⛔  | ✅ Slims down the amount of code that users need to import<br>⛔ Potentially too barebones. Users may get a lot of value out of the full API |
| Considerations | There is at least one Studio plugin that allows Wally packages to be imported into Studio. If we go with this option we may want to offer documentation on how to install Storyteller through third-party means |   |   |
