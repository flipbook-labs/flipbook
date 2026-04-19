---
notion-id: 0225021b-27e7-4598-8514-2b19370139ee
base: "[[Proposals.base]]"
Author:
  - Marin Minnerly
Tags: []
Status: Done
Created: 2023-12-12T14:08:00
Approval: Drafting
aliases: [Problem]
linter-yaml-title-alias: Problem
---

# Problem

Moonwave sits on top of [Docusaurus](https://docusaurus.io/) to create a documentation site with API docs made from extracting doc comments in the source code. But flipbook doesn’t really need that.

We currently use Moonwave because it was convenient to setup a docs site, but since we’re not utilizing Moonwave’s core feature, we have a forever empty “API” page in our nav that we can’t remove.

# Solution

Instead of using Moonwave, we could port over to Docusaurus. This removes one layer of abstraction.

Docusaurus can do docs versioning, which will be important between flipbook v1 and v2.

# Open Questions

* Could we support viewing flipbook’s docs within flipbook? Parse all the markdown we can and throw out any MDX?
