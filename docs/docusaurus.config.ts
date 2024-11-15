import { themes as prismThemes } from 'prism-react-renderer';
import type { Config } from '@docusaurus/types';
import type * as Preset from '@docusaurus/preset-classic';

const ORGANIZATION_NAME = 'flipbook-labs'
const PROJECT_NAME = 'flipbook'
const REPO_URL = `https://github.com/${ORGANIZATION_NAME}/${PROJECT_NAME}`
const SITE_URL = `https://${ORGANIZATION_NAME}.github.io`

const config: Config = {
	title: PROJECT_NAME,
	tagline: 'A storybook plugin for Roblox',
	favicon: 'img/favicon.ico',

	url: SITE_URL,
	baseUrl: `/${PROJECT_NAME}/`,

	organizationName: ORGANIZATION_NAME,
	projectName: PROJECT_NAME,

	onBrokenLinks: 'throw',
	onBrokenMarkdownLinks: 'warn',

	i18n: {
		defaultLocale: 'en',
		locales: ['en'],
	},

	presets: [
		[
			'classic',
			{
				docs: {
					sidebarPath: './sidebars.ts',
					editUrl: `${REPO_URL}/tree/main/docs/docs/`,
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
