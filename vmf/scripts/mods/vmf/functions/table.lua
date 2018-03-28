table.pack = function(...)
    return { n = select("#", ...); ... }
end

table.combine = function(a, b)
	local r = {unpack(a)}

	for i = 1, #b do
		r[#a + i] = b[i]
	end

	return r;
end

-- Check item exist in table
table.has_item = function(tbl, item)
    for _, value in ipairs(tbl) do
        if value == item then
			return true
		end
    end
    return false
end

table.has_item2 = function(tbl, item)
    for _, value in pairs(tbl) do
        if value == item then
			return true
		end
    end
    return false
end

table.index_of = function(t, o)
	if type(t) ~= "table" then
		return nil
	end
	for i,v in ipairs(t) do
		if o == v then
			return i
		end
	end
	return nil
end

table.adress = function(tbl)
	local str = tostring(tbl)

	return string.sub(str, 8, str:len())
end

-- Serialization and deserialization
local serialization = function(key, value)
	local str = ""

	if type(value) == "string" then
		str = str .. tostring(key) .. "=\"" .. value .. "\","
	elseif type(value) == "number" then
		str = str .. tostring(key) .. "=" .. tostring(value) .. ","
	elseif type(value) == "boolean" then
		str = str .. tostring(key) .. "="

		if value then
			str = str .. "true"
		else
			str = str .. "false"
		end

		str = str .. ","

	elseif type(value) == "table" then
		str = str .. tostring(key) .. "=" .. table.serialization(value) .. ","
	end

	return str
end

local deserialization = function(str)
	for i = 1, string.len(str) do
		local value = string.sub(str, i, i)

		if value == "=" then
			local key = string.sub(str, 1, i - 1)
			local value = string.sub(str, i + 1, string.len(str))

			-- Check key
			if string.sub(key, 1, 1) == "[" then
				key = string.sub(key, 3, string.len(key) - 2)
			else
				key = tonumber(key)
			end

			-- Check value
			if value == "true" then
				value = true
			elseif value == "false" then
				value = false
			elseif string.sub(value, 1, 1) == "\"" then
				value = string.sub(value, 2, string.len(value) - 1)
			elseif string.sub(value, 1, 1) == "{" then
				value = table.deserialization(value)
			else
				value = tonumber(value)
			end

			return key, value
		end
	end

	return nil, nil
end

table.serialization  = function(tbl)
	local str = "{"

	for key, value in ipairs(tbl) do
		str = str .. serialization(key, value)
	end
	for key, value in pairs(tbl) do
		if type(key) ~= "number" then
			str = str .. serialization("[\"" .. key .. "\"]", value)
		end
	end

	str = str .. "}"

	return str
end

table.deserialization = function(str)
	local tbl = {}

	-- Collected data
	local data = ""

	-- Checks
	local c_list = 0
	local c_str = false

	for i = 2, string.len(str) do
		local before_value = string.sub(str, i - 1, i - 1)
		local value = string.sub(str, i, i)

		-- If not inside a list or string
		if value == "," and c_list == 0 then
			-- Save propety
			local key, val = deserialization(data)

			if key then
				tbl[key] = val
			end

			-- Search for new propety
			data = ""
		else
			-- Detect string type
			if value == "\"" and not before_value ~= "\\" then
				c_str = not c_str
			end

			-- Detect list type
			if not c_str then
				if value == "{" then
					c_list = c_list + 1
				elseif value == "}" then
					c_list = c_list - 1
				end
			end

			-- save value
			data = data .. value
		end
	end

	return tbl
end