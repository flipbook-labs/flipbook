const MARKER = '<!-- flipbook-pr-preview -->'

function renderPreviewComment(releasePlaceId, prPlaceId) {
	const experienceUrl = (placeId) => `https://www.roblox.com/games/${placeId}`
	const launchUrl = (placeId) => `https://www.roblox.com/games/start?placeId=${placeId}`

	return `${MARKER}
## Storybook Preview

| Runtime and stories | Experience | Direct join |
| --- | --- | --- |
| Released Flipbook + PR stories | [Experience page ↗](${experienceUrl(releasePlaceId)}) | [▶ Join preview](${launchUrl(releasePlaceId)}) |
| PR Flipbook + PR stories | [Experience page ↗](${experienceUrl(prPlaceId)}) | [▶ Join preview](${launchUrl(prPlaceId)}) |
`
}

async function resolvePlaceId({ apiKey, fetch, placeName, universeId }) {
	let cursor

	do {
		const url = new URL(`https://develop.roblox.com/v1/universes/${universeId}/places`)
		url.searchParams.set('limit', '100')
		url.searchParams.set('isUniverseCreation', 'true')
		if (cursor) {
			url.searchParams.set('cursor', cursor)
		}

		const response = await fetch(url, {
			headers: { 'x-api-key': apiKey },
		})
		if (!response.ok) {
			throw new Error(`Failed to list preview places (${response.status})`)
		}

		const page = await response.json()
		const place = page.data.find((candidate) => candidate.name === placeName)
		if (place) {
			return place.id
		}

		cursor = page.nextPageCursor
	} while (cursor)

	throw new Error(`Could not find preview place ${placeName}`)
}

async function comment({ github, context }) {
	const resolve = (placeName) =>
		resolvePlaceId({
			apiKey: process.env.ROBLOX_API_KEY,
			fetch,
			placeName,
			universeId: process.env.ROBLOX_STORYBOOK_UNIVERSE_ID,
		})
	const [releasePlaceId, prPlaceId] = await Promise.all([
		resolve(process.env.RELEASE_RUNTIME_PLACE_NAME),
		resolve(process.env.PR_RUNTIME_PLACE_NAME),
	])
	const body = renderPreviewComment(releasePlaceId, prPlaceId)
	const request = {
		owner: context.repo.owner,
		repo: context.repo.repo,
		issue_number: context.issue.number,
	}
	const comments = await github.paginate(github.rest.issues.listComments, {
		...request,
		per_page: 100,
	})
	const existing = comments.find((candidate) => candidate.body?.startsWith(MARKER))

	if (existing) {
		await github.rest.issues.updateComment({
			owner: request.owner,
			repo: request.repo,
			comment_id: existing.id,
			body,
		})
	} else {
		await github.rest.issues.createComment({
			...request,
			body,
		})
	}
}

module.exports = comment
module.exports.MARKER = MARKER
module.exports.renderPreviewComment = renderPreviewComment
module.exports.resolvePlaceId = resolvePlaceId
