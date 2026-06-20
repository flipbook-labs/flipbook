import { themes as prismThemes } from 'prism-react-renderer';
import type { Config } from '@docusaurus/types';
import type * as Preset from '@docusaurus/preset-classic';
import path from 'path';
import remarkDirective from 'remark-directive';
import remarkObsidian from './src/remark/obsidian.mjs';
import obsidianSidebarItems from './src/sidebar/obsidian.mjs';

const ORGANIZATION_NAME = 'flipbook-labs'
const PROJECT_NAME = 'Flipbook'
const REPO_NAME = 'flipbook'
const REPO_URL = `https://github.com/${ORGANIZATION_NAME}/${REPO_NAME}`
const SITE_URL = `https://${ORGANIZATION_NAME}.github.io`

const config: Config = {
	title: PROJECT_NAME,
	tagline: 'A storybook plugin for Roblox',
	favicon: 'img/favicon.ico',

	url: SITE_URL,
	baseUrl: `/${REPO_NAME}/`,

	organizationName: ORGANIZATION_NAME,
	projectName: PROJECT_NAME,

	// Relaxed while the vault is mid-migration; tighten back to 'throw' once
	// unresolved wikilinks are cleaned up.
	onBrokenLinks: 'warn',
	onBrokenMarkdownLinks: 'warn',

	i18n: {
		defaultLocale: 'en',
		locales: ['en'],
	},

	// 'detect' parses .md as CommonMark so Obsidian-isms like bare <br> and
	// `{ ... }` in tables don't trip the stricter MDX compiler.
	markdown: {
		format: 'detect',
	},

	presets: [
		[
			'classic',
			{
				docs: {
					path: '../obsidian-vault',
					exclude: ['**/.obsidian/**', '**/*.base', 'drafts/**'],
					sidebarPath: './sidebars.ts',
					sidebarItemsGenerator: obsidianSidebarItems({
						vault: path.resolve(__dirname, '../obsidian-vault'),
					}),
					editUrl: `${REPO_URL}/tree/main/docs/obsidian-vault/`,
					beforeDefaultRemarkPlugins: [
						remarkDirective,
						[remarkObsidian, { vault: path.resolve(__dirname, '../obsidian-vault') }],
					],
				},
				theme: {
					customCss: './src/css/custom.css',
				},
			} satisfies Preset.Options,
		],
	],

	themeConfig: {
		image: 'img/social-card.png',
		navbar: {
			title: PROJECT_NAME,
			logo: {
				alt: `${PROJECT_NAME} Logo`,
				src: 'img/logo.svg',
			},
			items: [
				{
					type: 'docSidebar',
					sidebarId: 'docs',
					position: 'left',
					label: 'Docs',
				},
				{
					href: REPO_URL,
					label: 'GitHub',
					position: 'right',
				},
			],
		},
		footer: {
			style: 'dark',
			copyright: `Copyright © ${new Date().getFullYear()} flipbook-labs. Built with Docusaurus.`,
		},
		prism: {
			theme: prismThemes.github,
			darkTheme: prismThemes.dracula,
			additionalLanguages: ['lua', 'bash', 'diff', 'toml']
		},
	} satisfies Preset.ThemeConfig,
};

export default config;
