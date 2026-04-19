---
aliases: [Flipbook - Developer Storybook notes with Vincent]
linter-yaml-title-alias: Flipbook - Developer Storybook notes with Vincent
notion-id: 27695b79-12f8-81b4-be4d-d1afba1dfda9
---
# Flipbook - Developer Storybook notes with Vincent

## Marin

> My goal is to offer Flipbook as an alternative to Developer Storybook so the community and us internally can benefit from future improvements. Which then also gives me an excuse to work on it more during the day

> […] one of the biggest blockers is elevating Flipbook's permissions so stories can continue to access internal APIs. […] The killer is likely to be competing with "Developer Storybook comes pre-installed in Studio." If that can be overcome then I think Flipbook becomes a very good value add since it can be OTA'd (published to the Creator Store) and supports community creators implicitly

> There's definitely room to include Roblox internal only features in Flipbook behind some flagging mechanism, and for hack week I'm planning to largely keep the additions on a branch or gated and then later pick and choose what gets adopted for community use.

> Under the hood Flipbook is powered by [Storyteller](https://github.com/flipbook-labs/storyteller) which is a fairly robust API [..] for parsing, loading, and rendering stories. It's where all the messy logic of mapping Developer Storybook's story/storybook format to Flipbook's would take place. It's also where features necessary for parity like mapStory and substories will be added.

> I've got some longterm goals for Flipbook like general accessibility features, device size mocking, anonymized metric logging to track user journeys, documentation stories akin to storybookjs. Which I'm hoping carving out the internal avenue will help unlock

## Vincent

> I think I’m curious in what differences in internal feature parity we’d need to solve to fully commit to one tool over the other or, if they live side-by-side, what clear use cases we can define for each to reduce any confusion from ppl using them

> do you foresee any necessary divergence? example: idk if flipbook supports tags or not on components, but if it doesn’t, would it be something we could add internally first? or if it does, ig we’d need some internal definitions to provide default tags that we want? (uses stylesheets, react17, deprecated, etc)

In regards to tags:

> idea is for some visual indicators for arbitrary labels that we’d benefit from using internally, to discourage ppl from using deprecated components, educate ppl on stylesheets, etc etc

> I’m wondering if even changing how DS’s storybook format works is on the table, I don’t think anyone here is,,, extremely opinionated on the way we do our stories? So if a different format feels more readable/easy to write I could see us even just trying to convert to that as our hackweek proj

> anecdotally it feels like plugins and Studio UI gets a larger than normal influx of onboarding engineers, so if a story format is fast to learn and extend, its a big plus

> I think we’re gonna try to plan our improvements so that they do feed into a potential switch to flipbook though, with as little added friction as possible

Features they’re looking for:

* Story tags (deprecated,

Other considerations I have:

* Flipbook wrapper for BuiltInPlugins clearance that will elevate the existing Flipbook plugin
    * Should talk to Hugh about this since he’s giving contractors plenty of work on Developer Storybook
* Bring in the entire Flipbook codebase to game-engine to make it a built-in plugin
* Manually build Flipbook to BuiltInPlugins dir (only works on noopt and optimized builds)

See if anyone else is interested in working on this

Can a built-in plugin get what plugins a user has installed? How about arbitrary rbxm file loading?

If I can loadstring/loadmodule on Flipbook’s server script I think that can be enough to get it stood up
