const assert = require('node:assert/strict')
const test = require('node:test')

const {
	MARKER,
	renderPreviewComment,
	resolvePlaceId,
} = require('./comment-storybook-preview.cjs')

test('renders both runtime and story combinations', () => {
	const comment = renderPreviewComment(123, 456)

	assert.match(comment, new RegExp(`^${MARKER}`))
	assert.match(comment, /> ### Released Flipbook \+ PR stories/)
	assert.match(comment, /> ### PR Flipbook \+ PR stories/)
	assert.match(
		comment,
		/> \*\*\[▶ Join preview\]\(https:\/\/www\.roblox\.com\/games\/start\?placeId=123\)\*\*/,
	)
	assert.match(
		comment,
		/> <sub><a href="https:\/\/www\.roblox\.com\/games\/456">Experience page ↗<\/a><\/sub>/,
	)
	assert.doesNotMatch(comment, /\| Runtime and stories \|/)
})

test('resolves places across paginated results', async () => {
	const requests = []
	const pages = [
		{
			data: [{ id: 123, name: 'Another Preview' }],
			nextPageCursor: 'next page',
		},
		{
			data: [{ id: 456, name: 'Flipbook Preview 654 PR Flipbook' }],
			nextPageCursor: null,
		},
	]
	const fetch = async (url, options) => {
		requests.push({ url: url.toString(), options })
		return {
			ok: true,
			async json() {
				return pages.shift()
			},
		}
	}

	const placeId = await resolvePlaceId({
		apiKey: 'secret',
		fetch,
		placeName: 'Flipbook Preview 654 PR Flipbook',
		universeId: '10262009842',
	})

	assert.equal(placeId, 456)
	assert.equal(requests.length, 2)
	assert.match(requests[1].url, /cursor=next\+page/)
	assert.equal(requests[0].options.headers['x-api-key'], 'secret')
})

test('rejects failed place listings without exposing the API key', async () => {
	await assert.rejects(
		resolvePlaceId({
			apiKey: 'secret',
			fetch: async () => ({ ok: false, status: 403 }),
			placeName: 'Flipbook Preview 654',
			universeId: '10262009842',
		}),
		/Failed to list preview places \(403\)/,
	)
})
