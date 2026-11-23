local JestGlobals = require("@pkg/JestGlobals")

local afterEach = JestGlobals.afterEach
local beforeEach = JestGlobals.beforeEach
local expect = JestGlobals.expect
local jest = JestGlobals.jest
local test = JestGlobals.test

local mockResponse: { Success: boolean }?

-- Required in beforeEach, after requestAsync is mocked.
local postFeedbackAsync: typeof(require("./postFeedbackAsync"))

beforeEach(function()
	mockResponse = nil

	jest.mock(script.Parent.Parent.Http.requestAsync, function()
		return function()
			return mockResponse
		end
	end)

	postFeedbackAsync = require("./postFeedbackAsync")
end)

afterEach(function()
	jest.resetModules()
end)

test("returns true when the backend accepts the feedback", function()
	mockResponse = { Success = true }
	expect(postFeedbackAsync("Title", "Body")).toBe(true)
end)

test("returns false when the backend rejects the feedback", function()
	mockResponse = { Success = false }
	expect(postFeedbackAsync("Title", "Body")).toBe(false)
end)

test("returns false when the request can't be sent", function()
	mockResponse = nil
	expect(postFeedbackAsync("Title", "Body")).toBe(false)
end)
