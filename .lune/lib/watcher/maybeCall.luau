local function maybeCall(callback: (() -> ())?, ...)
	if callback then
		pcall(callback, ...)
	end
end

return maybeCall
