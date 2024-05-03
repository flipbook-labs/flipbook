local function maybeCall<T>(callback: ((...T) -> ())?, ...)
	if callback then
		pcall(callback, ...)
	end
end

return maybeCall
