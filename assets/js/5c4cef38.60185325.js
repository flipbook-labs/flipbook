"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[610],{3905:(t,e,n)=>{n.d(e,{Zo:()=>c,kt:()=>k});var a=n(7294);function r(t,e,n){return e in t?Object.defineProperty(t,e,{value:n,enumerable:!0,configurable:!0,writable:!0}):t[e]=n,t}function o(t,e){var n=Object.keys(t);if(Object.getOwnPropertySymbols){var a=Object.getOwnPropertySymbols(t);e&&(a=a.filter((function(e){return Object.getOwnPropertyDescriptor(t,e).enumerable}))),n.push.apply(n,a)}return n}function l(t){for(var e=1;e<arguments.length;e++){var n=null!=arguments[e]?arguments[e]:{};e%2?o(Object(n),!0).forEach((function(e){r(t,e,n[e])})):Object.getOwnPropertyDescriptors?Object.defineProperties(t,Object.getOwnPropertyDescriptors(n)):o(Object(n)).forEach((function(e){Object.defineProperty(t,e,Object.getOwnPropertyDescriptor(n,e))}))}return t}function i(t,e){if(null==t)return{};var n,a,r=function(t,e){if(null==t)return{};var n,a,r={},o=Object.keys(t);for(a=0;a<o.length;a++)n=o[a],e.indexOf(n)>=0||(r[n]=t[n]);return r}(t,e);if(Object.getOwnPropertySymbols){var o=Object.getOwnPropertySymbols(t);for(a=0;a<o.length;a++)n=o[a],e.indexOf(n)>=0||Object.prototype.propertyIsEnumerable.call(t,n)&&(r[n]=t[n])}return r}var p=a.createContext({}),s=function(t){var e=a.useContext(p),n=e;return t&&(n="function"==typeof t?t(e):l(l({},e),t)),n},c=function(t){var e=s(t.components);return a.createElement(p.Provider,{value:e},t.children)},m="mdxType",u={inlineCode:"code",wrapper:function(t){var e=t.children;return a.createElement(a.Fragment,{},e)}},d=a.forwardRef((function(t,e){var n=t.components,r=t.mdxType,o=t.originalType,p=t.parentName,c=i(t,["components","mdxType","originalType","parentName"]),m=s(n),d=r,k=m["".concat(p,".").concat(d)]||m[d]||u[d]||o;return n?a.createElement(k,l(l({ref:e},c),{},{components:n})):a.createElement(k,l({ref:e},c))}));function k(t,e){var n=arguments,r=e&&e.mdxType;if("string"==typeof t||r){var o=n.length,l=new Array(o);l[0]=d;var i={};for(var p in e)hasOwnProperty.call(e,p)&&(i[p]=e[p]);i.originalType=t,i[m]="string"==typeof t?t:r,l[1]=i;for(var s=2;s<o;s++)l[s]=n[s];return a.createElement.apply(null,l)}return a.createElement.apply(null,n)}d.displayName="MDXCreateElement"},9175:(t,e,n)=>{n.r(e),n.d(e,{assets:()=>p,contentTitle:()=>l,default:()=>u,frontMatter:()=>o,metadata:()=>i,toc:()=>s});var a=n(7462),r=(n(7294),n(3905));const o={sidebar_position:3},l="Story Format",i={unversionedId:"story-format",id:"story-format",title:"Story Format",description:"Stories can be written in several different formats to accomodate different workflows. This document outlines those formats with examples of how to use them.",source:"@site/docs/story-format.md",sourceDirName:".",slug:"/story-format",permalink:"/flipbook/docs/story-format",draft:!1,editUrl:"https://github.com/vocksel/flipbook/edit/master/docs/story-format.md",tags:[],version:"current",sidebarPosition:3,frontMatter:{sidebar_position:3},sidebar:"defaultSidebar",previous:{title:"Writing Stories",permalink:"/flipbook/docs/writing-stories"},next:{title:"Migrating from Hoarcekat",permalink:"/flipbook/docs/migrating"}},p={},s=[{value:"Storybook",id:"storybook",level:2},{value:"Roact Story",id:"roact-story",level:2},{value:"React Story",id:"react-story",level:2},{value:"Functional Story",id:"functional-story",level:2},{value:"Hoarcekat Story",id:"hoarcekat-story",level:2}],c={toc:s},m="wrapper";function u(t){let{components:e,...n}=t;return(0,r.kt)(m,(0,a.Z)({},c,n,{components:e,mdxType:"MDXLayout"}),(0,r.kt)("h1",{id:"story-format"},"Story Format"),(0,r.kt)("p",null,"Stories can be written in several different formats to accomodate different workflows. This document outlines those formats with examples of how to use them."),(0,r.kt)("h2",{id:"storybook"},"Storybook"),(0,r.kt)("p",null,"Storybooks are your entypoint to flipbook and you'll need at least one to start using it."),(0,r.kt)("p",null,"The only required prop is the ",(0,r.kt)("inlineCode",{parentName:"p"},"storyRoots")," array, which tells flipbook which Instances to search the descendants of for ",(0,r.kt)("inlineCode",{parentName:"p"},".story")," files"),(0,r.kt)("table",null,(0,r.kt)("thead",{parentName:"table"},(0,r.kt)("tr",{parentName:"thead"},(0,r.kt)("th",{parentName:"tr",align:null},"Name"),(0,r.kt)("th",{parentName:"tr",align:null},"Type"),(0,r.kt)("th",{parentName:"tr",align:null},"Notes"))),(0,r.kt)("tbody",{parentName:"table"},(0,r.kt)("tr",{parentName:"tbody"},(0,r.kt)("td",{parentName:"tr",align:null},(0,r.kt)("inlineCode",{parentName:"td"},"storyRoots")),(0,r.kt)("td",{parentName:"tr",align:null},(0,r.kt)("inlineCode",{parentName:"td"},"{ Instance }")),(0,r.kt)("td",{parentName:"tr",align:null},"An array of instances to search the descendants of for ",(0,r.kt)("inlineCode",{parentName:"td"},".story")," files.")),(0,r.kt)("tr",{parentName:"tbody"},(0,r.kt)("td",{parentName:"tr",align:null},(0,r.kt)("inlineCode",{parentName:"td"},"name")),(0,r.kt)("td",{parentName:"tr",align:null},(0,r.kt)("inlineCode",{parentName:"td"},"string?")),(0,r.kt)("td",{parentName:"tr",align:null},"The name to use for the storybook. This defaults to ",(0,r.kt)("inlineCode",{parentName:"td"},"script.Name")," with ",(0,r.kt)("inlineCode",{parentName:"td"},".storybook")," stripped off.")),(0,r.kt)("tr",{parentName:"tbody"},(0,r.kt)("td",{parentName:"tr",align:null},(0,r.kt)("inlineCode",{parentName:"td"},"roact")),(0,r.kt)("td",{parentName:"tr",align:null},(0,r.kt)("inlineCode",{parentName:"td"},"Roact?")),(0,r.kt)("td",{parentName:"tr",align:null},"The version of Roact to use across all stories.")),(0,r.kt)("tr",{parentName:"tbody"},(0,r.kt)("td",{parentName:"tr",align:null},(0,r.kt)("inlineCode",{parentName:"td"},"react")),(0,r.kt)("td",{parentName:"tr",align:null},(0,r.kt)("inlineCode",{parentName:"td"},"React?")),(0,r.kt)("td",{parentName:"tr",align:null},"The version of React to use across all stories.")),(0,r.kt)("tr",{parentName:"tbody"},(0,r.kt)("td",{parentName:"tr",align:null},(0,r.kt)("inlineCode",{parentName:"td"},"reactRoblox")),(0,r.kt)("td",{parentName:"tr",align:null},(0,r.kt)("inlineCode",{parentName:"td"},"ReactRoblox?")),(0,r.kt)("td",{parentName:"tr",align:null},"The version of ReactRoblox to use when mounting React components.")))),(0,r.kt)("p",null,"Example:"),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre",className:"language-lua"},'-- example/Example.storybook.lua\nreturn {\n    name = "Example Storybook",\n    storyRoots = {\n        script.Parent,\n    },\n}\n')),(0,r.kt)("h2",{id:"roact-story"},"Roact Story"),(0,r.kt)("p",null,"Support for Roblox's ",(0,r.kt)("a",{parentName:"p",href:"https://github.com/Roblox/roact"},"Roact")," library is built in to flipbook, allowing you to supply your copy of Roact and return Roact elements to create stories."),(0,r.kt)("table",null,(0,r.kt)("thead",{parentName:"table"},(0,r.kt)("tr",{parentName:"thead"},(0,r.kt)("th",{parentName:"tr",align:null},"Name"),(0,r.kt)("th",{parentName:"tr",align:null},"Type"),(0,r.kt)("th",{parentName:"tr",align:null},"Description"))),(0,r.kt)("tbody",{parentName:"table"},(0,r.kt)("tr",{parentName:"tbody"},(0,r.kt)("td",{parentName:"tr",align:null},"story"),(0,r.kt)("td",{parentName:"tr",align:null},(0,r.kt)("inlineCode",{parentName:"td"},"RoactElement    \\| (props: StoryPropss) -> RoactElement")),(0,r.kt)("td",{parentName:"tr",align:null},"Your story can either be a Roact element or a function that accepts props and returns a Roact element. The latter format is needed to support the use of controls. See below for an example")),(0,r.kt)("tr",{parentName:"tbody"},(0,r.kt)("td",{parentName:"tr",align:null},"roact"),(0,r.kt)("td",{parentName:"tr",align:null},(0,r.kt)("inlineCode",{parentName:"td"},"Roact")),(0,r.kt)("td",{parentName:"tr",align:null},"This must be set to your copy of Roact. Since Roact uses special symbols for things like children, flipbook needs to mount the story with the same copy of Roact that you used to create your elements.")),(0,r.kt)("tr",{parentName:"tbody"},(0,r.kt)("td",{parentName:"tr",align:null},"name"),(0,r.kt)("td",{parentName:"tr",align:null},(0,r.kt)("inlineCode",{parentName:"td"},"string?")),(0,r.kt)("td",{parentName:"tr",align:null},"Optional name for the story. Defaults to the file name.")),(0,r.kt)("tr",{parentName:"tbody"},(0,r.kt)("td",{parentName:"tr",align:null},"summary"),(0,r.kt)("td",{parentName:"tr",align:null},(0,r.kt)("inlineCode",{parentName:"td"},"string?")),(0,r.kt)("td",{parentName:"tr",align:null},"Optional description of the story that will appear as part of the information at the top of the preview.")),(0,r.kt)("tr",{parentName:"tbody"},(0,r.kt)("td",{parentName:"tr",align:null},"controls"),(0,r.kt)("td",{parentName:"tr",align:null},(0,r.kt)("inlineCode",{parentName:"td"},"StoryControls?")),(0,r.kt)("td",{parentName:"tr",align:null},"Optional controls to see how your story behaves with various props.")))),(0,r.kt)("p",null,"Example:"),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre",className:"language-lua"},'-- example/Button.story.lua\nlocal Example = script:FindFirstAncestor("Example")\n\nlocal Roact = require(Example.Parent.Packages.Roact)\nlocal Button = require(script.Parent.Button)\n\nreturn {\n    summary = "A generic button component that can be used anywhere",\n    roact = Roact,\n    story = Roact.createElement(Button, {\n        text = "Click me",\n        onActivated = function()\n            print("click")\n        end,\n    }),\n}\n')),(0,r.kt)("p",null,"Example with controls:"),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre",className:"language-lua"},'-- example/ButtonWithControls.story.lua\nlocal Example = script:FindFirstAncestor("Example")\n\nlocal Roact = require(Example.Parent.Packages.Roact)\nlocal ButtonWithControls = require(script.Parent.ButtonWithControls)\n\nlocal controls = {\n    isDisabled = false,\n}\n\ntype Props = {\n    controls: typeof(controls),\n}\n\nreturn {\n    summary = "A generic button component that can be used anywhere",\n    controls = controls,\n    roact = Roact,\n    story = function(props: Props)\n        return Roact.createElement(ButtonWithControls, {\n            text = "Click me",\n            isDisabled = props.controls.isDisabled,\n            onActivated = function()\n                print("click")\n            end,\n        })\n    end,\n}\n')),(0,r.kt)("h2",{id:"react-story"},"React Story"),(0,r.kt)("p",null,"Roblox's unreleased React 17 port is natively supported by flipbook, allowing you to use the React and ReactRoblox packages for mounting your components."),(0,r.kt)("p",null,"You can find React and ReactRoblox as part of the ",(0,r.kt)("a",{parentName:"p",href:"https://github.com/grilme99/CorePackages"},"CorePackages")," repo on GitHub."),(0,r.kt)("table",null,(0,r.kt)("thead",{parentName:"table"},(0,r.kt)("tr",{parentName:"thead"},(0,r.kt)("th",{parentName:"tr",align:null},"Name"),(0,r.kt)("th",{parentName:"tr",align:null},"Type"),(0,r.kt)("th",{parentName:"tr",align:null},"Description"))),(0,r.kt)("tbody",{parentName:"table"},(0,r.kt)("tr",{parentName:"tbody"},(0,r.kt)("td",{parentName:"tr",align:null},"story"),(0,r.kt)("td",{parentName:"tr",align:null},(0,r.kt)("inlineCode",{parentName:"td"},"ReactElement    \\| (props: StoryPropss) -> ReactElement")),(0,r.kt)("td",{parentName:"tr",align:null},"Your story can either be a React element or a function that accepts props and returns a React element. The latter format is needed to support the use of controls. See below for an example")),(0,r.kt)("tr",{parentName:"tbody"},(0,r.kt)("td",{parentName:"tr",align:null},"react"),(0,r.kt)("td",{parentName:"tr",align:null},(0,r.kt)("inlineCode",{parentName:"td"},"React")),(0,r.kt)("td",{parentName:"tr",align:null},"This must be set to your copy of React. Since React uses special symbols for things like children, flipbook needs to mount the story with the same copy of React that you used to create your elements.")),(0,r.kt)("tr",{parentName:"tbody"},(0,r.kt)("td",{parentName:"tr",align:null},"reactRoblox"),(0,r.kt)("td",{parentName:"tr",align:null},(0,r.kt)("inlineCode",{parentName:"td"},"ReactRoblox")),(0,r.kt)("td",{parentName:"tr",align:null},"This must be set to your copy of ReactRoblox that is compatible with the supplied copy of React. This is used by flipbook to mount your React components.")),(0,r.kt)("tr",{parentName:"tbody"},(0,r.kt)("td",{parentName:"tr",align:null},"name"),(0,r.kt)("td",{parentName:"tr",align:null},(0,r.kt)("inlineCode",{parentName:"td"},"string?")),(0,r.kt)("td",{parentName:"tr",align:null},"Optional name for the story. Defaults to the file name.")),(0,r.kt)("tr",{parentName:"tbody"},(0,r.kt)("td",{parentName:"tr",align:null},"summary"),(0,r.kt)("td",{parentName:"tr",align:null},(0,r.kt)("inlineCode",{parentName:"td"},"string?")),(0,r.kt)("td",{parentName:"tr",align:null},"Optional description of the story that will appear as part of the information at the top of the preview.")),(0,r.kt)("tr",{parentName:"tbody"},(0,r.kt)("td",{parentName:"tr",align:null},"controls"),(0,r.kt)("td",{parentName:"tr",align:null},(0,r.kt)("inlineCode",{parentName:"td"},"StoryControls?")),(0,r.kt)("td",{parentName:"tr",align:null},"Optional controls to see how your story behaves with various props.")))),(0,r.kt)("p",null,"Example:"),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre",className:"language-lua"},'-- example/ReactCounter.story.lua\nlocal Example = script:FindFirstAncestor("Example")\n\nlocal React = require(Example.Parent.Packages.React)\nlocal ReactRoblox = require(Example.Parent.Packages.ReactRoblox)\nlocal ReactCounter = require(script.Parent.ReactCounter)\n\nlocal controls = {\n    increment = 1,\n    waitTime = 1,\n}\n\ntype Props = {\n    controls: typeof(controls),\n}\n\nreturn {\n    summary = "A simple counter that increments every second. This is a copy of the Counter component, but written with React",\n    controls = controls,\n    react = React,\n    reactRoblox = ReactRoblox,\n    story = function(props: Props)\n        return React.createElement(ReactCounter, {\n            increment = props.controls.increment,\n            waitTime = props.controls.waitTime,\n        })\n    end,\n}\n')),(0,r.kt)("h2",{id:"functional-story"},"Functional Story"),(0,r.kt)("p",null,"A Functional story uses a function to create and mount UI. This is the most flexible story format and is useful when using a UI library that is not yet natively supported by flipbook. You simply parent your UI elements to the ",(0,r.kt)("inlineCode",{parentName:"p"},"target")," argument and optionally return a function that gets called to cleanup the story."),(0,r.kt)("table",null,(0,r.kt)("thead",{parentName:"table"},(0,r.kt)("tr",{parentName:"thead"},(0,r.kt)("th",{parentName:"tr",align:null},"Name"),(0,r.kt)("th",{parentName:"tr",align:null},"Type"),(0,r.kt)("th",{parentName:"tr",align:null},"Description"))),(0,r.kt)("tbody",{parentName:"table"},(0,r.kt)("tr",{parentName:"tbody"},(0,r.kt)("td",{parentName:"tr",align:null},"story"),(0,r.kt)("td",{parentName:"tr",align:null},(0,r.kt)("inlineCode",{parentName:"td"},"(parent: GuiObject, props: StoryProps) -> (() -> ()))?")),(0,r.kt)("td",{parentName:"tr",align:null},"Like you might expect, a Functional story uses a function to create and mount the story. This is the most flexible story format and is useful when using a UI library that is not yet natively supported. You simply parent your UI elements")),(0,r.kt)("tr",{parentName:"tbody"},(0,r.kt)("td",{parentName:"tr",align:null},"name"),(0,r.kt)("td",{parentName:"tr",align:null},(0,r.kt)("inlineCode",{parentName:"td"},"string?")),(0,r.kt)("td",{parentName:"tr",align:null},"Optional name for the story. Defaults to the file name.")),(0,r.kt)("tr",{parentName:"tbody"},(0,r.kt)("td",{parentName:"tr",align:null},"summary"),(0,r.kt)("td",{parentName:"tr",align:null},(0,r.kt)("inlineCode",{parentName:"td"},"string?")),(0,r.kt)("td",{parentName:"tr",align:null},"Optional description of the story that will appear as part of the information at the top of the preview.")),(0,r.kt)("tr",{parentName:"tbody"},(0,r.kt)("td",{parentName:"tr",align:null},"controls"),(0,r.kt)("td",{parentName:"tr",align:null},(0,r.kt)("inlineCode",{parentName:"td"},"StoryControls?")),(0,r.kt)("td",{parentName:"tr",align:null},"Optional controls to see how your story behaves with various props.")))),(0,r.kt)("p",null,"Example:"),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre",className:"language-lua"},'-- example/Functional.story.lua\nlocal controls = {\n    text = "Functional Story",\n}\n\ntype Props = {\n    controls: typeof(controls),\n}\n\nreturn {\n    summary = "This story uses a function with a cleanup callback to create and mount the gui elements. This works similarly to Hoarcekat stories but also supports controls and other metadata. Check out the source to learn more",\n    controls = controls,\n    story = function(parent: GuiObject, props: Props)\n        local label = Instance.new("TextLabel")\n        label.Text = props.controls.text\n        label.Font = Enum.Font.Gotham\n        label.TextColor3 = Color3.fromRGB(0, 0, 0)\n        label.BackgroundColor3 = Color3.fromRGB(255, 255, 255)\n        label.TextSize = 16\n        label.AutomaticSize = Enum.AutomaticSize.XY\n\n        local padding = Instance.new("UIPadding")\n        padding.PaddingTop = UDim.new(0, 8)\n        padding.PaddingRight = padding.PaddingTop\n        padding.PaddingBottom = padding.PaddingTop\n        padding.PaddingLeft = padding.PaddingTop\n        padding.Parent = label\n\n        label.Parent = parent\n\n        return function()\n            label:Destroy()\n        end\n    end,\n}\n')),(0,r.kt)("h2",{id:"hoarcekat-story"},"Hoarcekat Story"),(0,r.kt)("p",null,(0,r.kt)("a",{parentName:"p",href:"https://github.com/Kampfkarren/hoarcekat"},"Hoarcekat")," stories are supported to make migration to flipbook easier."),(0,r.kt)("p",null,"See the ",(0,r.kt)("a",{parentName:"p",href:"/flipbook/docs/migrating"},"migration guide")," for more info."),(0,r.kt)("p",null,"Example:"),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre",className:"language-lua"},'-- example/Hoarcekat.story.lua\nlocal Example = script:FindFirstAncestor("Example")\n\nlocal Roact = require(Example.Parent.Packages.Roact)\n\nreturn function(target: Instance)\n    local root = Roact.createElement("TextLabel", {\n        Text = "Hoarcekat Story",\n        TextScaled = true,\n        TextColor3 = Color3.fromRGB(255, 255, 255),\n        BackgroundColor3 = Color3.fromRGB(0, 0, 0),\n        Size = UDim2.fromOffset(300, 100),\n    }, {\n        Padding = Roact.createElement("UIPadding", {\n            PaddingTop = UDim.new(0, 8),\n            PaddingRight = UDim.new(0, 8),\n            PaddingBottom = UDim.new(0, 8),\n            PaddingLeft = UDim.new(0, 8),\n        }),\n    })\n\n    local tree = Roact.mount(root, target)\n\n    return function()\n        Roact.unmount(tree)\n    end\nend\n')))}u.isMDXComponent=!0}}]);