local test = require("@std/test")

local createUuidV5 = require("@scripts/lib/createUuidV5")

local DNS_NAMESPACE = "6ba7b810-9dad-11d1-80b4-00c04fd430c8"
local URL_NAMESPACE = "6ba7b811-9dad-11d1-80b4-00c04fd430c8"

test.suite("createUuidV5", function(suite)
	suite:case("matches the RFC 9562 example", function(assert)
		assert.eq(createUuidV5(DNS_NAMESPACE, "www.example.com"), "2ed6657d-e927-568b-95e1-2665a8aea6a2")
	end)

	suite:case("returns the same UUID for the same namespace and name", function(assert)
		assert.eq(createUuidV5(DNS_NAMESPACE, "flipbook"), createUuidV5(DNS_NAMESPACE, "flipbook"))
	end)

	suite:case("returns a different UUID for a different name", function(assert)
		assert.neq(createUuidV5(DNS_NAMESPACE, "flipbook"), createUuidV5(DNS_NAMESPACE, "storyteller"))
	end)

	suite:case("returns a different UUID for a different namespace", function(assert)
		assert.neq(createUuidV5(DNS_NAMESPACE, "flipbook"), createUuidV5(URL_NAMESPACE, "flipbook"))
	end)

	suite:case("sets the version and variant", function(assert)
		for _, name in { "", "flipbook", "ci_pending_changes:195acc1d94dedcb6fe331b548259b73e653d2e70" } do
			local uuid = createUuidV5(URL_NAMESPACE, name)
			assert.that(
				uuid:match("^%x%x%x%x%x%x%x%x%-%x%x%x%x%-5%x%x%x%-[89ab]%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x$") ~= nil,
				uuid
			)
		end
	end)

	suite:case("accepts a namespace without hyphens", function(assert)
		local unhyphenated = DNS_NAMESPACE:gsub("-", "")
		assert.eq(createUuidV5(unhyphenated, "www.example.com"), createUuidV5(DNS_NAMESPACE, "www.example.com"))
	end)

	suite:case("rejects a namespace that is not a UUID", function(assert)
		assert.throws(createUuidV5, "not-a-uuid", "flipbook")
		assert.throws(createUuidV5, "6ba7b810-9dad-11d1-80b4-00c04fd430cg", "flipbook")
	end)
end)
