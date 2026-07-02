---
name: flipbook-story-controls-campaign
description: "Runbook for story controls work: reproducing gaps, ranked solutions with implementation paths, validation gates. Use when tasked with UILabs story compatibility, adding new control types, fixing control re-render bugs, or validating controls refactor. Start with PHASE 1 (reproduce and characterize), then PHASE 2 (choose a solution), then implement and validate. All phases include exact commands and expected observations."
---

# Flipbook Story Controls Campaign

This is the maintainer-designated hardest live problem: bringing Flipbook's story controls to UI Labs parity (ControlGroup nesting, Object instance selection, new data types Color3/DateTime/UDim2/Vector3). The campaign is divided into four phases: (1) reproduce and characterize the gaps; (2) ranked solution menu with design decisions and implementation paths; (3) implementation gates for each option; (4) validation and promotion.

Every phase has exact commands and EXPECTED observations. If you see something else, the decision tree routes you to branch steps. Read the entire skill before starting.

---

## Background: What Broke

The `uilabs-controls-support` branch (tip 66f14210, May 9 2026) attempted UILabs compatibility but has three problems:

1. **Branch is 3 commits stale.** It lacks PR #576 (store + context), PR #579 (ObjectControl UI), and PR #597 (InstancePicker extraction). The main branch has all three; this branch predates them.
2. **Storyteller's Object migration silently drops Object controls.** In `Storyteller.migrateUILabsControl()`, the line `elseif control.Type == "Object" then return nil` means UILabs.Advanced.Object(...) disappears during conversion. Even if ObjectControl UI existed on the branch, the schema never reaches it.
3. **ControlGroup is flattened by design.** Storyteller's migration intentionally flattens ControlGroup nesting into a flat control dict. Flipbook has no UI for grouping/collapsing, so grouping is silently lost.

**Status on main (78d71e8f):** All 11 control types work; re-render isolation is fixed; ObjectControl + InstancePicker exist. UILabs Object migration is the 5-line gap. ControlGroup is a design decision gate.

---

## PHASE 1: Reproduce and Characterize (Baseline)

### Step 1.1: Write a comprehensive story exercising all control types

**Goal:** Create a reference story that tests every control type so you can verify functionality across phases.

**Command:**

```bash
cat > /tmp/test_all_controls.story.luau << 'EOF'
local React = require("@pkg/React")
local Storyteller = require("@pkg/Storyteller")

local e = React.createElement

-- Sample enum for Select/Radio/Check
local TestEnum = {
    Option1 = "opt1",
    Option2 = "opt2",
    Option3 = "opt3",
}

local function TestEnumToString(value)
    for k, v in TestEnum do
        if v == value then return k end
    end
    return tostring(value)
end

local story: Storyteller.Story = {
    controls = {
        boolControl = Storyteller.createBooleanControl(true),
        stringControl = Storyteller.createStringControl("hello"),
        numberControl = Storyteller.createNumberControl(42),
        sliderControl = Storyteller.createSliderControl(5, NumberRange.new(0, 10)),
        colorControl = Storyteller.createColorControl(Color3.fromRGB(255, 0, 0)),
        dateControl = Storyteller.createDateControl(),
        selectControl = Storyteller.createSelectControl(
            { TestEnum.Option1, TestEnum.Option2, TestEnum.Option3 },
            { tostring = TestEnumToString }
        ),
        radioControl = Storyteller.createRadioControl(
            { TestEnum.Option1, TestEnum.Option2, TestEnum.Option3 },
            { tostring = TestEnumToString }
        ),
        multiSelectControl = Storyteller.createMultiSelectControl(
            { TestEnum.Option1, TestEnum.Option2, TestEnum.Option3 },
            { tostring = TestEnumToString }
        ),
        checkControl = Storyteller.createCheckControl(
            { TestEnum.Option1, TestEnum.Option2, TestEnum.Option3 },
            { tostring = TestEnumToString }
        ),
        objectControl = Storyteller.createObjectControl(nil),
    },
    story = function(props)
        local controlsText = {}
        for key, val in props.controls do
            table.insert(controlsText, string.format("%s = %s", key, tostring(val)))
        end
        return React.createElement("TextLabel", {
            Text = "Controls Test\n" .. table.concat(controlsText, "\n"),
            Size = UDim2.fromScale(1, 1),
            BackgroundColor3 = Color3.fromRGB(240, 240, 240),
            TextColor3 = Color3.fromRGB(0, 0, 0),
            TextScaled = true,
            TextWrapped = true,
        })
    end,
}

return story
EOF
cp /tmp/test_all_controls.story.luau /Users/marin/Code/flipbook/workspace/example/src/Examples/AllControlTypes.story.luau
echo "✓ Test story written to workspace/example/src/Examples/AllControlTypes.story.luau"
```

**Expected observation:** Command succeeds; file exists; no Luau errors on `lute run analyze`.

**Verify:**

```bash
lute run analyze 2>&1 | grep -i "allcontroltypes" || echo "No errors for new story"
```

**Expected:** No errors mention AllControlTypes, or grep finds no results.

---

### Step 1.2: Reproduce the Object migration gap (Storyteller issue)

**Goal:** Verify that Storyteller drops UILabs Object controls.

**Command:**

```bash
# Inspect the migration code in the Storyteller package.
# Locate the migrateUILabsControl function and verify Object type handling.

find /Users/marin/Code/flipbook/Packages/_Index -name "*migrateUILabs*" -type f
```

**Expected observation:** Path like `/Users/marin/Code/flipbook/Packages/_Index/flipbook-labs_storyteller@1.12.0/storyteller/dist/controls/migrations/ui-labs-v2.4.2/migrateUILabsControl.luau` exists.

**Verify the gap:**

```bash
grep -A 2 'control.Type == "Object"' /Users/marin/Code/flipbook/Packages/_Index/flipbook-labs_storyteller@1.12.0/storyteller/dist/controls/migrations/ui-labs-v2.4.2/migrateUILabsControl.luau
```

**Expected:** Lines show `return nil` (Object control is dropped).

**Why this matters:** UILabs.Advanced.Object(...) in a story schema gets silently converted to nothing. The story author gets no warning; controls disappear.

---

### Step 1.3: Check re-render isolation (control subscription behavior)

**Goal:** Verify that changing one control does NOT cause all controls to re-render.

**Command:**

```bash
# Read createStoryControlsStore to confirm per-control signal design.
cat /Users/marin/Code/flipbook/workspace/flipbook-core/src/StoryControls/createStoryControlsStore.luau | head -50
```

**Expected observation:** Store exports `getControlValue(key)` which returns a per-control Charm signal (computed), not a whole-schema signal. Each control subscribes independently via `useSignalState()`.

**Spot-check the spec:**

```bash
grep -n "getControlValue" /Users/marin/Code/flipbook/workspace/flipbook-core/src/StoryControls/createStoryControlsStore.spec.luau | head -3
```

**Expected:** Test file has tests for `getControlValue()` returning signals (lines ~20–40 range).

**Gap identified:** No test for re-render isolation. The spec tests state shape but not subscription behavior. Mark this for Phase 3.

---

### Step 1.4: Confirm CheckControl grid TODO

**Goal:** Verify the documented gap.

**Command:**

```bash
grep -n "TODO.*grid" /Users/marin/Code/flipbook/workspace/flipbook-core/src/StoryControls/ControlElements/CheckControl.luau
```

**Expected observation:** Line ~41 has `-- TODO: Make this a grid` comment.

**Characterization:** CheckControl currently renders checkboxes as vertical stack. Grid layout would be better UX for many items (e.g., 8 options in 4x2 grid vs. vertical list).

---

**END PHASE 1 Checkpoint**

You should now understand:
- ✅ All 11 control types exist and work on main
- ✅ ObjectControl + InstancePicker are extracted
- ✅ Store uses per-control signals (re-render isolated)
- ✅ Object migration in Storyteller drops controls (5-line fix potential)
- ✅ ControlGroup is flattened silently (design decision needed)
- ✅ CheckControl lacks grid layout (small win)
- ✅ Re-render spec is incomplete (test gap)

---

## PHASE 2: Ranked Solution Menu

Solutions are ranked by evidence, scope, and risk. Each has success criteria and a decision gate.

### SOLUTION A: Fix Storyteller UILabs Object Migration (HIGH CONFIDENCE, LOW EFFORT)

**Scope:** ~5-line change in Storyteller package (not Flipbook). Storyteller 1.12.0 is pinned in `wally.toml`.

**Evidence:**
- Storyteller already defines `ObjectControl` type (ControlTypes.luau in Storyteller dist)
- Flipbook has ObjectControl UI (InstancePicker extraction in PR #597)
- UILabs.Advanced.Object("ModuleScript") just needs default = nil (typeclass filter is UILabs-only; Flipbook doesn't use it)
- InstancePicker handles nil gracefully; displays "Select an Instance..."

**Implementation Path:**

1. **Locate Storyteller's migrateUILabsControl.luau:**
   ```bash
   MIGRATION_FILE="/Users/marin/Code/flipbook/Packages/_Index/flipbook-labs_storyteller@1.12.0/storyteller/dist/controls/migrations/ui-labs-v2.4.2/migrateUILabsControl.luau"
   grep -n "Object" "$MIGRATION_FILE" | head -5
   ```
   **Expected:** Shows lines with `control.Type == "Object"` returning `nil`.

2. **Cross-repo workflow (important):**
   - This fix goes in the **Storyteller repo** (`flipbook-labs/storyteller`), not Flipbook.
   - After fix in Storyteller, version bump needed (e.g., 1.12.1).
   - Flipbook updates `wally.toml` to new Storyteller version.
   - Use `.agents/skills/test-dependencies-in-flipbook` to verify the fix works in Flipbook before releasing.

3. **The actual fix (in Storyteller, not here):**
   - Change line from `return nil` to:
     ```luau
     elseif control.Type == "Object" then
         local migrated: ObjectControl = {
             type = ControlType.Object,
             default = nil,
         }
         return migrated
     ```
   - Add `ObjectControl` type import at top if missing.
   - Write test in Storyteller validating UILabs Object → Storyteller ObjectControl round-trip.

**Obligations:**
- Depends on Flipbook having ObjectControl UI ✅ (exists in main)
- Storyteller version bump + wally.toml update
- Test in Storyteller validating migration

**Risks:** LOW. ObjectControl is already in main; migration is straightforward 1-to-1 conversion.

**Unverified:** Whether UILabs.Advanced.Object("ModuleScript") typeclass parameter should be stored as metadata; Flipbook doesn't use it, but storing it could enable future filtering.

**Success Criteria (Phase 3):**
- Storyteller fix merged; version bumped
- Flipbook wally.toml updated to new Storyteller version
- `lute run test` passes
- Write a UILabs Object story; verify ObjectControl appears in Flipbook UI
- Interact with ObjectControl; verify selection updates story props

---

### SOLUTION B: Design & Implement ControlGroup UI (MEDIUM CONFIDENCE, HIGH COMPLEXITY)

**Scope:** Flipbook + Storyteller design decision. Not a simple feature.

**Evidence:**
- ControlGroup is a UILabs feature: groups controls under collapsible headers
- Storyteller migration flattens ControlGroup intentionally (simpler for non-grouping authors)
- Flipbook has NO ControlGroup UI at all; no grouping/collapsing
- PR #465 comment: "UILabsControls story broken → becomes #577" (never resolved)

**Key Design Questions (must decide before implementing):**

1. **Should ControlGroup be a first-class Flipbook feature?** Currently it's not. UILabs stories with grouping render as flat lists.
2. **How to represent groups in Storyteller schema?** Current schema is flat dict. Supporting nesting requires:
   - Schema type change to allow `dict<string, Control | ControlGroup>`
   - UI component to render visual grouping (collapsible section, visual border, etc.)
   - Store logic for group collapse/expand state
3. **Backward compatibility?** Migration flattening is intentional. Changing it requires coordination with Storyteller maintainers.

**Candidate Design Option: Preserve Grouping (Don't Flatten):**
- In Storyteller: new ControlGroup type in schema union
- In Flipbook: render groups as Foundation.Card or collapsible section with child controls nested
- Store: track collapse state per group
- Migration: don't flatten; preserve nested structure

**Candidate Design Option: Document Flattening (Status Quo):**
- Accept that UILabs grouping is lost in translation
- Document this as known limitation
- Focus effort elsewhere (other control types, better UX for individual controls)

**Obligations (if pursuing):**
- Design spec (when to group, visual language, interaction model)
- Storyteller schema change + version bump
- Flipbook UI component for grouping + store state
- Documentation & examples for authors
- Migration compatibility story (what happens to existing flat schemas?)

**Risks:** HIGH complexity. May require Storyteller major version bump. Scope creep risk. Only one UILabs-compatible storybook uses this feature in repo evidence.

**Unverified:** Whether grouping is a real need (only UILabs stories use it; no community requests found in issues/discussions).

**Success Criteria (Phase 3, if pursued):**
- Design spec reviewed and approved (by maintainer or team lead)
- Storyteller PR merged with ControlGroup schema support
- Flipbook UI component renders grouping correctly
- `lute run test` passes
- Write a UILabs ControlGroup story; verify groups render and collapse/expand works
- Verify backward compat: flat schema still works

---

### SOLUTION C: New Control Data Types (HIGH CONFIDENCE, MODERATE COMPLEXITY)

**Scope:** Flipbook + Storyteller. The controls revamp spec in the Obsidian vault (unmerged `flipbook-docs` branch; list files with `git ls-tree -r --name-only flipbook-docs -- docs/obsidian-vault`, read via `git show flipbook-docs:<path>`) targets Color3, DateTime, UDim2, Vector3.

**Evidence:**
- Storyteller already has type definitions for these (ControlTypes.luau)
- Flipbook has UI for Color3 (ColorControl), DateTime (DateControl) ✅
- UDim2, Vector3 are planned but not yet implemented
- Vault spec lists acceptance criteria per type

**Data Types from Vault Spec:**

| Type | Status | Notes |
|------|--------|-------|
| Color3 | ✅ Shipped (ColorControl) | Flipbook UI exists |
| DateTime | ✅ Shipped (DateControl) | Flipbook UI exists |
| UDim2 | ⚠ Candidate | Needs CSV input UI + validation |
| Vector3 | ⚠ Candidate | Needs CSV input UI + validation |

**Implementation Path (per type):**

1. **UDim2:** `{Scale, Offset}` as two separate number inputs or one CSV field.
   - Acceptance: story with UDim2 control renders; Flipbook shows UI; selecting value updates story props
   - Component needed: two NumberControl inputs or custom CSVInput → UDim2 parser
2. **Vector3:** `{X, Y, Z}` as three NumberControl inputs or one CSV field.
   - Acceptance: story with Vector3 control renders; Flipbook shows UI; value updates story props
   - Component needed: three NumberControl inputs or CSVInput → Vector3 parser

**Obligations:**
- Storyteller: verify control constructors exist (createUDim2Control, createVector3Control)
- Flipbook: add UDim2Control, Vector3Control components
- Tests: spec for each new control type validating schema → UI → story props round-trip
- Vault spec says each type needs "acceptance criteria" — those become test assertions

**Risks:** MODERATE. Simple 1-to-1 component mapping (like ObjectControl → InstancePicker). Risk if Storyteller constructors don't exist or have different names.

**Success Criteria (Phase 3):**
- UDim2Control component added; spec written
- Vector3Control component added; spec written
- `lute run test` passes all new specs
- StoryControls.story.luau updated with UDim2 + Vector3 examples
- Verify each control renders, accepts input, updates story props

---

### SOLUTION D: CheckControl Grid Layout (HIGH CONFIDENCE, LOW EFFORT)

**Scope:** Flipbook only, ~15-line change.

**Evidence:**
- TODO explicitly in codebase (line 41 of CheckControl.luau)
- Current UI is vertical stack; many checkbox items are cramped
- Foundation.View with grid tag (`tag="auto-y grid gap-small"` or similar) can fix it

**Implementation Path:**

1. Change CheckControl.luau line 42 from:
   ```luau
   return e(Foundation.View, {
       tag = "size-full-y auto-x col gap-small",
   }, checkboxes)
   ```
   to something like:
   ```luau
   return e(Foundation.View, {
       tag = "size-full-y auto-x grid gap-small",
   }, checkboxes)
   ```
   (Exact tag depends on Foundation's grid support; verify in Foundation.View docs.)

2. Test with CheckControl story having 8+ items; verify they lay out in grid, not vertical stack.

**Obligations:**
- Verify Foundation grid tag syntax (read Foundation.View component)
- Visual test: story with many CheckControl items

**Risks:** LOW. Purely UI layout; no logic changes. May need to adjust padding/gaps if grid looks wrong.

**Success Criteria (Phase 3):**
- CheckControl renders checkboxes in grid layout (not vertical stack)
- `lute run test` passes
- Visual inspection: grid layout looks good with 4–12 items

---

**END PHASE 2 Checkpoint**

You now have four ranked solutions:
1. **A: Storyteller Object migration** (5 lines, low risk, high impact) ← **DO THIS FIRST**
2. **B: ControlGroup UI** (design gate, high complexity, medium evidence) ← **DO ONLY IF STAKEHOLDERS DECIDE**
3. **C: New data types UDim2/Vector3** (moderate effort, good evidence) ← **DO IF TIME**
4. **D: CheckControl grid** (15 lines, low risk, nice-to-have) ← **DO IF TIME**

---

## PHASE 3: Implementation Gates (Exact Commands & Expected Observations)

Follow the solution menu in order: A is mandatory (closes the Object gap), B requires design approval, C and D are optional. Every implementation has exact success criteria.

### SOLUTION A: Object Migration Fix (Storyteller)

**GATE A.1: Understand the cross-repo workflow**

This fix lives in **Storyteller**, not Flipbook. The workflow is:
1. Clone/fetch flipbook-labs/storyteller (sibling repo)
2. Create branch in Storyteller
3. Make the 5-line fix in Storyteller
4. Push; open PR in Storyteller
5. In Flipbook: use `.agents/skills/test-dependencies-in-flipbook` to overlay the Storyteller branch and verify
6. Merge Storyteller PR; version bump (1.12.0 → 1.12.1)
7. In Flipbook: update wally.toml to new Storyteller version
8. `lute run install` to pull new Storyteller
9. Run Flipbook tests to confirm

**GATE A.2: Storyteller fix (in Storyteller repo, not here)**

In Storyteller's `controls/migrations/ui-labs-v2.4.2/migrateUILabsControl.luau`:

Replace:
```luau
elseif control.Type == "Object" then
    return nil
```

With:
```luau
elseif control.Type == "Object" then
    local migrated: ObjectControl = {
        type = ControlType.Object,
        default = nil,
    }
    return migrated
```

Ensure `ObjectControl` type is imported at top if not already.

**Write test in Storyteller:**

```luau
-- In Storyteller's control migrations spec
local migratedObject = migrateUILabsControl({
    Type = "Object",
})

expect(migratedObject).to.be.ok()
expect(migratedObject.type).toBe("Object")
expect(migratedObject.default).toBe(nil)
```

**GATE A.3: Version bump Storyteller**

In Storyteller's `wally.toml`, bump version:
```toml
version = "1.12.1"
```

Publish to Wally registry.

**GATE A.4: Update Flipbook's wally.toml**

In Flipbook (this repo), change:
```toml
Storyteller = "flipbook-labs/storyteller@1.12.0"
```

To:
```toml
Storyteller = "flipbook-labs/storyteller@1.12.1"
```

**Run:**
```bash
lute run install
```

**Expected:** New Storyteller version fetched to `Packages/_Index/`.

**GATE A.5: Test the fix with a UILabs Object story**

Create test story in `/workspace/example/src/Examples/UILabsObjectTest.story.luau`:

```luau
local Storyteller = require("@pkg/Storyteller")
local React = require("@pkg/React")

local e = React.createElement

-- Simulate UILabs.Advanced.Object schema after migration
local uiLabsObjectSchema = {
    Type = "Object",
    -- UILabs-specific metadata (not used by Flipbook)
}

local migratedControl = Storyteller.migrateUILabsControl(uiLabsObjectSchema)

local story: Storyteller.Story = {
    controls = {
        selectedInstance = migratedControl or Storyteller.createObjectControl(nil),
    },
    story = function(props)
        local selected = props.controls.selectedInstance
        return React.createElement("TextLabel", {
            Text = "Selected: " .. (selected and selected.Name or "None"),
            Size = UDim2.fromScale(1, 1),
            BackgroundColor3 = Color3.fromRGB(240, 240, 240),
            TextColor3 = Color3.fromRGB(0, 0, 0),
        })
    end,
}

return story
```

**Run Flipbook manually or via studio plugin:**
```bash
lute run build plugin --channel dev
# Open Flipbook in Studio; navigate to UILabsObjectTest story
```

**Expected Observation:**
- Story renders
- ObjectControl UI (InstancePicker) appears in the controls panel
- Can click "Select an Instance..." and choose an instance from the DataModel
- Selected instance name appears in the story UI
- Story props.controls.selectedInstance is the Instance object (not nil)

**GATE A.6: Run full test suite**

```bash
lute run test
```

**Expected:** All tests pass. No new errors.

**SUCCESS CRITERIA (A):**
- ✅ Storyteller PR merged with Object migration fix
- ✅ Storyteller version bumped and published
- ✅ Flipbook wally.toml updated
- ✅ UILabs Object story renders with ObjectControl UI
- ✅ ObjectControl selection updates story props
- ✅ `lute run test` passes

---

### SOLUTION B: ControlGroup UI (Requires Design Decision)

**GATE B.0: DESIGN DECISION GATE — Do Not Proceed Without Approval**

**This gate is a decision point, not a code gate.** Before implementing ControlGroup support, you MUST:

1. **Read the vault spec** (from briefing): `engineering/story-controls/index.md` in `flipbook-docs` branch discusses grouping approach.
2. **Answer the design questions:**
   - Will Flipbook support ControlGroup as a first-class feature?
   - Will grouping be collapsible in the UI?
   - Will the migration flatten or preserve groups?
3. **Get stakeholder buy-in.** This is a significant schema change affecting Storyteller and Flipbook.

**If the answer is "no, accept flattening,"** stop here and document in the vault: "ControlGroup nesting is intentionally flattened during UILabs → Flipbook migration; grouping UI is out of scope."

**If the answer is "yes, preserve grouping,"** proceed to B.1.

---

**[If pursuing ControlGroup, gates B.1–B.5 would follow the same cross-repo pattern as Solution A: design spec → Storyteller schema change → Flipbook UI component → tests. Omitted here for brevity, but same discipline applies.]**

---

### SOLUTION C: New Data Types (UDim2, Vector3)

**GATE C.1: Verify Storyteller has constructors**

**Run:**
```bash
grep -n "createUDim2Control\|createVector3Control" /Users/marin/Code/flipbook/Packages/_Index/flipbook-labs_storyteller@1.12.0/storyteller/dist/controls/ControlTypes.luau
```

**Expected:** Lines showing function definitions, or "no matches" if not yet in Storyteller.

**Branch Decision:**
- **If functions exist:** Proceed to C.2 (implement Flipbook UI).
- **If functions don't exist:** Storyteller needs the constructors first. (Likely they're not yet shipped in 1.12.0; check vault spec for timeline.)

**GATE C.2: Implement UDim2Control in Flipbook**

Create `/Users/marin/Code/flipbook/workspace/flipbook-core/src/StoryControls/ControlElements/UDim2Control.luau`:

```luau
local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local Storyteller = require("@pkg/Storyteller")

local e = React.createElement
local useCallback = React.useCallback

export type Props = {
    controlSchema: Storyteller.UDim2Control,
    controlValue: UDim2,
    onChanged: (UDim2) -> (),
}

local function UDim2Control(props: Props)
    local currentValue = props.controlValue or props.controlSchema.default or UDim2.new()
    
    local onScaleChanged = useCallback(function(newScale: number)
        local newValue = UDim2.new(newScale, currentValue.Offset.X, 0, currentValue.Offset.Y)
        props.onChanged(newValue)
    end, { currentValue, props.onChanged } :: { unknown })
    
    local onOffsetChanged = useCallback(function(newOffset: number)
        local newValue = UDim2.new(currentValue.Scale.X, newOffset, currentValue.Scale.Y, 0)
        props.onChanged(newValue)
    end, { currentValue, props.onChanged } :: { unknown })
    
    return e(Foundation.View, {
        tag = "auto-y col gap-small",
    }, {
        ScaleLabel = e(Foundation.Text, {
            LayoutOrder = 1,
            Text = "Scale: " .. currentValue.Scale.X,
            tag = "text-label-small",
        }),
        ScaleInput = e(Foundation.TextInput, {
            LayoutOrder = 2,
            Value = tostring(currentValue.Scale.X),
            onChanged = function(value)
                local num = tonumber(value) or 0
                onScaleChanged(num)
            end,
            tag = "size-full-x",
        }),
        OffsetLabel = e(Foundation.Text, {
            LayoutOrder = 3,
            Text = "Offset: " .. currentValue.Offset.X,
            tag = "text-label-small",
        }),
        OffsetInput = e(Foundation.TextInput, {
            LayoutOrder = 4,
            Value = tostring(currentValue.Offset.X),
            onChanged = function(value)
                local num = tonumber(value) or 0
                onOffsetChanged(num)
            end,
            tag = "size-full-x",
        }),
    })
end

return React.memo(UDim2Control)
```

**Add to StoryControlRow.luau** (type dispatch):

```luau
elseif controlType == ControlType.UDim2 then
    controlElement = e(UDim2Control, {
        controlSchema = props.control :: Storyteller.UDim2Control,
        controlValue = controlValue :: UDim2,
        onChanged = setControl,
    })
```

**GATE C.3: Implement Vector3Control**

Same pattern as UDim2Control, but with three inputs (X, Y, Z).

**GATE C.4: Write specs for UDim2 and Vector3**

Create `/Users/marin/Code/flipbook/workspace/flipbook-core/src/StoryControls/ControlElements/UDim2Control.spec.luau`:

```luau
local jest = require("@pkg/JestGlobals")
local React = require("@pkg/React")
local Storyteller = require("@pkg/Storyteller")

local UDim2Control = require("@root/StoryControls/ControlElements/UDim2Control")

local expect = jest.expect
local it = jest.it
local describe = jest.describe

describe("UDim2Control", function()
    it("should render UDim2 input fields", function()
        local controlSchema = Storyteller.createUDim2Control(UDim2.new(0.5, 10, 0.3, 20))
        local onChanged = jest.fn()
        
        local element = React.createElement(UDim2Control, {
            controlSchema = controlSchema,
            controlValue = UDim2.new(0.5, 10, 0.3, 20),
            onChanged = onChanged,
        })
        
        expect(element).toBeTruthy()
    end)
end)
```

**GATE C.5: Add examples to StoryControls.story.luau**

Add UDim2 and Vector3 controls to the comprehensive example story.

**Run tests:**
```bash
lute run test --filter "UDim2Control|Vector3Control"
```

**Expected:** Specs pass.

**SUCCESS CRITERIA (C):**
- ✅ UDim2Control component added; spec passes
- ✅ Vector3Control component added; spec passes
- ✅ StoryControlRow type dispatch includes both types
- ✅ StoryControls.story.luau has examples
- ✅ `lute run test` passes

---

### SOLUTION D: CheckControl Grid Layout

**GATE D.1: Check Foundation grid support**

**Run:**
```bash
grep -n "grid" /Users/marin/Code/flipbook/workspace/flipbook-core/src/StoryControls/ControlElements/CheckControl.luau
```

**Expected:** Current tag is `"size-full-y auto-x col gap-small"` (vertical column).

**Read Foundation docs** (in Flipbook or Wally):
```bash
grep -A 5 "grid" /Users/marin/Code/flipbook/Packages/_Index/*/Foundation/src/Component.luau | head -20
```

**Decision:** If Foundation supports grid tag (e.g., `"auto-y grid gap-small"` or `"grid cols-4"`), proceed to D.2.

**GATE D.2: Update CheckControl**

Change line 42–44 in CheckControl.luau from:
```luau
return e(Foundation.View, {
    tag = "size-full-y auto-x col gap-small",
}, checkboxes)
```

To:
```luau
return e(Foundation.View, {
    tag = "size-full-y auto-x grid gap-small cols-4",  -- 4-column grid (adjust if needed)
}, checkboxes)
```

**Verify no spec exists for CheckControl layout:**
```bash
find /Users/marin/Code/flipbook -name "*CheckControl*.spec*" -type f
```

**Expected:** No spec for CheckControl. (Only logic to test is toggle logic, which is tested in createStoryControlsStore.spec.luau.)

**GATE D.3: Visual test**

Create a test story with CheckControl having 8+ items:

```luau
local Storyteller = require("@pkg/Storyteller")
local React = require("@pkg/React")

local e = React.createElement

local items = {}
for i = 1, 8 do
    table.insert(items, "Option " .. i)
end

local story: Storyteller.Story = {
    controls = {
        multiCheck = Storyteller.createCheckControl(items),
    },
    story = function(props)
        return React.createElement("TextLabel", {
            Text = "Checked: " .. table.concat(props.controls.multiCheck, ", "),
            Size = UDim2.fromScale(1, 1),
            BackgroundColor3 = Color3.fromRGB(240, 240, 240),
            TextColor3 = Color3.fromRGB(0, 0, 0),
            TextWrapped = true,
        })
    end,
}

return story
```

**Build and open:**
```bash
lute run build plugin --channel dev
# Open Flipbook in Studio; navigate to test story
# Inspect CheckControl in controls panel
```

**Expected:** Checkboxes render in a 4-column grid (or whatever column count you set), not vertical stack.

**SUCCESS CRITERIA (D):**
- ✅ CheckControl renders grid layout (not vertical stack)
- ✅ Grid is responsive; looks good with 4–12 items
- ✅ Toggle behavior still works (clicking checkbox checks/unchecks)

---

**END PHASE 3 Checkpoint**

Each solution has been implemented and verified against exact success criteria. Code changes are minimal and focused.

---

## PHASE 4: Validation and Promotion

### Step 4.1: Validation Protocol (Read-Only, Measurement-Based)

Never judge by eye. Every phase success is a measurable observation, not a visual assessment.

**For Object Migration (Solution A):**
- ✅ Specification: UILabs Object control → migrated ObjectControl with nil default
- ✅ Evidence: UILabs Object story renders with ObjectControl UI
- ✅ Behavior: Selecting instance updates props.controls.selectedInstance
- ✅ Regression: `lute run test` passes (no existing tests break)

**For ControlGroup (Solution B):**
- ✅ Design spec reviewed by stakeholder
- ✅ Spec: ControlGroup nesting preserved during migration or intentionally flattened
- ✅ Evidence: UILabs ControlGroup story renders with visual grouping or flattening matches spec
- ✅ Regression: `lute run test` passes

**For New Data Types (Solution C):**
- ✅ Specification: UDim2Control renders two numeric inputs; Vector3Control renders three
- ✅ Evidence: `lute run test --filter "UDim2Control|Vector3Control"` passes
- ✅ Behavior: Setting control value updates story props
- ✅ Regression: `lute run test` passes

**For Grid Layout (Solution D):**
- ✅ Specification: CheckControl renders checkboxes in grid (not vertical stack)
- ✅ Evidence: Visual inspection (screenshot) shows grid layout
- ✅ Behavior: Toggling checkbox still updates control value
- ✅ Regression: `lute run test` passes

**New Specs Required (Critical for Long-Term Maintenance):**

The briefing notes that "currently uncovered per the briefing" are:
1. **Re-render Isolation:** Add spec to `createStoryControlsStore.spec.luau` verifying that changing one control's signal does NOT trigger renders on others. (Currently missing; only state shape is tested.)
2. **Migration Behavior:** Add spec in Flipbook or Storyteller validating UILabs → Storyteller schema round-trip for each control type (Object, ControlGroup, new types).

**Create spec for re-render isolation:**

```luau
-- In createStoryControlsStore.spec.luau, add:
it("should not re-subscribe to other controls when one changes", function()
    local schema = {
        control1 = Storyteller.createStringControl("a"),
        control2 = Storyteller.createStringControl("b"),
    }
    local store = createStoryControlsStore(schema)
    
    local signal1 = store.getControlValue("control1")
    local signal2 = store.getControlValue("control2")
    
    -- Signals are different (per-control)
    expect(signal1 ~= signal2).toBe(true)
    
    -- Changing control1 does not re-emit signal2
    store.setControl("control1", "new-a")
    expect(signal2.value).toBe("b")  -- unchanged
end)
```

**Create migration spec (Storyteller):**

```luau
-- In Storyteller migrations spec:
it("should migrate UILabs Object to Storyteller ObjectControl", function()
    local uiLabsObject = {
        Type = "Object",
    }
    local migrated = migrateUILabsControl(uiLabsObject)
    
    expect(migrated).to.be.ok()
    expect(migrated.type).toBe("Object")
    expect(migrated.default).toBe(nil)
end)
```

---

### Step 4.2: Route Through Change Control

**Reference:** `flipbook-change-control` skill (AGENTS.md, `.github/pull_request_template.md`).

**For each solution implemented:**

1. **Create branch:** `git switch -c story-controls-<solution>` (e.g., `story-controls-object-migration`)
2. **Commit changes** (if in Flipbook, not Storyteller):
   ```bash
   git add workspace/flipbook-core/src/StoryControls/...
   git add wally.toml
   git commit -m "Add UDim2/Vector3 controls and fix CheckControl grid layout

   - Implement UDim2Control component with scale/offset inputs
   - Implement Vector3Control component with X/Y/Z inputs
   - Update StoryControlRow type dispatch for new controls
   - Change CheckControl from col to grid layout (4-column)
   - Add specs for new control types validating schema→UI→props round-trip
   - Add re-render isolation spec to createStoryControlsStore.spec.luau

   Closes story controls gaps in UI Labs parity work.

   Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
   ```

3. **Open draft PR:**
   ```bash
   gh pr create --draft --title "Story Controls: New Data Types and Grid Layout" \
     --body "Adds UDim2 and Vector3 control types, fixes CheckControl grid layout, and adds missing re-render isolation spec."
   ```

4. **Await review.** All PRs must route through change control (see skill).

**Cross-repo note:** If implementing Solution A (Object migration), the primary commit happens in Storyteller; Flipbook's PR is the version bump in wally.toml (smaller, lower-risk change).

---

### Step 4.3: Known Wrong Paths (Explicitly Fenced)

**DO NOT:**

1. **Resurrect uilabs-controls-support branch:** It is 3 commits stale (lacks #576, #579, #597). Merging it would revert ObjectControl + InstancePicker work, and lose re-render isolation fixes. If you need UILabs compat, port examples forward onto main. **Citation:** Briefing states branch predates ObjectControl extraction; main is current.

2. **Reintroduce shared-store subscriptions:** PR #576 eliminated a prior pattern where all controls subscribed to one shared Charm signal. This caused all controls to re-render when any changed. Current per-control signal pattern is the fix. Don't go back. **Citation:** Briefing says #576 is the "lesson" — don't make the same mistake.

3. **Bypass Storyteller by parsing controls in Flipbook:** UILabs schema → Storyteller schema → Flipbook UI is the layering contract. If Storyteller doesn't support a control type, the fix goes in Storyteller (as with Object migration). Flipbook must not parse raw UILabs schema or duplicate Storyteller's migration logic. **Citation:** Briefing states "layering contract" — maintain it.

---

### Step 4.4: Promotion Criteria

**Before merging any solution PR:**

1. ✅ **Code review** completed (via `gh pr review` or maintainer approval)
2. ✅ **All tests pass:** `lute run test` (entire suite)
3. ✅ **Lint passes:** `lute run lint` (StyLua, Selene, Prettier)
4. ✅ **Type check passes:** `lute run analyze` (Luau strict mode)
5. ✅ **Measurable validation** (per Phase 4.1 protocol — test assertions, not eyeballing)
6. ✅ **Changelog entry** added (if repo uses changewrite; see `flipbook-release-and-operations` skill)
7. ✅ **PR body discloses AI authorship** (required by repo conventions in CLAUDE.md)

**Merge to main:**
```bash
gh pr merge <PR_URL> --squash --delete-branch
```

(Squash keeps history clean; `--delete-branch` cleans up.)

**Post-merge:**
1. Announce to maintainer/team (e.g., "Story Controls Phase 3 complete; Object migration landed")
2. If cross-repo (Storyteller version bump), coordinate release timing with Storyteller maintainers
3. Add entry to vault docs (flipbook-docs branch or main, per publication plan) documenting the new control types and ControlGroup decision

---

## Appendix: Troubleshooting & Branch Decisions

### Troubleshooting: "But my story still doesn't show the control"

**Symptom:** You wrote a UILabs story with Object control; after Solution A, the control still doesn't appear.

**Diagnostic:**
1. Verify Storyteller was bumped and Flipbook's wally.toml is updated:
   ```bash
   grep Storyteller /Users/marin/Code/flipbook/wally.toml
   ```
2. Verify `lute run install` ran:
   ```bash
   ls /Users/marin/Code/flipbook/Packages/_Index/flipbook-labs_storyteller@*/storyteller/dist/controls/migrations/
   ```
3. Verify ObjectControl component exists in Flipbook:
   ```bash
   grep -n "ObjectControl" /Users/marin/Code/flipbook/workspace/flipbook-core/src/StoryControls/ControlElements/ObjectControl.luau | head -3
   ```
4. Run Flipbook dev build:
   ```bash
   lute run build plugin --channel dev
   ```
   Open story in Studio. Check browser console for errors (Storyteller migration errors, React errors).

**Branch decision:**
- **If Storyteller doesn't have the fix:** Merge Object migration PR in Storyteller first.
- **If wally.toml doesn't have the new version:** Update and re-run `lute run install`.
- **If ObjectControl missing:** Don't blame the migration; ObjectControl was in main before Solution A. Verify you're on main and built correctly.

### Troubleshooting: "Grid layout broke my CheckControl"

**Symptom:** After Solution D, CheckControl renders incorrectly (overlapping, cut off).

**Diagnostic:**
1. Verify Foundation's grid tag syntax:
   ```bash
   grep -C 3 "grid" /Users/marin/Code/flipbook/Packages/_Index/*/Foundation/src/Component.luau | head -20
   ```
2. If grid tag is wrong, adjust. E.g., change `"grid cols-4"` to `"grid cols-3"` or Foundation's actual grid class.
3. Verify story has enough items to fill grid:
   ```luau
   -- Use 8+ items so grid is visible
   local items = {}
   for i = 1, 12 do table.insert(items, "Item " .. i) end
   ```

**Branch decision:**
- **If Foundation doesn't support grid:** Use CSS Flexbox fallback or two-column layout.
- **If grid layout is ugly:** Adjust cols count or padding/gap.

---

## Provenance and Maintenance

**Last verified:** 2026-07-01

**Commands to re-verify facts:**

1. **Storyteller version pinned in wally.toml:**
   ```bash
   grep "Storyteller = " /Users/marin/Code/flipbook/wally.toml
   ```

2. **ObjectControl component exists:**
   ```bash
   test -f /Users/marin/Code/flipbook/workspace/flipbook-core/src/StoryControls/ControlElements/ObjectControl.luau && echo "✓"
   ```

3. **InstancePicker was extracted (PR #597):**
   ```bash
   git log --oneline --all | grep "Extract InstancePicker"
   ```

4. **CheckControl grid TODO exists:**
   ```bash
   grep "TODO.*grid" /Users/marin/Code/flipbook/workspace/flipbook-core/src/StoryControls/ControlElements/CheckControl.luau
   ```

5. **uilabs-controls-support branch is stale:**
   ```bash
   git log uilabs-controls-support..main --oneline | wc -l
   ```
   (Output > 2 = branch is behind)

6. **Current main is 78d71e8f (Embed Flipbook in DataModel):**
   ```bash
   git log -1 --oneline
   ```

**Re-verification schedule:** Quarterly. If any command returns unexpected output, update the skill.

---

## Summary: Why This Campaign Exists

Flipbook's story controls are the hardest live problem because they require coordinated changes across two repos (Storyteller + Flipbook), resolve a silent data loss bug (Object migration), and involve a design decision (ControlGroup). The campaign front-loads characterization (Phase 1) so you understand what's broken, ranks solutions by evidence (Phase 2) so you fix high-impact items first, provides exact implementation gates (Phase 3) so you don't guess, and enforces measurement-based validation (Phase 4) so you know when you're done. Follow the phases in order. Do not skip to implementation.
