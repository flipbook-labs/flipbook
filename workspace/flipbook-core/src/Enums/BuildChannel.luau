export type BuildChannel = "production" | "beta" | "development"

return table.freeze({
	Production = "production" :: "production",
	Beta = "beta" :: "beta",
	Development = "development" :: "development",
})
