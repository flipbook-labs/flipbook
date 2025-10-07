local ImageSet = script.Parent
local Images = require(ImageSet.Images)

local ImagesInverse = {}

for key, value in Images :: any do
	ImagesInverse[value] = key
end

return ImagesInverse
