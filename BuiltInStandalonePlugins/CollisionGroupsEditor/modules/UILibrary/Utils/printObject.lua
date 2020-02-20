--[[
	a debug function to neatly recursively print out the contents of a table and all child tables,
	with appropriate indenting to make it easy to read
]]

local function printTableInternal(tbl, indent, seen)
	tbl = tbl or {}
	indent = indent or 0

	seen = seen or {}
	seen[tbl] = true

	if 0 == indent then
		print("{")
		indent = 1
	end

	local indentSize = "     "
	for k, v in pairs(tbl) do
		local formatting = string.rep(indentSize, indent) .. k .. " = "
		if type(v) == "table" then
			if seen[v] then
				print(formatting .. "<" .. tostring(v) .. " = already printed>")
			else
				print(formatting .. tostring(v) .." = {")
				printTableInternal(v, indent+1, seen)
				print(string.rep(indentSize, indent) .. "}")
			end
		else
			print(formatting .. tostring(v))
		end
	end

	if 1 == indent then
		print("}")
	end
end

local function printObject(tbl)
	if not tbl or type(tbl) ~= "table" then
		print(tostring(tbl))
		return
	end
	printTableInternal(tbl)
end

return printObject