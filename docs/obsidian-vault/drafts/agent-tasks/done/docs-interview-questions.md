# Docs interview — batched Mode-3 questions

> [!note]
> The grounded prose for the remaining Track A pages is mostly written or extractable. These are the bits I genuinely can't pull from the repo and need from you. Answer in rough bullets or a voice memo — I'll turn it into prose. Lives in `drafts/` (build-excluded).

## getting-started — the "why" intro + first-story arc

1. The Story concept page now frames Flipbook around a sandbox/canvas (Figma/Storybook hybrid). For the getting-started opener, what one-sentence pitch do you want a newcomer to read first — the core pain it removes for you?

   Having to navigate complex UI structures just to get to one surface you need to test is the core pain, and trying out variations? Yikes. Isolating/sandboxing helps (especially when already writing componentized UI) to preview just the surfaces you care about, with controls to quickly switch between variations. There's also removing friction between design and engineering with deploy-storybook so that designers can quickly hop in and preview implementations as engineers work on them

2. For a brand-new user's very first story, what's the smallest "win" you want them to reach, and what most commonly goes wrong before they get there (beyond the malformed-module-shape issue we already covered on the Story page)?

   Not sure what other fall-offs there are.

   I think getting the user to having something they can interact with (some kind of button?) along with controls to change behavior. Maybe we could even do something like a simple todo list where the controls can change some things like "strike-through vs. fade-out" for completed items, and a numItems count to control how many items there are (make a list of 10, cap numItems at 10). Maybe we could even make the story stateful so the user can interact with it too. This could even be a good push for me to make it so controls changes doesn't lose component state.

3. Anything about installation — Creator Store vs GitHub release, the dev build — that trips people up and should be called out up front?

   Let's prefer directing users to the Creator Store and also use the install button from the README too. [![Get it on Creator Store](assets/link-creator-store.svg)](https://create.roblox.com/store/asset/8517129161/flipbook)

## writing-stories — sequencing + "ways to define a story"

4. We're adding a "ways to define a story" beat (a function returning a thing; an Instance directly; a component/element directly; mount-it-yourself + cleanup). Is there a recommended/default shape you want to steer people toward, or are they equals?

   I'm biased and want to show a React example first and then show vanilla with returning an Instance. Then any order for the rest is fine

5. The `packages` global-vs-per-story override: any real-world gotcha worth a warning (e.g. mixing React and Fusion under one Storybook)?

   Not sure, no ones complained about it and I've never thought to try mixing the two. Per Storyteller I think it would just be whichever framework gets matched first in createStoryRenderer? Whatever the renderer aggregator is. I don't think it's worth a callout other than defining `packages` in a storybook is what I want to nudge people towards

## frameworks/\* — the Default vs Storyteller contrast

6. Each framework page stacks a "Default" and a "Storyteller" example with no prose. In one line: when should a reader pick the Storyteller-typed form over the plain form? My read is "Storyteller gives you the `Story`/`Storybook` types for static checking" — is that the whole reason, or is there more?

   It's also where the `create*Control` functions are defined. We're using that API for now until we have a `Flipbook` package that gives a cleaner API (just renames, really). But yeah, mostly static types. Storyteller is essentially the Flipbook engine, and we use it _in_ Flipbook stories for now but I want to introduce a `Flipbook` package that would expose only what users need in a story (i.e. _not_ the entirety of story/storybook discovery)

## controls — v2.5.0 surface (A4)

7. Confirm the shipped v2.5.0 control set to document: simple inferred controls (string / boolean / number / arrays) plus the `create*Control` constructors (Select, MultiSelect, Radio, Check, Color, Date, Slider, Number-with-range). Anything shipped I'm missing, or anything in that constructor list that did NOT actually make v2.5.0?

   Not sure, please check Storyteller.

8. Do simple and constructor controls coexist freely (mixed in one `controls` table)? And is there a UI Labs / old-schema migration note worth surfacing for users coming across?

   They do co-exist. There is a UI Labs migration and even an older Storyteller version migration. Check Storyteller for both. We should include docs for how to migrate from UI Labs especially
