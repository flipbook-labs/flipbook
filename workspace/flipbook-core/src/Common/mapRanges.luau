local function mapRanges(num: number, min0: number, max0: number, min1: number, max1: number): number
	if max0 == min0 then
		error("Range of zero")
	end

	return (((num - min0) * (max1 - min1)) / (max0 - min0)) + min1
end

return mapRanges
