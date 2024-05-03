local fs = require("@lune/fs")

local function rmrf(path: string)
	if fs.isDir(path) then
		fs.removeDir(path)
	else
		fs.removeFile(path)
	end
end

return rmrf
