---
sidebar_position: 3
---

# Story Format

## Storybook

| Name         | Type         | Notes                                                                                             |
| :----------- | :----------- | :------------------------------------------------------------------------------------------------ |
| `roact`      | `Roact`      | The version of Roact to use across all stories.                                                   |
| `storyRoots` | `{Instance}` | An array of instances to search the descendants of for `.story` files.                            |
| `name`       | `string?`    | The name to use for the storybook. This defaults to `script.Name` with `.storybook` stripped off. |

## Story

| Name       | Type             | Notes                                                                                                                                           |
| :--------- | :--------------- | :---------------------------------------------------------------------------------------------------------------------------------------------- |
| `story`    | `StoryComponent` | The component to mount.                                                                                                                         |
| `controls` | `StoryControls?` | An object of controls that are supplied to the story as props.                                                                                  |
| `name`     | `string?`        | The name of the story. This defaults to `script.Name`.                                                                                          |
| `roact`    | `Roact?`         | The copy of Roact to use when mounting the story. This should be the same as the one used when calling `Roact.createElement` in the story file. |
| `summary`  | `string?`        | A summary of the story to give others an introduction to the component.                                                                         |
