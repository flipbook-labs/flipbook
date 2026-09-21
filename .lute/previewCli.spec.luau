local process = require("@std/process")
local test = require("@std/test")

test.case("documents the Storybook comment command", function(asserts)
	local result = process.run({
		"lute",
		"run",
		"comment-storybook-preview",
		"--help",
	})

	asserts.eq(true, result.ok)
	asserts.strContains(result.stdout, "Usage: lute run comment-storybook-preview [options]")
	asserts.strContains(result.stdout, "--release-place-name")
	asserts.strContains(result.stdout, "--branch-place-name")
	asserts.strContains(result.stdout, "--pull-request")
end)

test.case("documents the Storybook deployment command", function(asserts)
	local result = process.run({
		"lute",
		"run",
		"deploy-storybook-preview",
		"--help",
	})

	asserts.eq(true, result.ok)
	asserts.strContains(result.stdout, "Usage: lute run deploy-storybook-preview [options]")
	asserts.strContains(result.stdout, "--universe-id")
	asserts.strContains(result.stdout, "--place-name")
	asserts.strContains(result.stdout, "--api-key")
end)
