export type Release = {
	tag: string,
	publishedAt: string,
}

-- A prod rollback in effect. The rolled-back-to release is marked Latest,
-- while the newest release is the one it replaced or a later one.
export type RollbackState = {
	restoredTag: string,
	newestTag: string,
}

return nil
