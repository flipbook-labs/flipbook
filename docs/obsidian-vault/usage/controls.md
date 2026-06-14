---
aliases: [Controls]
linter-yaml-title-alias: Controls
---

# Controls

Stories can define controls that make it possible to quickly test out the behavior and variants of the UI you're working on.

Here's an example React component that we will build a Story around. The props it takes in will be configurable by the Story's controls.

<!-- code-sample: workspace/code-samples/src/React/ReactButtonControls.luau -->

The Story creates the element and passes in controls through the `props` argument.

<!-- code-sample: workspace/code-samples/src/React/ReactButtonControls.story.luau -->

Opening the `ReactButtonControls` Story in Flipbook will include an accompanying panel for configuring the controls.

![[button-with-controls.png]]

As controls are modified the Story will live-reload with the new props.

![[button-with-controls-changed.png]]
