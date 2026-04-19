---
aliases: [Flipbook Hack Week TODO]
linter-yaml-title-alias: Flipbook Hack Week TODO
notion-id: 27695b79-12f8-81df-9eaa-d46c32341379
---
# Flipbook Hack Week TODO

## Questions

* What are the differences between loadstring and loadmodule?
* Is there any way to know which files are synced in via an rbxp and to add new files into a project?
    * Yes. FileSyncService gets populated with InternalSyncItem instances that point back to paths the rbxp is syncing. Anything saved to the target will be synced to the FS

## Video Outline

* Introduction
    * I’m Marin Minnerly, software eng on Creator Content Music
    * Context on Developer Storybook (who uses it and for what)
    * Context on Flipbook (why I created it, why it’s still relevant years later, why I’m carving out an internal pathway
* Goals
    * Maximize compatibility with existing Developer Storybook stories
    * Make Flipbook as accessible as Developer Storybook to internal engineers
    * 10 engineers switch over to Flipbook full-time
* How I accomplished it
    * Solving permission issues
        * FlipbookWrapper built-in plugin
        * Downloads Flipbook from admin account or loads custom build from PluginDebugService
    * Story format deviations
        * Storyteller
* Features
    * Live reloading
    * Support for most of Developer Storybook’s story format
    * Create Storybook
        * Show that it syncs right to disk for easy committing
    * Support for Universal App stories
    * Support for stories in other projects (show off Scene Understanding?)
    * Pin favorite stories
    * See which stories are unavailable and why
    * Remember last opened story between sessions
    * Switch theme on the fly
    * Story editing lifecycle
        * Mount
        * Change controls
        * Explore
        * Preview in viewport
* Future plans
    * Merge everything back to the community
    * Pin favorite stories
    * Address performance issues
    * Support for substories
* Enroll today
    * ZFlipbookWrapper

## TODO

- [ ] **FEAT: Highlight code blocks**
 https://github.com/boatbomber/Highlighter
- [ ] **BUG: Some storybooks do not seem to have their storyRoots traversed
**See storybooks like InviteLinkExpiredModal, MessageToast, etc. where the dropdown arrow does not appear.
- [ ] **FEAT: Create Storybook should pop open a Modal
**For Roblox Internal, select the location of an already synced instance. For community, suggest a common DataModel service. Maybe just use the user’s Selection?
- [ ] **FEAT: Separate Flipbook stack trace from user-side errors**
- [ ] **BUG: If a story errors it gets stuck**
    1. Trigger a story error
    2. Observe the full stack trace
    3. Close the story and reopen it
    4. Observe the stacktrace is smaller, ending with "RESULT: nil"
- [ ] **BUG: Initial storybook discovery freezes Flipbook
**Upon opening Flipbook Internal, the app freezes for a moment while storybooks load in
- [x] **FEAT: Rewrite ModuleLoader to improve stacktraces, support loadmodule, and visualize the require graph
**Take inspiration from Jest’s module loading and the plugin ModuleLoader
- [x] **FEAT: FlipbookWrapper works with full development workflow
**Make change to plugin → FlipbookWrapper reloads plugin
- [x] **FEAT: Use a highlight color when hovering over one of the draggable edges**
- [x] **BUG: Any story that uses UIBlox’s Style breaks**
- [x] **BUG: Resizing sidebar width resets the tree view**
- [x] **BUG: Studio crashes from control changes
**Open Songbird’s CollapsibleFrame story, change the `isCollapsed` control, observe Studio crash.
Update: This may be because of a math error in engine. Keep an eye out of any other stories crash to see if that’s the case

> [!note]+ Stacktrace
>
> ```plain text
> 2024-12-16T22:00:28.777Z,614.777893,faff4240,6 [LOGCHANNELS + 1] /Users/dminnerly/code/game-engine/Client/Math/include/Math/Math.h(374) ASSERTION FAILED: low <= hi
> /Users/dminnerly/code/game-engine/Client/Math/include/Math/Math.h(374) ASSERTION FAILED: low <= hi
> 2024-12-16T22:00:28.782Z,614.782104,faff4240,6 [LOGCHANNELS + 1] CALL STACK
> CALL STACK:
> 2024-12-16T22:00:28.782Z,614.782104,faff4240,6 [LOGCHANNELS + 1]   0: 0x71223b0 RbxAssertFunction(char const*, char const*, int, char const*)
>   0: 0x71223b0 RbxAssertFunction(char const*, char const*, int, char const*)
> 2024-12-16T22:00:28.782Z,614.782104,faff4240,6 [LOGCHANNELS + 1]   1: 0x4e79618 RBX::UISizeConstraint::getConstrainedSize(RBX::Vector2 const&) const
>   1: 0x4e79618 RBX::UISizeConstraint::getConstrainedSize(RBX::Vector2 const&) const
> 2024-12-16T22:00:28.782Z,614.782166,faff4240,6 [LOGCHANNELS + 1]   2: 0x4db89bc RBX::GuiObject::getUIConstrainedSize(RBX::Vector2 const&, RBX::Vector2 const&) const
>   2: 0x4db89bc RBX::GuiObject::getUIConstrainedSize(RBX::Vector2 const&, RBX::Vector2 const&) const
> 2024-12-16T22:00:28.782Z,614.782166,faff4240,6 [LOGCHANNELS + 1]   3: 0x4cd3ef8 RBX::LayoutNode::calculateMaxSize(RBX::LayoutNode&, RBX::Vector2) const
>   3: 0x4cd3ef8 RBX::LayoutNode::calculateMaxSize(RBX::LayoutNode&, RBX::Vector2) const
> 2024-12-16T22:00:28.782Z,614.782166,faff4240,6 [LOGCHANNELS + 1]   4: 0x4ccc788 RBX::LayoutNode::layoutMinSize(RBX::Vector2, std::__1::vector<RBX::LayoutChangeEvent, std::__1::allocator<RBX::LayoutChangeEvent>>&, bool)
>   4: 0x4ccc788 RBX::LayoutNode::layoutMinSize(RBX::Vector2, std::__1::vector<RBX::LayoutChangeEvent, std::__1::allocator<RBX::LayoutChangeEvent>>&, bool)
> 2024-12-16T22:00:28.782Z,614.782166,faff4240,6 [LOGCHANNELS + 1]   5: 0x4ccd314 RBX::LayoutNode::layoutMinSize(RBX::Vector2, std::__1::vector<RBX::LayoutChangeEvent, std::__1::allocator<RBX::LayoutChangeEvent>>&, bool)
>   5: 0x4ccd314 RBX::LayoutNode::layoutMinSize(RBX::Vector2, std::__1::vector<RBX::LayoutChangeEvent, std::__1::allocator<RBX::LayoutChangeEvent>>&, bool)
> 2024-12-16T22:00:28.782Z,614.782166,faff4240,6 [LOGCHANNELS + 1]   6: 0x4ccd314 RBX::LayoutNode::layoutMinSize(RBX::Vector2, std::__1::vector<RBX::LayoutChangeEvent, std::__1::allocator<RBX::LayoutChangeEvent>>&, bool)
>   6: 0x4ccd314 RBX::LayoutNode::layoutMinSize(RBX::Vector2, std::__1::vector<RBX::LayoutChangeEvent, std::__1::allocator<RBX::LayoutChangeEvent>>&, bool)
> 2024-12-16T22:00:28.782Z,614.782410,faff4240,6 [LOGCHANNELS + 1]   7: 0x4ccd314 RBX::LayoutNode::layoutMinSize(RBX::Vector2, std::__1::vector<RBX::LayoutChangeEvent, std::__1::allocator<RBX::LayoutChangeEvent>>&, bool)
>   7: 0x4ccd314 RBX::LayoutNode::layoutMinSize(RBX::Vector2, std::__1::vector<RBX::LayoutChangeEvent, std::__1::allocator<RBX::LayoutChangeEvent>>&, bool)
> 2024-12-16T22:00:28.782Z,614.782471,faff4240,6 [LOGCHANNELS + 1]   8: 0x4ccd314 RBX::LayoutNode::layoutMinSize(RBX::Vector2, std::__1::vector<RBX::LayoutChangeEvent, std::__1::allocator<RBX::LayoutChangeEvent>>&, bool)
>   8: 0x4ccd314 RBX::LayoutNode::layoutMinSize(RBX::Vector2, std::__1::vector<RBX::LayoutChangeEvent, std::__1::allocator<RBX::LayoutChangeEvent>>&, bool)
> 2024-12-16T22:00:28.782Z,614.782471,faff4240,6 [LOGCHANNELS + 1]   9: 0x4ccd314 RBX::LayoutNode::layoutMinSize(RBX::Vector2, std::__1::vector<RBX::LayoutChangeEvent, std::__1::allocator<RBX::LayoutChangeEvent>>&, bool)
>   9: 0x4ccd314 RBX::LayoutNode::layoutMinSize(RBX::Vector2, std::__1::vector<RBX::LayoutChangeEvent, std::__1::allocator<RBX::LayoutChangeEvent>>&, bool)
> 2024-12-16T22:00:28.782Z,614.782532,faff4240,6 [LOGCHANNELS + 1]  10: 0x4ccd314 RBX::LayoutNode::layoutMinSize(RBX::Vector2, std::__1::vector<RBX::LayoutChangeEvent, std::__1::allocator<RBX::LayoutChangeEvent>>&, bool)
>  10: 0x4ccd314 RBX::LayoutNode::layoutMinSize(RBX::Vector2, std::__1::vector<RBX::LayoutChangeEvent, std::__1::allocator<RBX::LayoutChangeEvent>>&, bool)
> 2024-12-16T22:00:28.782Z,614.782532,faff4240,6 [LOGCHANNELS + 1]  11: 0x4ccd314 RBX::LayoutNode::layoutMinSize(RBX::Vector2, std::__1::vector<RBX::LayoutChangeEvent, std::__1::allocator<RBX::LayoutChangeEvent>>&, bool)
>  11: 0x4ccd314 RBX::LayoutNode::layoutMinSize(RBX::Vector2, std::__1::vector<RBX::LayoutChangeEvent, std::__1::allocator<RBX::LayoutChangeEvent>>&, bool)
> 2024-12-16T22:00:28.782Z,614.782532,faff4240,6 [LOGCHANNELS + 1]  12: 0x4ccd314 RBX::LayoutNode::layoutMinSize(RBX::Vector2, std::__1::vector<RBX::LayoutChangeEvent, std::__1::allocator<RBX::LayoutChangeEvent>>&, bool)
>  12: 0x4ccd314 RBX::LayoutNode::layoutMinSize(RBX::Vector2, std::__1::vector<RBX::LayoutChangeEvent, std::__1::allocator<RBX::LayoutChangeEvent>>&, bool)
> 2024-12-16T22:00:28.782Z,614.782593,faff4240,6 [LOGCHANNELS + 1]  13: 0x4ccd314 RBX::LayoutNode::layoutMinSize(RBX::Vector2, std::__1::vector<RBX::LayoutChangeEvent, std::__1::allocator<RBX::LayoutChangeEvent>>&, bool)
>  13: 0x4ccd314 RBX::LayoutNode::layoutMinSize(RBX::Vector2, std::__1::vector<RBX::LayoutChangeEvent, std::__1::allocator<RBX::LayoutChangeEvent>>&, bool)
> 2024-12-16T22:00:28.782Z,614.782593,faff4240,6 [LOGCHANNELS + 1]  14: 0x4ccd314 RBX::LayoutNode::layoutMinSize(RBX::Vector2, std::__1::vector<RBX::LayoutChangeEvent, std::__1::allocator<RBX::LayoutChangeEvent>>&, bool)
>  14: 0x4ccd314 RBX::LayoutNode::layoutMinSize(RBX::Vector2, std::__1::vector<RBX::LayoutChangeEvent, std::__1::allocator<RBX::LayoutChangeEvent>>&, bool)
> 2024-12-16T22:00:28.782Z,614.782593,faff4240,6 [LOGCHANNELS + 1]  15: 0x4ccd314 RBX::LayoutNode::layoutMinSize(RBX::Vector2, std::__1::vector<RBX::LayoutChangeEvent, std::__1::allocator<RBX::LayoutChangeEvent>>&, bool)
>  15: 0x4ccd314 RBX::LayoutNode::layoutMinSize(RBX::Vector2, std::__1::vector<RBX::LayoutChangeEvent, std::__1::allocator<RBX::LayoutChangeEvent>>&, bool)
> 2024-12-16T22:00:28.782Z,614.782593,faff4240,6 [LOGCHANNELS + 1]  16: 0x4ccd314 RBX::LayoutNode::layoutMinSize(RBX::Vector2, std::__1::vector<RBX::LayoutChangeEvent, std::__1::allocator<RBX::LayoutChangeEvent>>&, bool)
>  16: 0x4ccd314 RBX::LayoutNode::layoutMinSize(RBX::Vector2, std::__1::vector<RBX::LayoutChangeEvent, std::__1::allocator<RBX::LayoutChangeEvent>>&, bool)
> 2024-12-16T22:00:28.782Z,614.782593,faff4240,6 [LOGCHANNELS + 1]  17: 0x4ccd314 RBX::LayoutNode::layoutMinSize(RBX::Vector2, std::__1::vector<RBX::LayoutChangeEvent, std::__1::allocator<RBX::LayoutChangeEvent>>&, bool)
>  17: 0x4ccd314 RBX::LayoutNode::layoutMinSize(RBX::Vector2, std::__1::vector<RBX::LayoutChangeEvent, std::__1::allocator<RBX::LayoutChangeEvent>>&, bool)
> 2024-12-16T22:00:28.782Z,614.782654,faff4240,6 [LOGCHANNELS + 1]  18: 0x4ccd314 RBX::LayoutNode::layoutMinSize(RBX::Vector2, std::__1::vector<RBX::LayoutChangeEvent, std::__1::allocator<RBX::LayoutChangeEvent>>&, bool)
>  18: 0x4ccd314 RBX::LayoutNode::layoutMinSize(RBX::Vector2, std::__1::vector<RBX::LayoutChangeEvent, std::__1::allocator<RBX::LayoutChangeEvent>>&, bool)
> 2024-12-16T22:00:28.782Z,614.782654,faff4240,6 [LOGCHANNELS + 1]  19: 0x4ccb998 RBX::LayoutNode::layout(char const*, RBX::LayoutNode::RelayoutMode, bool)
>  19: 0x4ccb998 RBX::LayoutNode::layout(char const*, RBX::LayoutNode::RelayoutMode, bool)
> 2024-12-16T22:00:28.782Z,614.782654,faff4240,6 [LOGCHANNELS + 1]  20: 0x4d97900 RBX::GuiLayerCollector::stepLayouts(RBX::Stepped const&)
>  20: 0x4d97900 RBX::GuiLayerCollector::stepLayouts(RBX::Stepped const&)
> 2024-12-16T22:00:28.782Z,614.782654,faff4240,6 [LOGCHANNELS + 1]  21: 0x4dd3230 RBX::GuiService::updateAllLayouts(RBX::Stepped const&)
>  21: 0x4dd3230 RBX::GuiService::updateAllLayouts(RBX::Stepped const&)
> 2024-12-16T22:00:28.782Z,614.782654,faff4240,6 [LOGCHANNELS + 1]  22: 0x4dd3d8c RBX::GuiService::stepLayoutsAndTweens(RBX::Stepped const&)
>  22: 0x4dd3d8c RBX::GuiService::stepLayoutsAndTweens(RBX::Stepped const&)
> 2024-12-16T22:00:28.782Z,614.782654,faff4240,6 [LOGCHANNELS + 1]  23: 0x47628d0 RBX::RunService::renderStepped(double)
>  23: 0x47628d0 RBX::RunService::renderStepped(double)
> 2024-12-16T22:00:28.782Z,614.782654,faff4240,6 [LOGCHANNELS + 1]  24: 0x43fbde4 RBX::DataModel::renderStep(float)
>  24: 0x43fbde4 RBX::DataModel::renderStep(float)
> 2024-12-16T22:00:28.782Z,614.782654,faff4240,6 [LOGCHANNELS + 1]  25: 0xa419c8 RBX::Studio::DataModelRenderer::render()
>  25: 0xa419c8 RBX::Studio::DataModelRenderer::render()
> 2024-12-16T22:00:28.782Z,614.782654,faff4240,6 [LOGCHANNELS + 1]  26: 0xa57c88 RBX::Studio::RenderViewUpdateReceiver::event(QEvent*)
>  26: 0xa57c88 RBX::Studio::RenderViewUpdateReceiver::event(QEvent*)
> 2024-12-16T22:00:28.782Z,614.782654,faff4240,6 [LOGCHANNELS + 1]  27: 0x105e0 QApplicationPrivate::notify_helper(QObject*, QEvent*)
>  27: 0x105e0 QApplicationPrivate::notify_helper(QObject*, QEvent*)
> 2024-12-16T22:00:28.782Z,614.782715,faff4240,6 [LOGCHANNELS + 1]  28: 0x11978 QApplication::notify(QObject*, QEvent*)
>  28: 0x11978 QApplication::notify(QObject*, QEvent*)
> 2024-12-16T22:00:28.782Z,614.782715,faff4240,6 [LOGCHANNELS + 1]  29: 0x1ec26e0 RobloxApplication::notify(QObject*, QEvent*)
>  29: 0x1ec26e0 RobloxApplication::notify(QObject*, QEvent*)
> 2024-12-16T22:00:28.782Z,614.782715,faff4240,6 [LOGCHANNELS + 1]  30: 0x1d7fe4 QCoreApplication::notifyInternal2(QObject*, QEvent*)
>  30: 0x1d7fe4 QCoreApplication::notifyInternal2(QObject*, QEvent*)
> 2024-12-16T22:00:28.782Z,614.782715,faff4240,6 [LOGCHANNELS + 1]  31: 0x1d92a4 QCoreApplicationPrivate::sendPostedEvents(QObject*, int, QThreadData*)
>  31: 0x1d92a4 QCoreApplicationPrivate::sendPostedEvents(QObject*, int, QThreadData*)
> 2024-12-16T22:00:28.782Z,614.782715,faff4240,6,Info [FLog::RBXAssert] Assert: file: Math.h:374, expression: low <= hi, function: clamp, hash: 3521554823357504349, Flag::areFlagsLoaded(): true
> 2024-12-16T22:00:28.782Z,614.782776,faff4240,6 [LOGCHANNELS + 1] RBXCRASH: SoftAssert (Assert: file: Math.h:374, expression: low <= hi, function: clamp, hash: 3521554823357504349, Flag::areFlagsLoaded(): true)
> RBXCRASH: SoftAssert (Assert: file: Math.h:374, expression: low <= hi, function: clamp, hash: 3521554823357504349, Flag::areFlagsLoaded(): true)
> ```

## Extra TODO from home Computer

Had these sitting in my vscode. Pasting them here so I can look at them later

```markdown

Rojo + Darklua workflow seems broken

1. Build source to to a distinct dir
2. Sync with Rojo
3. Make changes, rebuild
4. Observe that Flipbook doesn't seem to get the memo that there was a file change

preview in viewport should show a message that the story preview is in the viewport

---

Seems like Flipbook needs to handle a case where the entire Storybook + Stories are destroyed and resynced
    The entire hierarchy winds up being the same, but the instances themselves I think are different

---

Pixel grid
Measure tool
Hover UI elements to select them
Select one element, Cmd/Ctrl to show px gap between other UI elementsgit 
```
