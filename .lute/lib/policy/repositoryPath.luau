local function repositoryPath(config: any): string
	return `repos/{config.repository.owner}/{config.repository.name}`
end

return repositoryPath
