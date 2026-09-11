import { defineConfig } from "vitepress";

// https://vitepress.dev/reference/site-config
export default defineConfig({
	title: "Flipbook",
	description: "Storybook plugin for Roblox UI",
	srcDir: "./src",
	assetsDir: "./static",

	cleanUrls: true,
	lastUpdated: true,

	markdown: {
		theme: {
			light: "catppuccin-latte",
			dark: "catppuccin-mocha",
		},
	},

	themeConfig: {
		logo: {
			light: "/logo.svg",
			dark: "/logo.svg",
		},

		nav: [
			{
				text: "Home",
				link: "/",
			},
			{
				text: "Reference",
				link: "/intro",
			},
			{
				text: "Discussions",
				link: "https://github.com/flipbook-labs/flipbook/discussions",
			},
		],

		editLink: {
			pattern:
				"https://github.com/flipbook-labs/flipbook/edit/main/site/src/:path",
		},

		sidebar: [
			{
				text: "Getting Started",
				link: "/intro",
			},
			{
				text: "Installation",
				link: "/install",
			},

			{
				text: "Stories",
				items: [
					{
						text: "Writing Stories",
						link: "/creating-stories/writing-stories",
					},
					{
						text: "Controls",
						link: "/creating-stories/controls",
					},
					{
						text: "Story Format",
						link: "/creating-stories/story-format",
					},
				],
			},

			{
				text: "Frameworks",
				items: [
					{
						text: "React",
						link: "/frameworks/react",
					},
					{
						text: "Fusion",
						link: "/frameworks/fusion",
					},
					{
						text: "Roact",
						link: "/frameworks/roact",
					},
				],
			},

			{
				text: "Migration Guides",
				items: [
					{
						text: "Hoarcekat",
						link: "migration-guides/migrating-hoarcekat",
					},
					{
						text: "UI Labs",
						link: "migration-guides/migrating-ui-labs",
					},
				],
			},

			{
				text: "Contributing",
				collapsed: true,
				items: [
					{
						text: "Onboarding",
						link: "/contributing/onboarding",
					},
					{
						text: "Creating releases",
						link: "/contributing/creating-releases",
					},
				],
			},

			{
				text: "Examples",
				collapsed: true,
				items: [
					{
						text: "Markdown Examples",
						link: "/markdown-examples",
					},
					{
						text: "Runtime API Examples",
						link: "/api-examples",
					},
				],
			},
		],

		socialLinks: [
			{
				icon: "github",
				link: "https://github.com/flipbook-labs/flipbook",
			},
		],

		search: {
			provider: "local",
		},

		footer: {
			// message: "Released under the MIT License.",
			copyright: "Copyright © 2021—2026 flipbook-labs",
		},
	},
});
