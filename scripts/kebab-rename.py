#!/usr/bin/env python3
"""Rename non-kebab files to kebab-case, fix frontmatter, fix headings, update wikilinks."""
import os, re, subprocess

BASE = "/Users/marin/Code/flipbook-docs/docs/docs"
os.chdir(BASE)

RENAMES = {
    "product/2026 Roadmap.md": ("product/2026-roadmap.md", "2026 Roadmap"),
    "product/2025-flipbook-product-spec/flipbook-product-wishlist/Flipbook product wishlist.base": ("product/2025-flipbook-product-spec/flipbook-product-wishlist/flipbook-product-wishlist.base", None),
    "product/2025-flipbook-product-spec/flipbook-product-wishlist/Anonymized usage metrics.md": ("product/2025-flipbook-product-spec/flipbook-product-wishlist/anonymized-usage-metrics.md", "Anonymized usage metrics"),
    "product/2025-flipbook-product-spec/flipbook-product-wishlist/Basic substories support.md": ("product/2025-flipbook-product-spec/flipbook-product-wishlist/basic-substories-support.md", "Basic substories support"),
    "product/2025-flipbook-product-spec/flipbook-product-wishlist/Click UI elements in the story preview to open them in the Explorer.md": ("product/2025-flipbook-product-spec/flipbook-product-wishlist/click-ui-elements-in-story-preview.md", "Click UI elements in the story preview to open them in the Explorer"),
    "product/2025-flipbook-product-spec/flipbook-product-wishlist/Device emulator.md": ("product/2025-flipbook-product-spec/flipbook-product-wishlist/device-emulator.md", "Device emulator"),
    "product/2025-flipbook-product-spec/flipbook-product-wishlist/Dropdown to select which theme to use right from the story.md": ("product/2025-flipbook-product-spec/flipbook-product-wishlist/dropdown-theme-selector.md", "Dropdown to select which theme to use right from the story"),
    "product/2025-flipbook-product-spec/flipbook-product-wishlist/Embed into experience.md": ("product/2025-flipbook-product-spec/flipbook-product-wishlist/embed-into-experience.md", "Embed into experience"),
    "product/2025-flipbook-product-spec/flipbook-product-wishlist/FigJam-style collaboration with other users in the same TeamCreate session. Stickers. Draw. Sticky notes.md": ("product/2025-flipbook-product-spec/flipbook-product-wishlist/figjam-collaboration.md", "FigJam-style collaboration"),
    "product/2025-flipbook-product-spec/flipbook-product-wishlist/Full compatibility with UI Labs.md": ("product/2025-flipbook-product-spec/flipbook-product-wishlist/full-ui-labs-compatibility.md", "Full compatibility with UI Labs"),
    "product/2025-flipbook-product-spec/flipbook-product-wishlist/Improved FTUX.md": ("product/2025-flipbook-product-spec/flipbook-product-wishlist/improved-ftux.md", "Improved FTUX"),
    "product/2025-flipbook-product-spec/flipbook-product-wishlist/Include docs right in the plugin.md": ("product/2025-flipbook-product-spec/flipbook-product-wishlist/docs-in-plugin.md", "Include docs right in the plugin"),
    "product/2025-flipbook-product-spec/flipbook-product-wishlist/Maximize story view.md": ("product/2025-flipbook-product-spec/flipbook-product-wishlist/maximize-story-view.md", "Maximize story view"),
    "product/2025-flipbook-product-spec/flipbook-product-wishlist/Measuring tool.md": ("product/2025-flipbook-product-spec/flipbook-product-wishlist/measuring-tool.md", "Measuring tool"),
    "product/2025-flipbook-product-spec/flipbook-product-wishlist/Middleware to wrap a story.md": ("product/2025-flipbook-product-spec/flipbook-product-wishlist/story-middleware.md", "Middleware to wrap a story"),
    "product/2025-flipbook-product-spec/flipbook-product-wishlist/Module loading is buggy.md": ("product/2025-flipbook-product-spec/flipbook-product-wishlist/module-loading-buggy.md", "Module loading is buggy"),
    "product/2025-flipbook-product-spec/flipbook-product-wishlist/No storybook required.md": ("product/2025-flipbook-product-spec/flipbook-product-wishlist/no-storybook-required.md", "No storybook required"),
    "product/2025-flipbook-product-spec/flipbook-product-wishlist/Pin favorite storybooks to the top.md": ("product/2025-flipbook-product-spec/flipbook-product-wishlist/pin-favorite-storybooks.md", "Pin favorite storybooks to the top"),
    "product/2025-flipbook-product-spec/flipbook-product-wishlist/Preview GuiObjects by selecting them.md": ("product/2025-flipbook-product-spec/flipbook-product-wishlist/preview-guiobjects.md", "Preview GuiObjects by selecting them"),
    "product/2025-flipbook-product-spec/flipbook-product-wishlist/Quickly create screenshots of the story in various dimensions.md": ("product/2025-flipbook-product-spec/flipbook-product-wishlist/story-screenshots.md", "Quickly create screenshots of the story in various dimensions"),
    "product/2025-flipbook-product-spec/flipbook-product-wishlist/Report bugs from Flipbook that get posted to GitHub.md": ("product/2025-flipbook-product-spec/flipbook-product-wishlist/bug-reporting.md", "Report bugs from Flipbook that get posted to GitHub"),
    "product/2025-flipbook-product-spec/flipbook-product-wishlist/Story stack traces are a nightmare.md": ("product/2025-flipbook-product-spec/flipbook-product-wishlist/story-stack-traces.md", "Story stack traces are a nightmare"),
    "product/2025-flipbook-product-spec/flipbook-product-wishlist/Studio Mode.md": ("product/2025-flipbook-product-spec/flipbook-product-wishlist/studio-mode.md", "Studio Mode"),
    "product/2025-flipbook-product-spec/flipbook-product-wishlist/Tabs to preview and jump between stories.md": ("product/2025-flipbook-product-spec/flipbook-product-wishlist/story-tabs.md", "Tabs to preview and jump between stories"),
    "product/2025-flipbook-product-spec/flipbook-product-wishlist/TeamCreate enhancements.md": ("product/2025-flipbook-product-spec/flipbook-product-wishlist/teamcreate-enhancements.md", "TeamCreate enhancements"),
    "product/2025-flipbook-product-spec/flipbook-product-wishlist/Toolbar with various actions that can be dragged to other locations on the screen.md": ("product/2025-flipbook-product-spec/flipbook-product-wishlist/configurable-toolbar.md", "Toolbar with various actions that can be dragged to other locations on the screen"),
    "product/2025-flipbook-product-spec/flipbook-product-wishlist/Untitled.md": ("product/2025-flipbook-product-spec/flipbook-product-wishlist/untitled.md", "Untitled"),
    "product/2025-flipbook-product-spec/flipbook-product-wishlist/Use a dotted background like Figma and UI Labs do.md": ("product/2025-flipbook-product-spec/flipbook-product-wishlist/dotted-background.md", "Use a dotted background like Figma and UI Labs do"),
    "product/2025-flipbook-product-spec/flipbook-product-wishlist/Validate that colors contrast well together for accessibility.md": ("product/2025-flipbook-product-spec/flipbook-product-wishlist/accessibility-color-contrast.md", "Validate that colors contrast well together for accessibility"),
    "product/2025-flipbook-product-spec/flipbook-product-wishlist/Zoom in-out on a story.md": ("product/2025-flipbook-product-spec/flipbook-product-wishlist/zoom-controls.md", "Zoom in-out on a story"),
    "proposals/Proposals.base": ("proposals/proposals.base", None),
    "proposals/Create a flipbook package.md": ("proposals/create-flipbook-package.md", "Create a flipbook package"),
    "proposals/Documentation stories.md": ("proposals/documentation-stories.md", "Documentation stories"),
    "proposals/Implement new modular story format.md": ("proposals/modular-story-format.md", "Implement new modular story format"),
    "proposals/Migrate from Moonwave to Docusaurus.md": ("proposals/migrate-moonwave-to-docusaurus.md", "Migrate from Moonwave to Docusaurus"),
    "proposals/Rename of storybook files.md": ("proposals/rename-storybook-files.md", "Rename of storybook files"),
    "proposals/Roblox styled native UI.md": ("proposals/roblox-styled-native-ui.md", "Roblox styled native UI"),
    "proposals/Story Renderer Spec.md": ("proposals/story-renderer-spec.md", "Story Renderer Spec"),
    "proposals/Story and Storybook typechecking.md": ("proposals/story-storybook-typechecking.md", "Story and Storybook typechecking"),
    "proposals/Storyteller API.md": ("proposals/storyteller-api.md", "Storyteller API"),
    "tech/Anonymized usage telemetry.md": ("tech/anonymized-usage-telemetry.md", "Anonymized usage telemetry"),
    "tech/Backend stack.md": ("tech/backend-stack.md", "Backend stack"),
    "tech/Documentation Sharing.md": ("tech/documentation-sharing.md", "Documentation Sharing"),
    "tech/Flipbook Mounts Anywhere.md": ("tech/flipbook-mounts-anywhere.md", "Flipbook Mounts Anywhere"),
    "tech/Flipbook for Foundation.md": ("tech/flipbook-for-foundation.md", "Flipbook for Foundation"),
    "tech/Flipbook \u2192 Roblox Internal Deployments.md": ("tech/flipbook-roblox-internal-deployments.md", "Flipbook \u2192 Roblox Internal Deployments"),
    "tech/Instance Collector.md": ("tech/instance-collector.md", "Instance Collector"),
    "tech/Luau API Diffing.md": ("tech/luau-api-diffing.md", "Luau API Diffing"),
    "tech/Module Loader.md": ("tech/module-loader.md", "Module Loader"),
    "tech/Publishing to Rotriever.md": ("tech/publishing-to-rotriever.md", "Publishing to Rotriever"),
    "tech/Story Container.md": ("tech/story-container.md", "Story Container"),
    "tech/Tech 1.md": ("tech/tech-1.md", "Tech 1"),
    "tech/Changewright CLI/Changewright CLI.md": ("tech/changewright-cli/changewright-cli.md", "Changewright CLI"),
    "tech/Changewright CLI/Task breakdown/Task breakdown.base": ("tech/changewright-cli/task-breakdown/task-breakdown.base", None),
    "tech/Changewright CLI/Task breakdown/Changelog entries can specify the version component to bump (major, minor, patch).md": ("tech/changewright-cli/task-breakdown/changelog-version-bump.md", "Changelog entries can specify the version component to bump"),
    "tech/Changewright CLI/Task breakdown/Create a workflow to build a Foreman-Rokit compatible binary (on all platforms) to attach with releases.md": ("tech/changewright-cli/task-breakdown/build-binary-workflow.md", "Create a workflow to build a Foreman-Rokit compatible binary"),
    "tech/Changewright CLI/Task breakdown/Create the check command.md": ("tech/changewright-cli/task-breakdown/create-check-command.md", "Create the check command"),
    "tech/Changewright CLI/Task breakdown/Create the init command.md": ("tech/changewright-cli/task-breakdown/create-init-command.md", "Create the init command"),
    "tech/Changewright CLI/Task breakdown/Create the release command.md": ("tech/changewright-cli/task-breakdown/create-release-command.md", "Create the release command"),
    "tech/Changewright CLI/Task breakdown/Foundation glue code to adopt changewright.md": ("tech/changewright-cli/task-breakdown/foundation-glue-code.md", "Foundation glue code to adopt changewright"),
    "tech/Changewright CLI/Task breakdown/Generate a default changewright.toml config file.md": ("tech/changewright-cli/task-breakdown/generate-default-config.md", "Generate a default changewright.toml config file"),
    "tech/Changewright CLI/Task breakdown/Write a decent semver parser.md": ("tech/changewright-cli/task-breakdown/write-semver-parser.md", "Write a decent semver parser"),
    "tech/Roblox Internal Support/Bringing in Internal Roblox Contributions.md": ("tech/roblox-internal-support/bringing-in-internal-contributions.md", "Bringing in Internal Roblox Contributions"),
    "tech/Roblox Internal Support/Flipbook - Developer Storybook notes with Vincent.md": ("tech/roblox-internal-support/developer-storybook-notes.md", "Flipbook - Developer Storybook notes with Vincent"),
    "tech/Roblox Internal Support/Flipbook Hack Week TODO.md": ("tech/roblox-internal-support/hack-week-todo.md", "Flipbook Hack Week TODO"),
    "tech/Roblox Internal Support/Flipbook Internal 2025.md": ("tech/roblox-internal-support/flipbook-internal-2025.md", "Flipbook Internal 2025"),
    "tech/Roblox Internal Support/Flipbook Internal update to Studio Plugins folks.md": ("tech/roblox-internal-support/internal-update-studio-plugins.md", "Flipbook Internal update to Studio Plugins folks"),
    "tech/Roblox Internal Support/Flipbook consolidate recent PRs.md": ("tech/roblox-internal-support/consolidate-recent-prs.md", "Flipbook consolidate recent PRs"),
    "tech/Roblox Internal Support/Flipbook internal release strategy.md": ("tech/roblox-internal-support/internal-release-strategy.md", "Flipbook internal release strategy"),
    "tech/Roblox Internal Support/Flipbook support for Developer Storybook.md": ("tech/roblox-internal-support/flipbook-support-developer-storybook.md", "Flipbook support for Developer Storybook"),
    "tech/Roblox Internal Support/Flipbook \u2192 Studio release flow.md": ("tech/roblox-internal-support/flipbook-studio-release-flow.md", "Flipbook \u2192 Studio release flow"),
    "tech/Roblox Internal Support/Internal mirroring workflow.md": ("tech/roblox-internal-support/internal-mirroring-workflow.md", "Internal mirroring workflow"),
    "tech/Roblox Internal Support/October Roblox internal notes.md": ("tech/roblox-internal-support/october-internal-notes.md", "October Roblox internal notes"),
    "tech/Roblox Internal Support/RequestInternal switch.md": ("tech/roblox-internal-support/request-internal-switch.md", "RequestInternal switch"),
    "tech/Roblox Internal Support/Roblox Internal Support.md": ("tech/roblox-internal-support/roblox-internal-support.md", "Roblox Internal Support"),
    "tech/Roblox Internal Support/RobloxInternal package.md": ("tech/roblox-internal-support/roblox-internal-package.md", "RobloxInternal package"),
    "tech/Roblox Internal Support/Storyteller interim Roblox support.md": ("tech/roblox-internal-support/storyteller-interim-roblox-support.md", "Storyteller interim Roblox support"),
    "tech/Story Controls/story-controls-api.md": ("tech/story-controls/story-controls-api.md", None),
    "tech/Story Controls/story-controls.md": ("tech/story-controls/story-controls.md", None),
    "tech/Story Controls/Control Data Types/Control Data Types.base": ("tech/story-controls/control-data-types/control-data-types.base", None),
    "tech/Story Controls/Control Data Types/Boolean.md": ("tech/story-controls/control-data-types/boolean.md", "Boolean"),
    "tech/Story Controls/Control Data Types/Callback.md": ("tech/story-controls/control-data-types/callback.md", "Callback"),
    "tech/Story Controls/Control Data Types/Check.md": ("tech/story-controls/control-data-types/check.md", "Check"),
    "tech/Story Controls/Control Data Types/Color.md": ("tech/story-controls/control-data-types/color.md", "Color"),
    "tech/Story Controls/Control Data Types/Date.md": ("tech/story-controls/control-data-types/date.md", "Date"),
    "tech/Story Controls/Control Data Types/File.md": ("tech/story-controls/control-data-types/file.md", "File"),
    "tech/Story Controls/Control Data Types/InlineCheck.md": ("tech/story-controls/control-data-types/inline-check.md", "InlineCheck"),
    "tech/Story Controls/Control Data Types/InlineRadio.md": ("tech/story-controls/control-data-types/inline-radio.md", "InlineRadio"),
    "tech/Story Controls/Control Data Types/Instance.md": ("tech/story-controls/control-data-types/instance.md", "Instance"),
    "tech/Story Controls/Control Data Types/MultiSelect.md": ("tech/story-controls/control-data-types/multi-select.md", "MultiSelect"),
    "tech/Story Controls/Control Data Types/Number.md": ("tech/story-controls/control-data-types/number.md", "Number"),
    "tech/Story Controls/Control Data Types/Object.md": ("tech/story-controls/control-data-types/object.md", "Object"),
    "tech/Story Controls/Control Data Types/Radio.md": ("tech/story-controls/control-data-types/radio.md", "Radio"),
    "tech/Story Controls/Control Data Types/Select.md": ("tech/story-controls/control-data-types/select.md", "Select"),
    "tech/Story Controls/Control Data Types/Sequence.md": ("tech/story-controls/control-data-types/sequence.md", "Sequence"),
    "tech/Story Controls/Control Data Types/Slider.md": ("tech/story-controls/control-data-types/slider.md", "Slider"),
    "tech/Story Controls/Control Data Types/Text.md": ("tech/story-controls/control-data-types/text.md", "Text"),
    "tech/Story Controls/Control Data Types/UDim.md": ("tech/story-controls/control-data-types/udim.md", "UDim"),
    "tech/Story Controls/Control Data Types/UDim2.md": ("tech/story-controls/control-data-types/udim2.md", "UDim2"),
    "tech/Story Controls/Control Data Types/Vector2.md": ("tech/story-controls/control-data-types/vector2.md", "Vector2"),
    "tech/Story Controls/Control Data Types/Vector3.md": ("tech/story-controls/control-data-types/vector3.md", "Vector3"),
    "tech/Storybook Embedding/Storybook Embedding.md": ("tech/storybook-embedding/storybook-embedding.md", "Storybook Embedding"),
    "tech/Storybook Embedding/flipbook-mounts-anywhere.md": ("tech/storybook-embedding/flipbook-mounts-anywhere.md", None),
}

BASE_REPLACEMENTS = {
    '"[[Proposals.base]]"': '"[[proposals.base]]"',
    '"[[Flipbook product wishlist.base]]"': '"[[flipbook-product-wishlist.base]]"',
    '"[[Task breakdown.base]]"': '"[[task-breakdown.base]]"',
    '"[[Control Data Types.base]]"': '"[[control-data-types.base]]"',
}

LINK_MAP = [
    ("Flipbook \u2192 Roblox Internal Deployments", "tech/flipbook-roblox-internal-deployments"),
    ("Flipbook - Developer Storybook notes with Vincent", "tech/roblox-internal-support/developer-storybook-notes"),
    ("Flipbook Internal update to Studio Plugins folks", "tech/roblox-internal-support/internal-update-studio-plugins"),
    ("Flipbook \u2192 Studio release flow", "tech/roblox-internal-support/flipbook-studio-release-flow"),
    ("Storyteller interim Roblox support", "tech/roblox-internal-support/storyteller-interim-roblox-support"),
    ("Flipbook support for Developer Storybook", "tech/roblox-internal-support/flipbook-support-developer-storybook"),
    ("Bringing in Internal Roblox Contributions", "tech/roblox-internal-support/bringing-in-internal-contributions"),
    ("Flipbook consolidate recent PRs", "tech/roblox-internal-support/consolidate-recent-prs"),
    ("Flipbook internal release strategy", "tech/roblox-internal-support/internal-release-strategy"),
    ("Flipbook Hack Week TODO", "tech/roblox-internal-support/hack-week-todo"),
    ("Flipbook Internal 2025", "tech/roblox-internal-support/flipbook-internal-2025"),
    ("Internal mirroring workflow", "tech/roblox-internal-support/internal-mirroring-workflow"),
    ("October Roblox internal notes", "tech/roblox-internal-support/october-internal-notes"),
    ("RequestInternal switch", "tech/roblox-internal-support/request-internal-switch"),
    ("RobloxInternal package", "tech/roblox-internal-support/roblox-internal-package"),
    ("Roblox Internal Support", "tech/roblox-internal-support/roblox-internal-support"),
    ("Flipbook product wishlist.base", "flipbook-product-wishlist.base"),
    ("Story and Storybook typechecking", "proposals/story-storybook-typechecking"),
    ("Implement new modular story format", "proposals/modular-story-format"),
    ("Migrate from Moonwave to Docusaurus", "proposals/migrate-moonwave-to-docusaurus"),
    ("Create a flipbook package", "proposals/create-flipbook-package"),
    ("Rename of storybook files", "proposals/rename-storybook-files"),
    ("Roblox styled native UI", "proposals/roblox-styled-native-ui"),
    ("Story Renderer Spec", "proposals/story-renderer-spec"),
    ("Documentation stories", "proposals/documentation-stories"),
    ("Storyteller API", "proposals/storyteller-api"),
    ("Proposals.base", "proposals.base"),
    ("Anonymized usage telemetry", "tech/anonymized-usage-telemetry"),
    ("Documentation Sharing", "tech/documentation-sharing"),
    ("Flipbook Mounts Anywhere", "tech/flipbook-mounts-anywhere"),
    ("Flipbook for Foundation", "tech/flipbook-for-foundation"),
    ("Instance Collector", "tech/instance-collector"),
    ("Luau API Diffing", "tech/luau-api-diffing"),
    ("Module Loader", "tech/module-loader"),
    ("Publishing to Rotriever", "tech/publishing-to-rotriever"),
    ("Story Container", "tech/story-container"),
    ("Backend stack", "tech/backend-stack"),
    ("Changewright CLI", "tech/changewright-cli/changewright-cli"),
    ("Storybook Embedding", "tech/storybook-embedding/storybook-embedding"),
    ("2026 Roadmap", "product/2026-roadmap"),
    ("Task breakdown.base", "task-breakdown.base"),
    ("Control Data Types.base", "control-data-types.base"),
]


def normalize(s):
    return re.sub(r'[^a-z0-9]', '', s.lower())


def titles_match(a, b):
    return normalize(a) == normalize(b)


def parse_frontmatter(text):
    if not text.startswith('---'):
        return None, text
    end = text.find('\n---', 3)
    if end == -1:
        return None, text
    fm = text[:end + 4]
    body = text[end + 4:]
    if body.startswith('\n'):
        body = body[1:]
    return fm, body


def update_frontmatter(fm, title):
    if fm is None:
        return f'---\naliases: [{title}]\nlinter-yaml-title-alias: {title}\n---'
    for old, new in BASE_REPLACEMENTS.items():
        fm = fm.replace(old, new)
    # Remove existing aliases and linter lines
    fm = re.sub(r'^aliases:.*\n', '', fm, flags=re.MULTILINE)
    fm = re.sub(r'^linter-yaml-title-alias:.*\n', '', fm, flags=re.MULTILINE)
    insert = f'aliases: [{title}]\nlinter-yaml-title-alias: {title}\n'
    fm = fm.replace('---\n', '---\n' + insert, 1)
    return fm


def find_first_h1(body):
    lines = body.split('\n')
    in_code = False
    for line in lines:
        if re.match(r'^```|^~~~', line):
            in_code = not in_code
        if not in_code and re.match(r'^# ', line):
            return line[2:].strip()
    return None


def shift_all_headings(body):
    lines = body.split('\n')
    result = []
    in_code = False
    for line in lines:
        if re.match(r'^```|^~~~', line):
            in_code = not in_code
        if not in_code and re.match(r'^#+\s', line):
            line = '#' + line
        result.append(line)
    return '\n'.join(result)


def transform_md(content, title):
    fm, body = parse_frontmatter(content)
    fm = update_frontmatter(fm, title)
    first_h1 = find_first_h1(body)
    if first_h1 is not None and titles_match(first_h1, title):
        pass  # H1 already matches; leave headings alone
    else:
        body = shift_all_headings(body)
        body = f'# {title}\n\n' + body.lstrip('\n')
    if fm:
        return fm + '\n' + body
    return body


def replace_wikilinks(content, link_map):
    for old_text, new_slug in link_map:
        old_esc = re.escape(old_text)
        def make_repl(m, old=old_text, slug=new_slug):
            existing_display = m.group(1)
            display = existing_display if existing_display else old
            if slug == display:
                return f'[[{slug}]]'
            return f'[[{slug}|{display}]]'
        content = re.sub(
            r'\[\[' + old_esc + r'(?:\|([^\]]*))?\]\]',
            make_repl, content
        )
    return content


errors = []
for old, (new, title) in RENAMES.items():
    old_abs = os.path.join(BASE, old)
    new_abs = os.path.join(BASE, new)
    if not os.path.exists(old_abs):
        print(f"SKIP: {old}")
        continue
    os.makedirs(os.path.dirname(new_abs), exist_ok=True)
    if old.endswith('.md') and title is not None:
        with open(old_abs, 'r', encoding='utf-8') as f:
            content = f.read()
        with open(old_abs, 'w', encoding='utf-8') as f:
            f.write(transform_md(content, title))
    elif old.endswith('.md'):
        with open(old_abs, 'r', encoding='utf-8') as f:
            content = f.read()
        updated = content
        for bk, bv in BASE_REPLACEMENTS.items():
            updated = updated.replace(bk, bv)
        if updated != content:
            with open(old_abs, 'w', encoding='utf-8') as f:
                f.write(updated)
    result = subprocess.run(
        ['git', 'mv', old_abs, new_abs],
        cwd='/Users/marin/Code/flipbook-docs',
        capture_output=True, text=True
    )
    if result.returncode != 0:
        print(f"ERROR: {old}: {result.stderr.strip()}")
        errors.append(old)
    else:
        print(f"OK: {os.path.basename(new)}")

updated_count = 0
for root, dirs, files in os.walk(BASE):
    dirs[:] = [d for d in dirs if d != '.obsidian']
    for fname in files:
        if not fname.endswith('.md'):
            continue
        fpath = os.path.join(root, fname)
        with open(fpath, 'r', encoding='utf-8') as f:
            original = f.read()
        updated = replace_wikilinks(original, LINK_MAP)
        if updated != original:
            with open(fpath, 'w', encoding='utf-8') as f:
                f.write(updated)
            updated_count += 1

print(f"\nDone. {len(RENAMES)-len(errors)} renamed, {updated_count} link files updated.")
if errors:
    print("Errors:", errors)
